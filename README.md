# Equipo 5 | BBP y DistBBP con Hadoop 3.3.6

**Materia:** Manejo Masivo de Datos  
**Profesor:** Javier Moya  
**Tema:** Ejemplos MapReduce para el cálculo de π

## 1. Objetivo

Ejecutar los ejemplos `bbp` y `distbbp` incluidos en Hadoop 3.3.6, identificar sus parámetros y explicar cómo se organiza el cálculo mediante tareas MapReduce. El repositorio incluye instrucciones, un script de ejecución, resultados de referencia y un ejercicio de comparación.

## 2. Entorno de trabajo

La práctica se realizó con Docker Desktop en Windows y un contenedor Debian denominado `hadoop`, con Java y Hadoop 3.3.6 instalados en `/opt/hadoop`.

**Requisitos para reproducirla:**
- Docker Desktop en funcionamiento y acceso a PowerShell.
- Un contenedor Debian existente llamado `hadoop` con Java y Hadoop 3.3.6 configurados.
- El archivo `/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar`.

Los comandos del repositorio usan el sistema de archivos local y no requieren un clúster de varios nodos. La instalación inicial de Hadoop no está automatizada en este proyecto.

## 3. Descargar el proyecto

En **PowerShell**:

```powershell
git clone https://github.com/frankofdz2/bda-equipo-5-bbp.git
cd bda-equipo-5-bbp
docker ps -a
```

Si el contenedor `hadoop` está detenido:

```powershell
docker start hadoop
```

Verificar la instalación:

```powershell
docker exec hadoop bash -lc 'java -version && /opt/hadoop/bin/hadoop version'
```

## 4. Ejecutar los ejemplos

Desde la carpeta del repositorio, en **PowerShell**:

```powershell
docker cp .\scripts\ejecutar.sh hadoop:/tmp/ejecutar-equipo5.sh
docker exec -it hadoop bash
```

Dentro del **contenedor Debian**:

```bash
sed -i 's/\r$//' /tmp/ejecutar-equipo5.sh
bash /tmp/ejecutar-equipo5.sh
```

El script guarda cada ejecución en una carpeta independiente bajo `/tmp/equipo5/ejecuciones/`. Allí se generan los resultados y los registros `bbp.log` y `distbbp.log`. No elimina ejecuciones anteriores.

**Nota técnica:** el script invoca los ejemplos con sus argumentos propios. El modo de ejecución depende de la configuración de Hadoop del contenedor; antes de describirlo como modo local debe comprobarse la configuración efectiva con `hadoop getconf` y los registros.

## 5. Comandos manuales

Dentro del contenedor:

```bash
export HADOOP_HOME=/opt/hadoop
export JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
export PATH="$JAVA_HOME/bin:$HADOOP_HOME/bin:$PATH"

JAR="$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar"
BASE="/tmp/equipo5/manual-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BASE"

hadoop jar "$JAR" bbp 1 16 2 "$BASE/bbp"
cat "$BASE/bbp/pi.txt"

hadoop jar "$JAR" distbbp 100 1 1 m 1 "$BASE/distbbp-remoto" "$BASE/distbbp-local"
find "$BASE/distbbp-local" -maxdepth 1 -type f -name '*.txt' -print | sort
```

### Parámetros

| Ejemplo | Argumentos utilizados | Significado |
| --- | --- | --- |
| BBP | `1 16 2 directorio` | Posición inicial, cantidad de dígitos hexadecimales, número de tareas Map y directorio de trabajo |
| DistBBP | `100 1 1 m 1 remoto local` | Posición en bits, número de hilos, trabajos, tipo de ejecución Map, particiones y directorios de salida |

BBP calcula dígitos de π mediante la fórmula Bailey–Borwein–Plouffe. DistBBP organiza sumas parciales relacionadas con ese cálculo y trabaja con posiciones expresadas en bits.

## 6. Resultados y evidencias

### BBP

En `resultados/bbp/pi.txt` se conserva esta salida:

```text
Pi = 0x3.243F6A8885 A308D3
Total number of hexadecimal digits is 16.

Pi = 3.1415926535 897932
Total number of decimal digits is 16.
```

El resultado corresponde a los primeros 16 dígitos hexadecimales solicitados. En la ejecución registrada se observó que BBP terminó correctamente.

### DistBBP

Las carpetas `resultados/distbbp/` y `resultados/distbbp-remoto/` contienen archivos de sumas parciales `P8_*` y `P20_*`. Esos archivos sirven para inspeccionar trabajo intermedio, pero **no demuestran por sí solos que el cálculo global haya terminado**. Para comprobarlo hay que revisar el registro completo `distbbp.log` de una nueva ejecución.

Los resultados del repositorio son material de referencia; para una entrega definitiva es conveniente contrastarlos con los archivos originales copiados del contenedor.

## 7. Relación con MapReduce

**Map:** distribuye partes del cálculo que pueden resolverse de manera independiente.  
**Shuffle y agrupación:** cuando un trabajo incluye Reduce, organiza las contribuciones intermedias.  
**Reduce:** combina las contribuciones que correspondan al algoritmo y la configuración utilizada.

No todos los trabajos tienen una fase Reduce. En particular, la opción `m` utilizada en DistBBP corresponde al trabajo por el lado Map. Además, ejecutar MapReduce en un solo contenedor no equivale a demostrar un clúster distribuido de varios equipos.

## 8. Guardar los resultados de una nueva ejecución

Dentro de Debian, identificar la carpeta reciente:

```bash
ls -lt /tmp/equipo5/ejecuciones/
```

Salir con `exit`. Después, desde PowerShell, sustituir `ID_EJECUCION` por el nombre de la carpeta creada:

```powershell
docker cp hadoop:/tmp/equipo5/ejecuciones/ID_EJECUCION/bbp/pi.txt .\resultados\bbp\pi.txt
docker cp hadoop:/tmp/equipo5/ejecuciones/ID_EJECUCION/distbbp.log .\resultados\distbbp-ejecucion.log
```

El segundo archivo queda ignorado por `.gitignore`; para publicarlo como evidencia, cambiar su extensión a `.txt` después de revisar su contenido. No reemplazar evidencias originales sin compararlas.

## 9. Actividad de comprobación

El archivo [ejercicio/ejercicio.md](ejercicio/ejercicio.md) propone ejecutar BBP con una y dos tareas Map y comparar las salidas. La explicación y los comandos están en [ejercicio/solucion.md](ejercicio/solucion.md).

## 10. Alcance y limitaciones

- Se conserva un resultado verificable de BBP.
- Existen archivos parciales de DistBBP; falta adjuntar un registro completo que confirme su terminación global.
- La reproducibilidad presupone un contenedor con Hadoop y Java previamente instalados.
- El repositorio no incluye una demostración de ejecución distribuida entre varios nodos.

Estas limitaciones permiten distinguir lo observado de lo que todavía debe comprobarse.
