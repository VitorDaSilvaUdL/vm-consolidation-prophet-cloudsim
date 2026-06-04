#!/bin/bash
# Entrypoint script — fixes jpyconfig.properties before running any Java command
# Called automatically when container starts

D="/usr/local/lib/python3.8/dist-packages"

cat > "$D/jpyconfig.properties" << 'EOF'
jpy.jpyLib = /usr/local/lib/python3.8/dist-packages/jpy.cpython-38-x86_64-linux-gnu.so
jpy.jdlLib = /usr/local/lib/python3.8/dist-packages/jdl.cpython-38-x86_64-linux-gnu.so
jpy.pythonLib = /usr/lib/x86_64-linux-gnu/libpython3.8.so.1.0
jpy.pythonPrefix = /usr/local
jpy.pythonExecutable = /usr/bin/python3.8
EOF

echo "[entrypoint] jpyconfig.properties fixed:"
cat "$D/jpyconfig.properties"

exec "$@"
