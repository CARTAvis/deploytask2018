# deploytask2018
Repository that containing packaging scripts for the new 2018 carta-backend.

# A summary of steps to build and package CARTA
(Assuming installation of all packages and libraries described on https://github.com/CARTAvis/carta-backend is already done)

1. Export your Qt path e.g. `export PATH=/Qt5.3.2/5.3/gcc_64/bin:$PATH`.

2. Download the latest CARTA source code `git clone https://github.com/CARTAvis/carta-backend.git`.

3. Prepare a build directory e.g. `mkdir build && cd build`.

4. Run the Qt qmake e.g. `qmake NOSERVER=1 CARTA_BUILD_TYPE=dev ../carta -r`.

5. Build the code e.g. `make -j 4`.

6. Download the appropriate packaging script from here e.g `curl -O https://raw.githubusercontent.com/CARTAvis/deploytask2018/master/packaging_steps_mac.sh`.

7. Modify paths in the script for your system and run the script `chmod 755 packaging_steps_mac.sh && ./packaging_steps_mac.sh`.

8. Final package should be in `/tmp/carta-backend.app`, ready copying into the Electron app.

# Miscellaneous files
These scripts automatically download the `measures_data` containing the ephemerides and geodetic files:
curl -O -L http://alma.asiaa.sinica.edu.tw/_downloads/measures_data.tar.gz

