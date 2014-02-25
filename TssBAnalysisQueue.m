function TssBAnalysisQueue(dsIds)

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

global session;

pixServ = session.getPixelsService;

images = getImages(session, 'dataset', dsIds);

progress = waitbar(0, 'Downloading images');
numImages = length(images);
for thisImage = 1:numImages
    imageId = images(thisImage).getId.getValue;
    theImage = getImages(session, imageId);
    imageName = char(theImage.getName.getValue.getBytes');
    pixels = theImage.getPrimaryPixels;
    numC = pixels.getSizeC.getValue;
    
    for thisC = 1:numC
        pixDesc = pixServ.retrievePixDescription(pixels.getId.getValue);
        ch = pixDesc.getChannel(thisC-1);
        chLog = ch.getLogicalChannel;
        chName = char(chLog.getName.getValue.getBytes');
        if strcmpi(chName, 'FITC')
            greenIdx = thisC-1;
        end
        if strcmpi(chName, 'TRITC')
            redIdx = thisC-1;
        end
    end
    progressFraction = thisImage/numImages;
    waitbar(progressFraction, progress, 'Downloading images');
    greenStack = getStack(session, imageId, greenIdx, 0);
    redStack = getStack(session, imageId, redIdx, 0);
    
    cellProps = TssBRunAnalysis(greenStack, redStack, progress, progressFraction);
    waitbar(progressFraction, progress, 'Saving data');
    cellPropsToXLS(cellProps, imageName);
end

close(progress);
