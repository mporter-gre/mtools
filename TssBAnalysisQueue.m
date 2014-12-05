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
global savePath;

msgbox('Please choose/make a folder to save your data to');
uiwait;
savePath = uigetdir;

pixServ = session.getPixelsService;
images = getImages(session, 'dataset', dsIds);
numImagesTotal = length(images);
numDs = length(dsIds);

for thisDs = 1:numDs
    images = getImages(session, 'dataset', dsIds(thisDs));
    
    progress = waitbar(0, 'Downloading images');
    numImages = length(images);
    for thisImage = 1:numImages
        imageId = images(thisImage).getId.getValue;
        theImage = getImages(session, imageId);
        imageName = char(theImage.getName.getValue.getBytes');
        ans = strfind(imageName, '_masks');
        if ~isempty(ans)
            continue;
        end
        pixels = theImage.getPrimaryPixels;
        numC = pixels.getSizeC.getValue;
        numZ = pixels.getSizeZ.getValue;
        
        for thisC = 1:numC
            pixDesc = pixServ.retrievePixDescription(pixels.getId.getValue);
            ch = pixDesc.getChannel(thisC-1);
            chLog = ch.getLogicalChannel;
            chName = char(chLog.getName.getValue.getBytes');
            if strcmpi(chName, 'FITC') || strcmpi(chName, 'GFP')
                greenIdx = thisC-1;
            end
            if strcmpi(chName, 'TRITC') || strcmpi(chName, 'mCherry')
                redIdx = thisC-1;
            end
        end
        progressFraction = thisImage/numImagesTotal;
        waitbar(progressFraction, progress, 'Downloading images');
        
        %This is a modification from the original workflow to limit
        %segmentation to the middle ofthe stack. This is a measure to
        %'de-clump' some of the images that had hazy intensities towards
        %the bottom of the cells. Uncomment the 'getStack' lines to revert.
        greenStack = getStack(session, imageId, greenIdx, 0);
        redStack = getStack(session, imageId, redIdx, 0);
%         middleZ = round(numZ/2);
%         counter = 1;
%         for thisZ = middleZ-1:middleZ+1
%             greenStack(:,:,counter) = getPlane(session, imageId, thisZ-1, greenIdx, 0);
%             redStack(:,:,counter) = getPlane(session, imageId, thisZ-1, redIdx, 0);
%         end
%         
        
        cellProps = TssBRunAnalysis(greenStack, redStack, progress, progressFraction, dsIds(thisDs), imageName);
        waitbar(progressFraction, progress, 'Saving data');
        cellPropsToXLS(cellProps, imageName);
        keepProps{thisImage} = cellProps{1}.proxToFocusDist;
    end
end

close(progress);
