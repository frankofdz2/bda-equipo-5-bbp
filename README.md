# Equipo 5 — BBP y DistBBP en Hadoop 3.3.6

**Materia:** Manejo Masivo de Datos · **Profesor:** Javier Moya · **Tema:** Cálculo de π mediante BBP.

## Objetivo
Ejecutar y explicar `bbp` y `distbbp` del JAR oficial de ejemplos de Hadoop 3.3.6 y permitir reproducir la práctica desde otro contenedor Debian con Hadoop configurado.

## Requisitos
- Windows con Docker Desktop, PowerShell y Git; contenedor existente llamado `hadoop` con Hadoop 3.3.6 y Java.
- No ejecutar `docker rm hadoop`.
- El script usa el **modo local** de Hadoop (`-D mapreduce.framework.name=local` y `-fs file:///`), por lo que no exige iniciar HDFS/YARN.
- En este ejercicio **no hay archivos de entrada externos**: BBP y DistBBP generan sus propias particiones matemáticas. `datos/` contiene una explicación.

## 1. Preparar el contenedor
**[EN TU COMPUTADORA — PowerShell]**
```powershell
docker ps -a
docker start hadoop  # solo si estaba detenido
docker exec -it hadoop bash
```
**[DENTRO DEL CONTENEDOR — bash]**
```bash
export HADOOP_HOME=/opt/hadoop
export JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
export PATH="$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"
hadoop version
ls -lh "$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar"
```
Si Java no existe, hay que reparar la instalación antes de continuar; no adivines `JAVA_HOME`.

## 2. Transferir el script
**[EN TU COMPUTADORA — PowerShell]** desde la carpeta del repositorio:
```powershell
docker cp .\scripts\ejecutar.sh hadoop:/tmp/ejecutar-equipo5.sh
docker exec -it hadoop bash
```
**[DENTRO DEL CONTENEDOR — bash]**
```bash
bash /tmp/ejecutar-equipo5.sh
```
El script crea un directorio de ejecución único bajo `/tmp/equipo5/ejecuciones/` y muestra la ruta final. No borra resultados previos. Para una demostración manual, ver sección 3.

## 3. Ejecución manual
**[DENTRO DEL CONTENEDOR — bash]** (primero configurar entorno según sección 1):
```bash
JAR=/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar
BASE=/tmp/equipo5/manual-$(date +%Y%m%d-%H%M%S)
mkdir -p "$BASE"
hadoop jar "$JAR" bbp -D mapreduce.framework.name=local -fs file:/// 1 16 2 "$BASE/bbp"
cat "$BASE/bbp/pi.txt"
hadoop jar "$JAR" distbbp -D mapreduce.framework.name=local -fs file:/// 100 1 1 m 1 "$BASE/distbbp-remoto" "$BASE/distbbp-local"
find "$BASE/distbbp-local" -maxdepth 1 -type f -name '*.txt' | sort
cat "$BASE/distbbp-local"/*.txt
```
**Nota:** Hadoop acepta las opciones genéricas antes de los argumentos propios del ejemplo. `distbbp` lanza múltiples sumas internas aun con `nJobs=1`.

## 4. Interpretación
- **BBP:** `startDigit=1`, `nDigits=16`, `nMaps=2`, `workingDir=...`. Produce texto y archivo hexadecimal de π. El cálculo conocido comienza `0x3.243F6A8885A308D3`.
- **DistBBP:** `b=100` salta 100 bits; `nThreads=1`, `nJobs=1` por suma, `type=m` (trabajo por el lado Map), `nPart=1`, más directorios remoto/local. Sus archivos `P8_*` y `P20_*` son **resultados parciales**, no una cadena de dígitos final por sí solos.
- **Map:** calcula fragmentos o sumas independientes; **shuffle/agrupación:** organiza las contribuciones; **Reduce:** combina fragmentos en BBP. En DistBBP `type=m`, el trabajo es del lado Map; no debe afirmarse que cada trabajo utiliza Reduce.
- En modo local hay ejecución de MapReduce en un único equipo, **no** un clúster distribuido real.

## 5. Evidencias disponibles y pendientes
En la sesión original, BBP terminó con `map 100% reduce 100%`, `completed successfully`, duración `1.583 seconds`; `pi.txt` mostró `Pi = 0x3.243F6A8885 A308D3` y `Pi = 3.1415926535 897932`. DistBBP produjo ocho archivos `P8_*`/`P20_*` de sumas parciales. **No se ha conservado en este repositorio la salida completa de terminación de DistBBP ni su valor combinado final.** Los archivos de `resultados/` son registros de texto basados en las salidas proporcionadas; no son capturas ni salidas binarias extraídas del contenedor.

## 6. Copiar resultados reales al repositorio
**[EN TU COMPUTADORA — PowerShell]**, después de ejecutar el script, sustituir `<ID_EJECUCION>` por el nombre impreso:
```powershell
docker cp hadoop:/tmp/equipo5/ejecuciones/<ID_EJECUCION>/bbp/pi.txt .\resultados\pi.txt
docker cp hadoop:/tmp/equipo5/ejecuciones/<ID_EJECUCION>/distbbp-local .\resultados\distbbp-local
```
Si deseas copiar el archivo `.hex`:
```powershell
docker cp hadoop:/tmp/equipo5/ejecuciones/<ID_EJECUCION>/bbp/pi_1_16.hex .\resultados\pi_1_16.hex
```
No subas carpetas masivas, archivos `.tar.gz` de Hadoop ni archivos mayores a 50 MB.

## 7. GitHub
**[EN TU COMPUTADORA — PowerShell]** dentro de la carpeta:
```powershell
git init
git add .
git commit -m "Entrega equipo 5: BBP y DistBBP"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/bda-equipo-5-bbp.git
git push -u origin main
```
Crea primero el repositorio público vacío en GitHub; sustituye `TU_USUARIO`. No se ha publicado automáticamente.

## 8. Reproducibilidad
Un compañero debe poder: clonar, verificar su contenedor, copiar `scripts/ejecutar.sh`, ejecutarlo y comparar los resultados con `resultados/`. Si falla, abrir un Issue con comando, salida completa, versión de Hadoop y sistema utilizado.

## 9. Presentación y ejercicio
Consultar `ejercicio/ejercicio.md` y `ejercicio/solucion.md`. La presentación se elaborará después de validar la reproducción.

## 10. Evidencias originales de la sesión
En el equipo que realizó la práctica, conservar `resultados/bbp`, `resultados/distbbp` y `resultados/distbbp-remoto` obtenidos con `docker cp`. La carpeta `distbbp-remoto` contiene artefactos de trabajo; para GitHub conviene conservar solo archivos de texto pequeños relevantes, sin archivos `.crc` ni directorios temporales innecesarios. No afirmar que el cálculo global de DistBBP finalizó hasta revisar el log completo.
