function [roiShapes measureSegChannel data dataAround objectData objectDataAround segChannel groupObjects numSegPixels] = volumeIntensityMeasure(segChannel, measureChannels, measureAroundChannels, featherSize, saveMasks, verifyZ, groupObjects, minSize, selectedSegType, threshold, imageId, imageName, roiShapes, channelLabels, pixels, datasetNames, annulusSize, gapSize)
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

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
[roiShapes, fullMaskImg, data, dataAround, objectData, objectDataAround, numSegPixels, measureSegChannel] = ROISegmentMeasureAndMask(roiShapes, pixels, measureChannels, measureAroundChannels, segChannel, verifyZ, featherSize, groupObjects, minSize, selectedSegType, threshold, channelsToFetch, numROI, annulusSize, gapSize);


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

    set(ROIText, 'String', 'Sending mask image to server');
    drawnow;

    for thisZ = 1:length(fullMaskImg(1,1,:))
        planeAsBytes = toByteArray(fullMaskImg(:,:,thisZ)', newPixels);
        store.setPlane(planeAsBytes, thisZ-1, 0, 0);
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