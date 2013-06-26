function [roiIdx roishapeIdx badImage badCredentials data] = distanceMeasure(filepath, filename, credentials, fileNum, numFiles, conditionNum, numConditions, handles)
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

global client;
global session;
global gateway;
global fig1;
global ROIText;
global selectorOutput;

badImage = 0;
badCredentials = 0;

%Let the user know what's going on, position it in the centre of the screen...
scrsz = get(0,'ScreenSize');
fig1 = figure('Name','Processing...','NumberTitle','off','MenuBar','none','Position',[(scrsz(3)/2)-150 (scrsz(4)/2)-180 300 80]);
conditionText = uicontrol(fig1, 'Style', 'text', 'String', ['Condition ', num2str(conditionNum), ' of ' num2str(numConditions)], 'Position', [25 60 250 15]);
fileText = uicontrol(fig1, 'Style', 'text', 'String', ['ROI file ', num2str(fileNum), ' of ' num2str(numFiles)], 'Position', [25 35 250 15]);
drawnow;

try
    [roiIdx roishapeIdx] = readROIs([filepath filename]);
catch 
    helpdlg(['There was a problem opening the ROI file ', filename, ', please check this file and retry it.', 'Problem']);
    set(handles.beginAnalysisButton, 'Enable', 'on');
    badImage = 1;
    return;
end
% try
%     gatewayConnect(credentials{1}, credentials{2}, credentials{3});
% catch 
%     helpdlg('Could not log you on to the server. Check your username and password');
%     set(handles.beginAnalysisButton, 'Enable', 'on');
%     badCredentials = 1;
%     return;
% end
try
    [pixelsId, imageName] = getPixIdFromROIFile([filepath filename], credentials{1}, credentials{3});
    [imageName remain] = strtok(filename, '.');
catch
    helpdlg(['Reference to ', filename, ' could not be found in your roiFileMap.xml. Please re-save the ROI file in Insight and try analysis again.']);
    set(handles.beginAnalysisButton, 'Enable', 'on');
    badImage = 1;
    return;
end

pixelsId = str2double(pixelsId);
pixels = gateway.getPixels(pixelsId);
numChannels = pixels.getSizeC.getValue;
pixelsId = pixels.getId.getValue;
channelLabel{numChannels} = [];
for thisChannel = 1:numChannels
    channelLabel{thisChannel} = session.getPixelsService.retrievePixDescription(pixelsId).getChannel(thisChannel-1).getLogicalChannel.getEmissionWave.getValue;
end

drawnow;
ROIText = uicontrol(fig1, 'Style', 'text', 'Position', [25 10 250 15]);
set(ROIText, 'String', 'Downloading image and segmenting...');
drawnow;

numROI = length(roiIdx);
for thisROI = 1:numROI
    roishapeIdx{thisROI}.name = [imageName '_mask'];
    roishapeIdx{thisROI}.origName = imageName; 
end
freeMem = [];

for thisROI = 1:numROI
    numROIZ = length(roishapeIdx{thisROI}.Z);
    for thisChannel = 1:numChannels
        for thisZ = 1:numROIZ
            [planesThisROI{thisROI}{thisChannel}(:,:,thisZ)] = getPlaneFromPixelsId(pixelsId, roishapeIdx{thisROI}.Z(thisZ), thisChannel-1, 0);
        end
    end
end

data{numROI} = [];
for thisROI = 1:numROI
    objectSelector(pixels, channelLabel, roishapeIdx{thisROI}, planesThisROI{thisROI}, credentials);
    data{thisROI} = selectorOutput;
end
clear('planesThisROI');
close(fig1);
drawnow;


end