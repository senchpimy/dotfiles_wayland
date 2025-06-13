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

const configFilePath = "/home/plof/configs/quickshell/pendientes/pendientes.txt"
const timeFormat = "2006-01-02 15:04:05" // Formato que incluye la hora.

type Pendiente struct {
	Text        string     `json:"text"`
	Checked     bool       `json:"checked"`
	CompletedAt *time.Time `json:"completed_at,omitempty"`
}

type FileLine struct {
	IsTask      bool      // True si la línea es una tarea.
	Content     string    // Contenido de la línea (texto plano o texto de la tarea).
	Indentation string    // Sangría original.
	Checked     bool      // Estado de la tarea.
	CompletedAt *time.Time // Hora de completado.
}

var (
	fileModel []FileLine
	mutex     = &sync.RWMutex{}
)


func getMarkdownPath(path string) (string, error) {
	content, err := os.ReadFile(path)
	if err != nil { return "", err }
	return strings.TrimSpace(string(content)), nil
}

func loadFullFileStructure(markdownPath string) error {
	file, err := os.Open(markdownPath)
	if err != nil { return err }
	defer file.Close()

	mutex.Lock()
	defer mutex.Unlock()

	fileModel = []FileLine{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		taskMarkerIndex := strings.Index(line, "- [")

		if taskMarkerIndex != -1 { // Es una línea de tarea
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
			} else { // - [ ]
				fl.Checked = false
				fl.Content = strings.TrimSpace(strings.TrimPrefix(taskContent, "- [ ]"))
			}
			fileModel = append(fileModel, fl)
		} else { // No es una línea de tarea (encabezado, línea vacía, etc.)
			fileModel = append(fileModel, FileLine{IsTask: false, Content: line})
		}
	}
	log.Printf("Cargadas %d líneas (incluyendo estructura) desde %s", len(fileModel), markdownPath)
	return scanner.Err()
}

func saveFileStructure() error {

  todays_path := time.Now().Format("2006-01-02")
	markdownPath := "/home/plof/Documents/PythonProjects/Eiri/secretariobot/pro/horarios/" + todays_path + ".md"

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

	err = os.WriteFile(markdownPath, []byte(builder.String()), 0644)
	if err != nil { return err }
	log.Printf("Estructura guardada exitosamente en %s", markdownPath)
	return nil
}

func getPendientesHandler(w http.ResponseWriter, r *http.Request) {
	mutex.RLock()
	defer mutex.RUnlock()

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
    
    w.Header().Set("Content-Type", "text/plain; charset=utf-8")
    w.Write([]byte(builder.String()))
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
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

func main() {
  todays_path := time.Now().Format("2006-01-02")
	markdownPath := "/home/plof/Documents/PythonProjects/Eiri/secretariobot/pro/horarios/" + todays_path + ".md"
	if err := loadFullFileStructure(markdownPath); err != nil { log.Fatalf("Error al cargar pendientes: %v", err) }

	corsHandler := func(h http.HandlerFunc) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Access-Control-Allow-Origin", "*")
			if r.Method == http.MethodOptions {
				w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
				w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
				return
			}
			h(w, r)
		}
	}

	http.HandleFunc("/pendientes", corsHandler(getPendientesHandler))
	http.HandleFunc("/update", corsHandler(updatePendienteHandler))
	http.HandleFunc("/pendientes/markdown", corsHandler(getPendientesMarkdownHandler))

	log.Println("Servidor de pendientes (v3 - Estructura preservada) iniciado en http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("No se pudo iniciar el servidor: %v", err)
	}
}
