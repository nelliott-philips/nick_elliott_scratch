FROM python:3.11-slim

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system deps for scipy/numpy wheels, matplotlib GUI (Tk), and some common utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-tk \
    tk \
    tcl \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libsm6 \
    libice6 \
    libglib2.0-0 \
    libgl1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# DSP / scientific Python stack
RUN pip install --no-cache-dir \
    numpy \
    scipy \
    matplotlib \
    pandas \
    sympy \
    scikit-learn \
    numba \
    pywavelets \
    soundfile \
    librosa

# Force a GUI-capable backend default (TkAgg)
ENV MPLBACKEND=TkAgg

WORKDIR /work

# Copy a demo script (optional)
COPY demo_plot.py /work/demo_plot.py

CMD ["python", "/work/demo_plot.py"]
