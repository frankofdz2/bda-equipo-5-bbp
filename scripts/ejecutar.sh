#!/usr/bin/env bash
set -Eeuo pipefail
HADOOP_HOME="${HADOOP_HOME:-/opt/hadoop}"
if ! command -v java >/dev/null 2>&1; then echo 'ERROR: Java no encontrado' >&2; exit 1; fi
JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"; export JAVA_HOME HADOOP_HOME
export PATH="$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"
JAR="$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar"
[ -f "$JAR" ] || { echo "No existe $JAR" >&2; exit 1; }
RUN="$(date +%Y%m%d-%H%M%S)-$$"
BASE="/tmp/equipo5/ejecuciones/$RUN"
mkdir -p "$BASE"
echo "DIRECTORIO DE EJECUCION: $BASE"
hadoop version | head -n 1
printf '\n=== BBP ===\n'
hadoop jar "$JAR" bbp -D mapreduce.framework.name=local -fs file:/// 1 16 2 "$BASE/bbp" 2>&1 | tee "$BASE/bbp.log"
cat "$BASE/bbp/pi.txt"
printf '\n=== DISTBBP ===\n'
hadoop jar "$JAR" distbbp -D mapreduce.framework.name=local -fs file:/// 100 1 1 m 1 "$BASE/distbbp-remoto" "$BASE/distbbp-local" 2>&1 | tee "$BASE/distbbp.log"
find "$BASE/distbbp-local" -maxdepth 1 -name '*.txt' -type f | sort
printf '\nFINALIZADO. Resultados en: %s\n' "$BASE"
