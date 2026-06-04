# Versiones Java y Python requeridas

## Versiones exactas del paper

| Componente | Version | Notas |
|-----------|---------|-------|
| Java JDK | **8** (1.8.x) | Obligatorio. JDK 11+ no compatible con las APIs CloudSim usadas |
| Python | **3.8.x** | Obligatorio para jpy. Python 3.9+ rompe la ABI de jpy |
| jpy | latest (compilar desde source) | Bridge Java <-> Python |
| Maven | 3.6+ | Para compilar jpy con `setup.py build maven` |

## Compatibilidad de Python con jpy

jpy compila una extension `.so`/`.pyd` especifica para la version de Python.
El nombre del fichero indica la version: `jpy.cpython-38-x86_64-linux-gnu.so`

**Linux/Docker**: `jpy.cpython-38-x86_64-linux-gnu.so`
**Windows**: `jpy.cp38-win_amd64.pyd`

Si se usa Python 3.9 o superior, hay que recompilar jpy completo.

## Donde instalar JDK 8

### Windows
- Adoptium Temurin 8: https://adoptium.net/temurin/releases/?version=8
- Configurar JAVA_HOME:
  ```powershell
  $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-8.0.xxx-hotspot"
  $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
  ```

### Linux/Docker
```bash
apt-get install openjdk-8-jdk
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

## Donde instalar Python 3.8 en Windows (junto a Python 3.13)

### Opcion A: pyenv-win
```powershell
# Instalar pyenv-win
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "install-pyenv-win.ps1"
.\install-pyenv-win.ps1

# Instalar Python 3.8
pyenv install 3.8.18
pyenv local 3.8.18
python --version  # Debe mostrar 3.8.18
```

### Opcion B: Instalador oficial
- Descargar: https://www.python.org/downloads/release/python-3818/
- Instalar en: `C:\Python38\`
- NO marcar "Add to PATH" (para no romper Python 3.13)
- Usar: `C:\Python38\python.exe` explicitamente

## Variables de entorno para launcher.json

Una vez compilado jpy, actualizar launcher.json:

```json
{
  "baseFolder": "C:\\Users\\PcVIP\\Desktop\\Proyecto Sergi\\networkExperiments",
  "experimentsFolder": "testbed",
  "outputFolder": "generatedExperiments",
  "experiment": "paper4_smoke",
  "jpyLib": "C:\\path\\to\\jpy\\build\\lib.win-amd64-3.8\\jpy.cp38-win_amd64.pyd",
  "jdlLib": "C:\\path\\to\\jpy\\build\\lib.win-amd64-3.8\\jdl.cp38-win_amd64.pyd",
  "decisionLogger": "C:\\Users\\PcVIP\\Desktop\\Proyecto Sergi\\networkExperiments\\debugLog.txt",
  "pymodule": "C:\\path\\to\\cloudsim\\src\\main\\python"
}
```

## Estado actual en esta maquina (PcVIP)

| Componente | Estado |
|-----------|--------|
| Java 8 | NO instalado |
| Python 3.8 | NO instalado (hay Python 3.13) |
| jpy compilado | NO |
| pymodule | NO (no esta en el repo) |
| **Solucion rapida** | **Usar Docker** |
