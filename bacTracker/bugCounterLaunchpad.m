function bugCounterLaunchpad(handles, credentials)

% Copyright (C) 2013-2014 University of Dundee & Open Microscopy Environment.
% All rights reserved.
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

global gateway;

bugCounterMain(handles, credentials);

% numImages = length(imageIdVec);
% header = {'numPix' 'sum green' 'mean green' 'stDev green' 'sum red' 'mean red' 'stDev red' 'sum green - bkg' 'mean green - bkg' 'sum red - bkg' 'mean red - bkg'};
% tic;
% for thisImg = 1:numImages
%     filename = num2str(imageIdVec(thisImg));
%     pixels = gateway.getPixelsFromImage(imageIdVec(thisImg));
%     DICStack = getStackFromPixels(pixels, 0, 0);
%     greenStack = getStackFromPixels(pixels, 1, 0);
%     redStack = getStackFromPixels(pixels, 2, 0);
%     
%     segStack = DICSeg(DICStack, 60);
%     dataOut = sumIntensitiesAreasFromDICSeg(segStack, greenStack, redStack);
%     [greenBkg redBkg] = getIntensitiesInROI(imageIdVec(thisImg), greenStack, redStack);
%     bkgLine = [0 greenBkg redBkg];
%     dataOut = [bkgLine; dataOut];
%     dataOut = subtractBackground(dataOut);
%     createSpreadsheetFromData(dataOut, header, filename);
%     toc
% end

