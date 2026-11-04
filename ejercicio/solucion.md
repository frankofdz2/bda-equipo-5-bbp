# Solución del ejercicio

Los siguientes comandos se ejecutan dentro del contenedor Debian, con Hadoop 3.3.6 y Java configurados.

```bash
JAR=/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar
BASE=/tmp/equipo5/ejercicio-$(date +%Y%m%d-%H%M%S)
mkdir -p "$BASE"

hadoop jar "$JAR" bbp 1 16 1 "$BASE/un-map"
hadoop jar "$JAR" bbp 1 16 2 "$BASE/dos-maps"

cat "$BASE/un-map/pi.txt"
cat "$BASE/dos-maps/pi.txt"
diff -u "$BASE/un-map/pi.txt" "$BASE/dos-maps/pi.txt"
```

## Resultado esperado

En ambos archivos, la representación hexadecimal debe comenzar con `0x3.243F6A8885A308D3`. El comando `diff` no debería mostrar diferencias si las salidas coinciden.

## Explicación

Cambiar de una a dos tareas Map modifica cómo se reparte el cálculo, pero no los dígitos de π que se solicitan. El tiempo de ejecución puede variar según los recursos del equipo y no necesariamente mejora con más tareas. Por su parte, `distbbp` recibe una posición expresada en bits y genera cálculos parciales; sus archivos no se interpretan como la misma salida de `bbp`.
