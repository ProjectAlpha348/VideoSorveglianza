#!/bin/sh
clear
#Per liberare spazio (~1,6GB) possiamo eliminare LibreOffice e Wolfram engine
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | grep sonic
apt-get -y purge wolfram-engine
apt-get -y purge libreoffice*
apt-get -y clean
apt-get -y autoremove
sleep 3

echo "Ci assicuriamo che il nostro S.O. Raspbian sia aggiornato:"

apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y
echo "rpi-update ultimo firmware sperimentale sconsigliato"
apt-get autoremove -y
sleep 2

clear
echo "INSTALLAZIONE DEI PACCHETTI NECESSARI AD OPENCV"

sleep 5
echo " "
echo "compilatore e strumenti di sviluppo"
apt-get install -y build-essential
apt-get install -y cmake cmake-curses-gui pkg-config
apt-get install -y git
sleep 3

clear
echo " image I/O packages, video I/O packages "
apt-get install -y libjpeg8-dev    # https://packages.debian.org/it/wheezy/libjpeg8-dev
apt-get install -y libjpeg-dev
apt-get install -y libtiff5-dev    # https://packages.debian.org/it/wheezy/libtiff5-dev
apt-get install -y libjasper-dev   # https://packages.debian.org/it/wheezy/libjasper-dev
apt-get install -y libpng12-dev    # https://packages.debian.org/it/wheezy/libpng12-dev
apt-get install -y libavcodec-dev
apt-get install -y libavformat-dev

apt-get install -y libswscale-dev
apt-get install -y libv4l-dev v4l-utils
apt-get install -y libeigen3-dev
apt-get install -y libxvidcore-dev
apt-get install -y libx264-dev
sleep 3

clear
echo " GTK development library"
apt-get install -y libgtk2.0-dev 
apt-get install -y libgtk-3-dev    #https://packages.debian.org/stretch/libgtk-3-dev
apt-get install libcanberra-gtk*
sleep 3

clear
echo " Python package manager"
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
python3 get-pip.py
echo
echo " Installazione di NumPy"
pip install numpy

apt-get install -y python-dev   # https://packages.debian.org/it/wheezy/python-dev
apt-get install -y python-numpy # https://packages.debian.org/it/wheezy/python-numpy
sleep 3

clear
date

#echo "INSTALLAZIONE e CREAZIONE DEL VIRTUAL ENVIRONMENT DI PYTHON"
#echo " installazione di virtualenv (opzionle)"
#pip install virtualenv virtualenvwrapper
#rm -rf get-pip.py  .cache/pip
#echo -e "\n# virtualenv and virtualenvwrapper" >> .profile
#echo "export WORKON_HOME=$HOME/.virtualenvs" >> .profile
#echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3" >> .profile
#echo "source /usr/local/bin/virtualenvwrapper.sh" >> .profile
# Per rendere effettive le modifiche
#source .profile


#mkvirtualenv py2cv3 -p python2
#mkvirtualenv py3cv3 -p python3
#mkvirtualenv py3cv4 -p python3
#sleep 3

clear
echo "COMPILAZIONE ED INSTALLAZIONE DI OPENCV"
echo "Download di OpenCV da http://opencv.org/releases.html o http://sourceforge.net/projects/opencvlibrary/files/opencv-unix"
echo "https://github.com/opencv/opencv"
cd /
wget https://github.com/opencv/opencv/archive/3.4.3.zip -O opencv_source.zip
wget https://github.com/opencv/opencv_contrib/archive/3.4.3.zip -O opencv_contrib.zip
unzip opencv_source.zip
unzip opencv_contrib.zip
cd opencv-3.4.3
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
 -D CMAKE_INSTALL_PREFIX=/usr/local \
 -D BUILD_DOCS=OFF \
 -D BUILD_EXAMPLES=OFF \
 -D BUILD_TESTS=OFF \
 -D BUILD_opencv_ts=OFF \
 -D BUILD_PERF_TESTS=OFF \
 -D INSTALL_C_EXAMPLES=ON \
 -D INSTALL_PYTHON_EXAMPLES=ON \
 -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-3.4.3/modules \
 -D ENABLE_NEON=ON \
 -D WITH_LIBV4L=ON \
        ../

sleep 3

clear
echo "Finalmente si può passare alla compilazione. Questa operazione può durare più di 12 ore! (sulla raspberry Pi 1) meno di 2 ore sulla Raspberry 3"
make -j4 
make install
ldconfig
date
