function [roiShapes, measureSegChannel, data, dataAround, objectCounter, objectData, objectDataAround, segChannel, groupObjects, numSegPixels] = volumeIntensityMeasure(handles, segChannel, measureChannels, measureAroundChannels, featherSize, saveMasks, verifyZ, groupObjects, minSize, selectedSegType, threshold, imageId, imageName, roiShapes, channelLabels, pixels, datasetNames, annulusSize, gapSize)
%Author Michael Porter

% Copyright (C) 2009-2014 University of Dundee.
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
global ROIText;

numROI = length(roiShapes);
for thisROI = 1:numROI
    roiShapes{thisROI}.name = [imageName '_mask'];
    roiShapes{thisROI}.origName = imageName;
end

drawnow;
channelsToFetch = unique([measureChannels measureAroundChannels]);

%Piece together a mask image the same size as the original image, and send
%it back to the server. Use segmented patches, also calculated here.

drawnow;
[roiShapes, fullMaskImg, data, dataAround, objectCounter, objectData, objectDataAround, numSegPixels, measureSegChannel] = ROISegmentMeasureAndMask(roiShapes, pixels, measureChannels, measureAroundChannels, segChannel, verifyZ, featherSize, groupObjects, minSize, selectedSegType, threshold, channelsToFetch, numROI, annulusSize, gapSize);


%Use only a single channel and time point for the fullMaskImage upload.
for thisChannel = 1
    parameters.channelList = thisChannel;
end
parameters.imageName = roiShapes{1}.name;
channelLabels = getChannelLabelsFromPixels(pixels);
channelList{1} = channelLabels{segChannel};

%Don't create a new image if user decided not to save masks.
if saveMasks == 1
    newImage = createNewImageFromOldPixels(imageId, channelList, parameters.imageName, 'uint8');
    newImageId = newImage.getId.getValue;
    newPixels = newImage.getPrimaryPixels;
    newPixelsId = newPixels.getId.getValue;
    store = session.createRawPixelsStore();
    store.setPixelsId(newPixelsId, false);

    %set(ROIText, 'String', 'Sending mask image to server');
    drawnow;

    for thisT = 1:length(fullMaskImg)
        for thisZ = 1:length(fullMaskImg{thisT}(1,1,:))
            planeAsBytes = toByteArray(fullMaskImg{thisT}(:,:,thisZ)', newPixels);
            store.setPlane(planeAsBytes, thisZ-1, 0, thisT-1);
        end
    end
    store.save();
    store.close();
    
    % Retrieve all datasets linked to image
    queryService = session.getQueryService();
    links = queryService.findAllByQuery(['select link from DatasetImageLink as link where link.child.id = ', num2str(imageId)], []);
    links = toMatlabList(links);
    datasetId = links(1).getParent().getId().getValue();
    
    % Link creation
    newLink = omero.model.DatasetImageLinkI();
    newLink.setParent(omero.model.DatasetI(datasetId, false));
    newLink.setChild(omero.model.ImageI(newImageId, false));
    session.getUpdateService().saveObject(newLink);
    
end
clear('patches');
clear('fullMaskImg');

end
