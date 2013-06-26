#!/bin/bash
#Execute ImageAnalysis application, first launching X11 and then setting the correct display. This assumes the #MATLAB Component Runtime has been installed in the default location /Applications/MATLAB/MAtlab_Complonent...

currDir=${0%'Launch_Image_Analysis_App.command'*};
cd $currDir
compname=`uname -n`;
beforeDot=${compname%.*};
export DISPLAY=$beforeDot:0;
echo $DISPLAY;
isXRunning=`ps ax | grep -v grep | grep X11`;
lengthXRunning=${#isXRunning};

if [ "$lengthXRunning" -eq "0" ]
then echo "Starting X11.";
/Applications/Utilities/X11.app/Contents/MacOS/X11 & sleep 5;
fi

./run_ImageAnalysisMac.sh /Applications/MATLAB/MATLAB_Component_Runtime/v77/;
