# Son todas variables que ayudan a que Streamlit funcione correctamente detras de un proxy y webs

# Este es el Dockerfile 
FROM python:3.11-slim

# Esto sirve para evitar prompts y reducir tamaño
ENV PYHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Crear usuario no-root
RUN useradd -m appuser


# Instalar curl (y limpiar caché de apt)
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
# ...existing code...
# Path relativo de aplicación. En el caso de que no exista, lo crea
WORKDIR /app

# COpiar requerimientos primero para aprovechar cache
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copia el resto del codigo
COPY . /app

# Cambia permisos (chown es un comand oque sirve para cambiar el dueñoad ho de los archivos y directorios de un contenedor)
RUN chown -R appuser:appuser /app
USER appuser

# Streamlit en 0.0.0.0 y puerto configurable por env
# EXPOSE 8501
ENV STREAMLIT_SERVER_PORT=$PORT \
    STREAMLIT_SERVER_ADDRESS=0.0.0.0 \
    STREAMLIT_HEADLESS=true

# Ajustes recomendados para proxy y websockets
ENV STREAMLIT_SERVER_ENABLECORS=false \
    STREAMLIT_SERVER_ENABLEXSRSFPROTECTION=true \
    STREAMLIT_SERVER_TRUSTED_ORIGINS="*"

CMD bash -lc "streamlit run app.py --server.port=${PORT} --server.address=${STREAMLIT_SERVER_ADDRESS}"