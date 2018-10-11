#!/bin/bash
####
#### Script run the final packaging steps for the 2018 carta-backend on Mac
####
#### Please check every line carefully and adjust accordingly for your system.
####


# 0. Define the installed locations of your Qt and built carta-backend:
CARTABUILDHOME=/Users/acdc/cartahome/carta-backend6/build
thirdparty=/Users/acdc/cartahome/CARTAvis-externals/ThirdParty
export qtpath=/usr/local/Cellar/qt@5.7/5.7.1
packagepath=/tmp/Carta.app


# 1. Fix paths (Based on Ville's NRAO instructions):
mkdir $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks
cd $CARTABUILDHOME

cp ./cpp/core/libcore.1.dylib $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/
cp ./cpp/CartaLib/libCartaLib.1.dylib $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/

install_name_tool -change libplugin.dylib $CARTABUILDHOME/cpp/plugins/CasaImageLoader/libplugin.dylib $CARTABUILDHOME/cpp/plugins/ImageStatistics/libplugin.dylib
install_name_tool -change libcore.1.dylib  $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib $CARTABUILDHOME/cpp/plugins/ImageStatistics/libplugin.dylib

install_name_tool -change libCartaLib.1.dylib  $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $CARTABUILDHOME/cpp/plugins/ImageStatistics/libplugin.dylib
install_name_tool -change libcore.1.dylib  $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/MacOS/CARTA
install_name_tool -change libCartaLib.1.dylib  $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/MacOS/CARTA
install_name_tool -change libCartaLib.1.dylib  $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib

for f in `find . -name libplugin.dylib`; do install_name_tool -change libcore.1.dylib  $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/libcore.1.dylib $f; done
for f in `find . -name libplugin.dylib`; do install_name_tool -change libCartaLib.1.dylib  $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $f; done
for f in `find . -name "*.dylib"`; do install_name_tool -change libwcs.5.15.dylib  $thirdparty/wcslib/lib/libwcs.5.15.dylib $f; echo $f; done
for f in `find . -name libplugin.dylib`; do install_name_tool -change libCartaLib.1.dylib  $CARTABUILDHOME/cpp/desktop/CARTA.app/Contents/Frameworks/libCartaLib.1.dylib $f; done


# 2. Download and run the make-app-carta script (The make-app-carta script fixed by Grimmer):
curl -O https://raw.githubusercontent.com/CARTAvis/deploytask2018/master/make-app-carta
sed -i '' 's|\/Users\/rpmbuild\/Qt5.7.0\/5.7\/clang_64|'"${qtpath}"'|g' make-app-carta
chmod 755 make-app-carta
rm -rf $packagepath
svn export https://github.com/CARTAvis/deploytask2018/trunk/carta-backend.app
echo "make-app-carta start"
./make-app-carta -ni -v out=/tmp  ws=$CARTABUILDHOME/cpp/desktop/CARTA.app template=Carta.app
echo "make-app-carta end"


# 3. Remove .prl files and fix some things:
for f in `find $packagepath/Contents/Frameworks -name "*.prl"`;
do
 echo $f;
 rm -f $f;
done

install_name_tool -change @rpath/QtGui.framework/Versions/5/QtGui @loader_path/QtGui.framework/Versions/5/QtGui $packagepath/Contents/Frameworks/libCartaLib.1.dylib
install_name_tool -add_rpath @loader_path/../Frameworks $packagepath/Contents/MacOS/CARTA
cp $thirdparty/uWebSockets/lib/libuWS.dylib $packagepath/Contents/Frameworks 
install_name_tool -change libuWS.dylib @loader_path/../Frameworks/libuWS.dylib $packagepath/Contents/MacOS/CARTA
cp $thirdparty/zfp/lib/libzfp.0.dylib $packagepath/Contents/Frameworks


# 4. Copy over libqcocoa.dylib (no need to change @rpath to @loader_path as we will add @rpath to the desktop exectuable)
mkdir $packagepath/Contents/MacOS/platforms/
cp $qtpath/plugins/platforms/libqcocoa.dylib $packagepath/Contents/MacOS/platforms/libqcocoa.dylib


# 5. Setup geodetic and ephemerides data in the measures_directory
curl -O -L http://alma.asiaa.sinica.edu.tw/_downloads/measures_data.tar.gz
tar -xvf measures_data.tar.gz
mv measures_data $packagepath/Contents/Resources/
mv $packagepath/Contents/Resources/measures_data $packagepath/Contents/Resources/data
rm measures_data.tar.gz


# 6. Download and copy over the sample image
curl -O -L http://alma.asiaa.sinica.edu.tw/_downloads/HLTau_Band7_Continuum.fits.tar.gz
tar -xvf HLTau_Band7_Continuum.fits.tar.gz
mv HLTau_Band7_Continuum.fits $packagepath/Contents/Resources/Images


# 7. Fix for QtSql; copy its dylib file to the executable folder
mkdir $packagepath/Contents/MacOS/sqldrivers
cp $qtpath/plugins/sqldrivers/libqsqlite.dylib $packagepath/Contents/MacOS/sqldrivers/


# 8. Fix the homebrew'qt issue which uses no-rpath
qt57brewrealpath=$qtpath
echo "qt57homebrew:"$qt57brewrealpath
echo "Fix the homebrew'qt issue which uses no-rpath"
  install_name_tool -change $qt57brewrealpath/lib/QtGui.framework/Versions/5/QtGui @rpath/QtGui.framework/Versions/5/QtGui $packagepath/Contents/MacOS/platforms/libqcocoa.dylib
  install_name_tool -change $qt57brewrealpath/lib/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore $packagepath/Contents/MacOS/platforms/libqcocoa.dylib
  install_name_tool -change $qt57brewrealpath/lib/QtPrintSupport.framework/Versions/5/QtPrintSupport @rpath/QtPrintSupport.framework/Versions/5/QtPrintSupport $packagepath/Contents/MacOS/platforms/libqcocoa.dylib
  install_name_tool -change $qt57brewrealpath/lib/QtWidgets.framework/Versions/5/QtWidgets @rpath/QtWidgets.framework/Versions/5/QtWidgets $packagepath/Contents/MacOS/platforms/libqcocoa.dylib
  install_name_tool -change $qt57brewrealpath/lib/QtSql.framework/Versions/5/QtSql @rpath/QtSql.framework/Versions/5/QtSql $packagepath/Contents/MacOS/sqldrivers/libqsqlite.dylib
  install_name_tool -change $qt57brewrealpath/lib/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore $packagepath/Contents/MacOS/sqldrivers/libqsqlite.dylib


# 9. Rename Carta.app into carta-backend.app
newappname=carta-backend
mv /tmp/Carta.app /tmp/$newappname.app

# Finished

