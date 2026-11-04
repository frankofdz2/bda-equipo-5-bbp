# Solución del mini ejercicio
**[DENTRO DEL CONTENEDOR — bash]** con `JAVA_HOME`, `PATH` y `HADOOP_HOME` configurados:
```bash
JAR=/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar
BASE=/tmp/equipo5/ejercicio-$(date +%Y%m%d-%H%M%S)
hadoop jar "$JAR" bbp -D mapreduce.framework.name=local -fs file:/// 1 16 1 "$BASE/uno"
hadoop jar "$JAR" bbp -D mapreduce.framework.name=local -fs file:/// 1 16 2 "$BASE/dos"
cat "$BASE/uno/pi.txt"
cat "$BASE/dos/pi.txt"
```
Se espera el mismo valor de π en ambos casos: `0x3.243F6A8885A308D3`. Cambia la cantidad de tareas Map y la partición del trabajo, no el valor matemático. DistBBP utiliza un desplazamiento en **bits** y diferentes sumas parciales, por lo que no es la misma salida directa.
