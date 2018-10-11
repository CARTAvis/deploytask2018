#!/bin/bash
  
dirname=`dirname $0`

echo "dirname $dirname"

## Check if Images directory exists and if not, create it plus copy the sample image.
if [ ! -d $HOME/CARTA/Images ]; then
	mkdir -p $HOME/CARTA/Images
        cp $dirname/../Resources/Images/HLTau_Band7_Continuum.fits $HOME/CARTA/Images
fi

## Check if cache directory exists and if not, create it.
if [ ! -d $HOME/CARTA/cache ]; then
	mkdir -p $HOME/CARTA/cache
fi

## Check if log directory exists and if not, create it.
if [ ! -d $HOME/CARTA/log ]; then
        mkdir -p $HOME/CARTA/log
fi

logfilename=$HOME/CARTA/log/$(date +"%Y%m%d_%H%M%S_%Z").log

## source the measures data
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/../Resources"

export CASAPATH="$DIR linux local `hostname`"

$dirname/CARTA --port=50505 >> $logfilename 2>&1
