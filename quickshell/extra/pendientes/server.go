package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"
)

const timeFormat = "2006-01-02 15:04:05"

type Pendiente struct {
	Text        string     `json:"text"`
	Checked     bool       `json:"checked"`
	CompletedAt *time.Time `json:"completed_at,omitempty"`
}

type FileLine struct {
	IsTask      bool
	Content     string
	Indentation string
	Checked     bool
	CompletedAt *time.Time
}

var (
	fileModel    []FileLine
	markdownPath string
	mutex        = &sync.RWMutex{}
)

func loadFullFileStructure(path string) error {
	file, err := os.Open(path)
	if err != nil {
		return err
	}
	defer file.Close()

	mutex.Lock()
	defer mutex.Unlock()

	fileModel = []FileLine{} 
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		taskMarkerIndex := strings.Index(line, "- [")

		if taskMarkerIndex != -1 {
			var fl FileLine
			fl.IsTask = true
			fl.Indentation = line[:taskMarkerIndex]
			taskContent := strings.TrimSpace(line[taskMarkerIndex:])

			if strings.HasPrefix(taskContent, "- [x]") {
				fl.Checked = true
				fullText := strings.TrimSpace(strings.TrimPrefix(taskContent, "- [x]"))
				if dateIndex := strings.LastIndex(fullText, " @{"); dateIndex != -1 && strings.HasSuffix(fullText, "}") {
					fl.Content = strings.TrimSpace(fullText[:dateIndex])
					dateStr := fullText[dateIndex+3 : len(fullText)-1]
					if t, err := time.Parse(timeFormat, dateStr); err == nil {
						fl.CompletedAt = &t
					}
				} else {
					fl.Content = fullText
				}
			} else { // Trata [ ] y [-] como no completadas
				fl.Checked = false
				contentWithoutMarker := strings.TrimPrefix(taskContent, "- [ ]")
				contentWithoutMarker = strings.TrimPrefix(contentWithoutMarker, "- [-]")
				fl.Content = strings.TrimSpace(contentWithoutMarker)
			}
			fileModel = append(fileModel, fl)
		} else {
			fileModel = append(fileModel, FileLine{IsTask: false, Content: line})
		}
	}
	log.Printf("Cargadas %d líneas (incluyendo estructura) desde %s", len(fileModel), path)
	return scanner.Err()
}

func saveFileStructure() error {
	if markdownPath == "" {
		return fmt.Errorf("no hay una ruta de archivo configurada para guardar")
	}

	var builder strings.Builder
	for i, line := range fileModel {
		if line.IsTask {
			builder.WriteString(line.Indentation)
			if line.Checked {
				builder.WriteString(fmt.Sprintf("- [x] %s", line.Content))
				if line.CompletedAt != nil {
					builder.WriteString(fmt.Sprintf(" @{%s}", line.CompletedAt.Format(timeFormat)))
				}
			} else {
				builder.WriteString(fmt.Sprintf("- [ ] %s", line.Content))
			}
		} else {
			builder.WriteString(line.Content)
		}
		if i < len(fileModel)-1 {
			builder.WriteString("\n")
		}
	}

	err := os.WriteFile(markdownPath, []byte(builder.String()), 0644)
	if err != nil {
		return err
	}
	log.Printf("Estructura guardada exitosamente en %s", markdownPath)
	return nil
}

func getPendientesHandler(w http.ResponseWriter, r *http.Request) {
	mutex.RLock()
	defer mutex.RUnlock()

	if markdownPath == "" {
		http.Error(w, "No se ha configurado un horario todavía. Use el endpoint /set-path.", http.StatusNotFound)
		return
	}

	var tasksOnly []Pendiente
	for _, line := range fileModel {
		if line.IsTask {
			tasksOnly = append(tasksOnly, Pendiente{
				Text:        line.Content,
				Checked:     line.Checked,
				CompletedAt: line.CompletedAt,
			})
		}
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(tasksOnly)
}

func getPendientesMarkdownHandler(w http.ResponseWriter, r *http.Request) {
	mutex.RLock()
	defer mutex.RUnlock()

	if markdownPath == "" {
		http.Error(w, "No se ha configurado un horario todavía.", http.StatusNotFound)
		return
	}

	content, err := os.ReadFile(markdownPath)
	if err != nil {
		http.Error(w, "Error al leer el archivo de horario.", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.Write(content)
}

type UpdateRequest struct {
	Index   int  `json:"index"`
	Checked bool `json:"checked"`
}

func updatePendienteHandler(w http.ResponseWriter, r *http.Request) {
	var req UpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	mutex.Lock()
	defer mutex.Unlock()

	if markdownPath == "" {
		http.Error(w, "No se ha configurado un horario para actualizar.", http.StatusNotFound)
		return
	}

	taskCount := -1
	targetLineIndex := -1
	for i, line := range fileModel {
		if line.IsTask {
			taskCount++
			if taskCount == req.Index {
				targetLineIndex = i
				break
			}
		}
	}

	if targetLineIndex == -1 {
		http.Error(w, "Índice de tarea no encontrado", http.StatusBadRequest)
		return
	}

	line := &fileModel[targetLineIndex]
	line.Checked = req.Checked
	if req.Checked {
		now := time.Now()
		line.CompletedAt = &now
	} else {
		line.CompletedAt = nil
	}

	if err := saveFileStructure(); err != nil {
		log.Printf("¡ATENCIÓN! Error al guardar cambios en el archivo: %v", err)
		http.Error(w, "Error interno al guardar el archivo", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

type SetPathRequest struct {
	Path string `json:"path"`
}

func setPathHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Método no permitido. Usa POST.", http.StatusMethodNotAllowed)
		return
	}
	var req SetPathRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Cuerpo JSON inválido", http.StatusBadRequest)
		return
	}
	if req.Path == "" {
		http.Error(w, "El campo 'path' no puede estar vacío", http.StatusBadRequest)
		return
	}

	log.Printf("Recibida nueva ruta de horario: %s", req.Path)
	if err := loadFullFileStructure(req.Path); err != nil {
		log.Printf("ERROR al cargar el nuevo archivo de horario: %v", err)
		http.Error(w, "No se pudo cargar el archivo en la ruta especificada", http.StatusInternalServerError)
		return
	}

	mutex.Lock()
	markdownPath = req.Path
	mutex.Unlock()

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok", "message": "Ruta actualizada y archivo cargado."})
}

func main() {
	log.Println("Servidor de horarios iniciado. Esperando ruta en http://localhost:8080/set-path")

	corsHandler := func(h http.HandlerFunc) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Access-Control-Allow-Origin", "*")
			if r.Method == http.MethodOptions {
				w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
				w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
				return
			}
			h(w, r)
		}
	}

	http.HandleFunc("/pendientes", corsHandler(getPendientesHandler))
	http.HandleFunc("/update", corsHandler(updatePendienteHandler))
	http.HandleFunc("/pendientes/markdown", corsHandler(getPendientesMarkdownHandler))
	http.HandleFunc("/set-path", corsHandler(setPathHandler))

	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("No se pudo iniciar el servidor: %v", err)
	}
}
