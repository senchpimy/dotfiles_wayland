#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void) {
  unsigned long long user1, nice1, system1, idle1;
  unsigned long long user2, nice2, system2, idle2;

  FILE *fp = fopen("/proc/stat", "r");
  if (fp == NULL) {
    perror("Error al abrir /proc/stat");
    return 1;
  }
  // Se lee la primera línea que empieza con "cpu"
  fscanf(fp, "cpu %llu %llu %llu %llu", &user1, &nice1, &system1, &idle1);
  fclose(fp);

  // Se espera 1 segundo para obtener una segunda lectura
  sleep(1);

  fp = fopen("/proc/stat", "r");
  if (fp == NULL) {
    perror("Error al abrir /proc/stat");
    return 1;
  }
  fscanf(fp, "cpu %llu %llu %llu %llu", &user2, &nice2, &system2, &idle2);
  fclose(fp);

  // Se calculan los totales y la diferencia entre lecturas
  unsigned long long total1 = user1 + nice1 + system1 + idle1;
  unsigned long long total2 = user2 + nice2 + system2 + idle2;
  unsigned long long totalDiff = total2 - total1;
  unsigned long long idleDiff = idle2 - idle1;

  // El uso del CPU es el tiempo activo dividido por el total transcurrido
  double cpuUsage = (double)(totalDiff - idleDiff) / totalDiff * 100.0;
  printf("%.2f\n", cpuUsage);

  return 0;
}
