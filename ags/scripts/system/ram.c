#include <stdio.h>
#include <stdlib.h>

int main(void) {
  FILE *fp = fopen("/proc/meminfo", "r");
  if (!fp) {
    perror("Error al abrir /proc/meminfo");
    return 1;
  }

  unsigned long memTotal = 0, memFree = 0, buffers = 0, cached = 0;
  char line[256];

  // Se leen las líneas del archivo y se extraen los valores relevantes
  while (fgets(line, sizeof(line), fp)) {
    if (sscanf(line, "MemTotal: %lu kB", &memTotal) == 1)
      continue;
    if (sscanf(line, "MemFree: %lu kB", &memFree) == 1)
      continue;
    if (sscanf(line, "Buffers: %lu kB", &buffers) == 1)
      continue;
    if (sscanf(line, "Cached: %lu kB", &cached) == 1)
      continue;
  }
  fclose(fp);

  // Se calcula la memoria usada. Se resta de la memoria total la suma de libre,
  // buffers y caché.
  unsigned long used = memTotal - memFree - buffers - cached;
  double usage = (double)used / memTotal * 100.0;
  printf("%.2f\n", usage);

  return 0;
}
