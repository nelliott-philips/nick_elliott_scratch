FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# System + GUI dependencies
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Base utilities commonly expected by EDA tools
    ca-certificates curl git locales \
    bash csh tcsh procps lsb-release \
    unzip xz-utils file \
    # X11 client utilities for testing DISPLAY
    x11-apps xauth \
    # X11 runtime libs (GUI support)
    libx11-6 libxext6 libxrender1 libxi6 libxtst6 libxrandr2 libxcursor1 libxfixes3 \
    libsm6 libice6 \
    libxcb1 libxau6 libxdmcp6 \
    # GTK / fonts (frequently needed by vendor GUIs)
    libglib2.0-0 libgtk-3-0 libpango-1.0-0 libcairo2 libgdk-pixbuf2.0-0 libatk1.0-0 \
    fontconfig fonts-dejavu-core \
    # Misc common deps
    libnss3 libasound2 libgl1 \
    # Python + Tk for matplotlib GUI
    python3 python3-pip python3-tk \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Python DSP stack
# -----------------------------
RUN pip3 install --no-cache-dir \
    numpy scipy matplotlib pandas sympy \
    scikit-learn numba pywavelets \
    soundfile librosa

ENV MPLBACKEND=TkAgg

# -----------------------------
# ModelSim installer (baked in)
# -----------------------------
RUN mkdir -p /opt/install
COPY ModelSimSetup-18.1.0.625-linux.run /opt/install/ModelSimSetup.run
RUN chmod +x /opt/install/ModelSimSetup.run

# Common install target (mount a volume at /opt/intelFPGA for persistence)
ENV MODELSIM_HOME=/opt/intelFPGA/modelsim
ENV PATH="${MODELSIM_HOME}/bin:${PATH}"

WORKDIR /work
CMD ["/bin/bash"]
