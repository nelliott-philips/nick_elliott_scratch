FROM python:3.11-slim

# Avoid interactive prompts during apt
ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# System + GUI dependencies
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # GUI / X11 / Tk
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
    libnss3 \
    libasound2 \
    dbus-x11 \
    x11-apps \
    # Utilities ModelSim commonly expects
    bash \
    csh \
    tcsh \
    unzip \
    procps \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Python DSP / scientific stack
# -----------------------------
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

# Force GUI backend for matplotlib
ENV MPLBACKEND=TkAgg

# -----------------------------
# ModelSim installer
# -----------------------------
# Copy the installer into the image (local builds only; do not publish)
COPY ModelSimSetup-18.1.0.625-linux.run /opt/install/ModelSimSetup.run
RUN chmod +x /opt/install/ModelSimSetup.run

# Common install target
ENV MODELSIM_HOME=/opt/intelFPGA/modelsim
ENV PATH="${MODELSIM_HOME}/bin:${PATH}"

# -----------------------------
# Workspace
# -----------------------------
WORKDIR /work

# Optional demo
COPY demo_plot.py /work/demo_plot.py

# Default to shell so you can:
#  - run the ModelSim installer
#  - launch GUIs (vsim, gnome-terminal, etc.)
CMD ["/bin/bash"]
