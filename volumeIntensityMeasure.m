function [roiShapes measureSegChannel data dataAround objectData objectDataAround segChannel groupObjects numSegPixels] = volumeIntensityMeasure(handles, segChannel, measureChannels, measureAroundChannels, featherSize, saveMasks, verifyZ, groupObjects, minSize, selectedSegType, threshold, imageId, imageName, roiShapes, channelLabels, pixels, datasetNames, annulusSize, gapSize)
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

global gateway;
global fig1;
global ROIText;

%Let the user know what's going on, position it in the centre of the
%screen...
% scrsz = get(0,'ScreenSize');
% fig1 = figure('Name','Processing...','NumberTitle','off','MenuBar','none','Position',[(scrsz(3)/2)-150 (scrsz(4)/2)-180 300 80]);
% conditionText = uicontrol(fig1, 'Style', 'text', 'String', ['Condition ', num2str(conditionNum), ' of ' num2str(numConditions)], 'Position', [25 60 250 15]);
% fileText = uicontrol(fig1, 'Style', 'text', 'String', ['ROI file ', num2str(fileNum), ' of ' num2str(numFiles)], 'Position', [25 35 250 15]);
% drawnow;

%[filename filepath] = uigetfile('*.xml');
%Process the ROI file for cropping the images and passing the ROI's back to
%selectROIFiles.m
% try
%     [roiIdx roishapeIdx] = readROIs([filepath filename]);
% catch 
%     helpdlg(['There was a problem opening the ROI file ', filename, ', please check this file and retry it.', 'Problem']);
%     set(handles.beginAnalysisButton, 'Enable', 'on');
%     badImage = 1;
%     return;
% end
% 
% try
%     [pixelsId, imageName] = getPixIdFromROIFile([filepath filename], credentials{1}, credentials{3});
%     [imageName remain] = strtok(filename, '.');
% catch
%     helpdlg(['Reference to ', filename, ' could not be found in your roiFileMap.xml. Please re-save the ROI file in Insight and try analysis again.']);
%     set(handles.beginAnalysisButton, 'Enable', 'on');
%     badImage = 1;
%     return;
% end


% pixelsId = str2double(pixelsId);
% pixels = gateway.getPixels(pixelsId);
% imageId = pixels.getImage.getId.getValue;
channelLabel = getSegChannel(pixels);
%[segChannel remembered scope measureChannels measureAroundChannels featherSize saveMasks verifyZ groupObjects] = channelSelector(channelLabel);


drawnow;
% ROIText = uicontrol(fig1, 'Style', 'text', 'Position', [25 10 250 15]);
% set(ROIText, 'String', 'Downloading image and segmenting...');
drawnow;

%, '|2.', channelLabel{2}, '|3. ', channelLabel{3}, '|4. ', channelLabel{4}
%Get planes for each ROIShape listed, grouped by ROI, then copy the ROI
%patch to a new image and upload it to the server. Also get the deltaT via
%query for the first and last roishape T and Z.
numROI = length(roiShapes);
for thisROI = 1:numROI
    roiShapes{thisROI}.name = [imageName '_mask'];
    roiShapes{thisROI}.origName = imageName;
end

drawnow;
channelsToFetch = unique([measureChannels measureAroundChannels]);
%[patches measureSegChannel] = cutPatchesFromROI(roishapeIdx, numROI, segChannel, channelsToFetch, pixels);

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
    newPixels = gateway.getPixelsFromImage(newImageId);
    newPixelsId = newPixels.get(0).getId.getValue;

    set(ROIText, 'String', 'Sending mask image to server');
    drawnow;

    for thisZ = 1:length(fullMaskImg(1,1,:))
        planeAsBytes = omerojava.util.GatewayUtils.convertClientToServer(newPixels.get(0), fullMaskImg(:,:,thisZ)');
        gateway.uploadPlane(newPixelsId, thisZ-1, 0, 0, planeAsBytes);
    end

    thisImageLinks = gateway.findAllByQuery(['select link from DatasetImageLink as link where link.child.id = ', num2str(imageId)]);
    imageLinksIter = thisImageLinks.iterator;
    thisIter = 1;
    while imageLinksIter.hasNext
        imageLinks(thisIter) = imageLinksIter.next.getParent.getId.getValue;
        thisIter = thisIter + 1;
    end
    sortedLinks = sort(imageLinks);

    aDataset = gateway.getDataset(sortedLinks(1),0);
    aDataset.unload;
    newImage.unload;
    newLink = omero.model.DatasetImageLinkI();
    newLink.link(aDataset, newImage);
    gateway.saveObject(newLink);
end
clear('patches');
clear('fullMaskImg');
%close(fig1);

end