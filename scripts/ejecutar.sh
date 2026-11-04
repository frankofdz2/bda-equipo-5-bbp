#!/usr/bin/env bash
set -Eeuo pipefail

HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
command -v java >/dev/null 2>&1 || { echo "Error: Java no está instalado." >&2; exit 1; }
JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
export HADOOP_HOME JAVA_HOME
export PATH="$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"

JAR="$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar"
[[ -f "$JAR" ]] || { echo "Error: no se encontró $JAR" >&2; exit 1; }
command -v hadoop >/dev/null 2>&1 || { echo "Error: no se encontró el comando hadoop." >&2; exit 1; }

BASE="/tmp/equipo5/ejecuciones/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$BASE"
echo "Directorio de trabajo: $BASE"
hadoop version | head -n 1

echo "=== BBP: 16 dígitos hexadecimales desde la posición 1 ==="
hadoop jar "$JAR" bbp 1 16 2 "$BASE/bbp" 2>&1 | tee "$BASE/bbp.log"
[[ -s "$BASE/bbp/pi.txt" ]] || { echo "Error: BBP no produjo pi.txt." >&2; exit 1; }
cat "$BASE/bbp/pi.txt"

echo "=== DistBBP: cálculo desde el bit 100 ==="
hadoop jar "$JAR" distbbp 100 1 1 m 1 "$BASE/distbbp-remoto" "$BASE/distbbp-local" 2>&1 | tee "$BASE/distbbp.log"

echo "Archivos parciales de DistBBP:"
find "$BASE/distbbp-local" -maxdepth 1 -type f -name '*.txt' -print | sort
echo "Ejecución terminada. Revisar distbbp.log para confirmar el resultado global."
echo "Resultados: $BASE"
