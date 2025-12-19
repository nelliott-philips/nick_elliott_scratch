#!/bin/bash

# docker run --rm -it \
#   -e DISPLAY=host.docker.internal:0.0 \
#   -e LM_LICENSE_FILE=/licenses/license.dat \
#   -v "C:/path/to/license.dat":/licenses/license.dat:ro \
#   dsp-modelsim:18.1

docker run --rm -it \
  -e DISPLAY=host.docker.internal:0.0 \
  -v "$(pwd)":/work \
  dsp-modelsim:18.1

# docker run --rm -it --entrypoint /bin/bash dsp-mpl-gui
