function intensityMeasureLaunchpad(handles, credentials)

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

try
    [segChannel, measureChannels, measureAroundChannels, featherSize, saveMasks, verifyZ, groupObjects, minSize, selectedSegType, threshold, imageIds, imageNames, roiShapes, channelLabels, pixels, datasetNames, annulusSize, gapSize] = ImageSegmentation(handles, credentials);
catch ME
    throw(ME)
    return;
end
numImages = length(roiShapes);
progBar = waitbar(0, 'Analysing image');

for thisImage = 1:numImages
    waitbar(thisImage/numImages, progBar, ['Analysing image ' num2str(thisImage) ' of ' num2str(numImages)]);
    [roiShapes{thisImage}, measureSegChannel, data{thisImage}, dataAround{thisImage}, objectCounter{thisImage}, objectData{thisImage}, objectDataAround{thisImage}, segChannel, groupObjects, numSegPixels{thisImage}] = volumeIntensityMeasure(handles, segChannel, measureChannels, measureAroundChannels, featherSize, saveMasks, verifyZ, groupObjects, minSize, selectedSegType, threshold, imageIds(thisImage), imageNames{thisImage}, roiShapes{thisImage}, channelLabels, pixels{thisImage}, datasetNames, annulusSize, gapSize);
end
close(progBar);

writeDataOut(data, dataAround, objectCounter, objectData, objectDataAround, segChannel, groupObjects, numSegPixels, roiShapes, datasetNames, imageNames, channelLabels, annulusSize);



function writeDataOut(data, dataAround, objectCounter, objectData, objectDataAround, segChannel, groupObjects, numSegPixels, roiShapes, datasetNames, imageNames, channelLabels, annulusSize)

%Find the maximum number of channels needing written out.

maxChannels = 0;
maxAroundChannels = 0;
numDs = length(datasetNames);
numImages = length(imageNames);

for thisImage = 1:numImages
    numROI = length(roiShapes{thisImage});
    for thisROI = 1:numROI
        thisChannel = length(data{thisImage}{thisROI}{1}{1});
        if thisChannel > maxChannels
            maxChannels = thisChannel;
        end
        thisAroundChannel = length(dataAround{thisImage}{thisROI}{1}{1});
        if thisAroundChannel > maxAroundChannels
            maxAroundChannels = thisAroundChannel;
        end
    end
end

mainHeader = {'Original Image', 'Mask Image', 'Dataset', 'ROI', 'Time Point', 'Channel Segmented', 'Number Objects', 'Number Pixels'};
partEmptyLine = {' ',' ',' ',' ',' ',' ',' '};
dataOut = [];
objectDataOut = [];
%Create the data structure for writing out to .xls
for thisImage = 1:numImages
    numROI = length(roiShapes{thisImage});
    for thisROI = 1:numROI
        timePoints = getROITimePoints(roiShapes{thisImage}{thisROI});
        numT = length(timePoints);
        for thisT = 1:numT
            %Output is variable in number of columns. Do the sums...
            %numROI = length(ROIIdx{thisImage}{thisROI});
            if ~isempty(data{thisImage}{thisROI}{1}{1}.channel)
                numMeasureChannels = length(data{thisImage}{thisROI}{1});
            else
                numMeasureChannels = 0;
            end
            if ~isempty(dataAround{thisImage}{thisROI}{1}{1}.channel)
                numMeasureAroundChannels = length(dataAround{thisImage}{thisROI}{1});
            else
                numMeasureAroundChannels = 0;
            end
            
            %Write a header line for each image
            dataOut3 = [];
            emptyLine = [];
            %for thisROI = 1:numROI
            thisChannelsHeader = [];
            thisChannelsAroundHeader = [];
            if numMeasureChannels > 0
                for thisHeader = 1:numMeasureChannels
                    thisChannelName = num2str(channelLabels{thisImage}{data{thisImage}{thisROI}{1}{thisHeader}.channel});
                    thisChannelsHeader = [thisChannelsHeader {['Summed Intensity Ch ', thisChannelName], ['Mean Intensity Ch ', thisChannelName], ['Standard Deviation Ch ', thisChannelName]}];
                end
                if numMeasureChannels < maxChannels
                    for thisPadding = numMeasureChannels+1:maxChannels
                        thisChannelsHeader = [thisChannelsHeader, {' ', ' ', ' '}];
                    end
                end
            end
            
            if numMeasureAroundChannels > 0
                for thisAroundHeader = 1:numMeasureAroundChannels
                    thisChannelAroundName = num2str(channelLabels{thisImage}{dataAround{thisImage}{thisROI}{thisT}{thisAroundHeader}.channel});
                    if annulusSize > 0
                        thisChannelsAroundHeader = [thisChannelsAroundHeader {['Summed Intensity ', num2str(annulusSize), 'px annulus Ch ', thisChannelAroundName], ['Mean Intensity ', num2str(annulusSize), 'px annulus Ch ', thisChannelAroundName], ['Standard Deviation ', num2str(annulusSize), 'px annulus Ch ', thisChannelAroundName], ['Number Pixels In Annulus ', thisChannelAroundName]}];
                    else
                        thisChannelsAroundHeader = [thisChannelsAroundHeader {['Summed Intensity Around Ch ', thisChannelAroundName], ['Mean Intensity Around Ch ', thisChannelAroundName], ['Standard Deviation Around Ch ', thisChannelAroundName], ['Number Pixels Around ', thisChannelAroundName]}];
                    end
                end
                if numMeasureAroundChannels < maxAroundChannels
                    for thisPadding = numMeasureAroundChannels+1:maxAroundChannels
                        thisChannelsAroundHeader = [thisChannelsAroundHeader, {' ', ' ', ' ', ' '}];
                    end
                end
            end
            
            %Compile the data for each image
            dataOut1 = [];
            dataOut2 = [];
            dataAroundOut2 = [];
            dataOut1 = [dataOut1 {roiShapes{thisImage}{thisROI}.origName roiShapes{thisImage}{thisROI}.name datasetNames{thisImage} num2str(thisROI) num2str(timePoints(thisT)) channelLabels{thisImage}{segChannel} objectCounter{thisImage}{thisROI}{thisT}.numObjects numSegPixels{thisImage}{thisROI}}];
            if numMeasureChannels > 0
                for thisChannel = 1:numMeasureChannels
                    dataOut2 = [dataOut2 {data{thisImage}{thisROI}{thisT}{thisChannel}.sumPix data{thisImage}{thisROI}{thisT}{thisChannel}.meanPix data{thisImage}{thisROI}{thisT}{thisChannel}.stdPix}];
                end
                if numMeasureChannels < maxChannels
                    for thisPadding = numMeasureChannels+1:maxChannels
                        dataOut2 = [dataOut2 {' ', ' ', ' '}];
                    end
                end
            end
            
            if numMeasureAroundChannels > 0
                for thisAroundChannel = 1:numMeasureAroundChannels
                    dataAroundOut2 = [dataAroundOut2 {dataAround{thisImage}{thisROI}{thisT}{thisAroundChannel}.sumPix dataAround{thisImage}{thisROI}{thisT}{thisAroundChannel}.meanPix dataAround{thisImage}{thisROI}{thisT}{thisAroundChannel}.stdPix dataAround{thisImage}{thisROI}{thisT}{thisAroundChannel}.numPix}];
                end
                if numMeasureAroundChannels < maxAroundChannels
                    for thisPadding = numMeasureAroundChannels+1:maxAroundChannels
                        dataAroundOut2 = [dataAroundOut2 {' ', ' ', ' ',' '}];
                    end
                end
            end
            dataOut3 = [dataOut3; [dataOut1 dataOut2 dataAroundOut2]];
            %end
            %Make an empty line to separate image data
            %totalCols = 5 + numMeasureChannels + numMeasureAroundChannels;
            [~, totalCols] = size(dataOut3);
            for thisCol = 1:totalCols
                emptyLine = [emptyLine, {' '}];
            end
            
            dataOut = [dataOut; [mainHeader thisChannelsHeader thisChannelsAroundHeader]; dataOut3; emptyLine];
            
            %Compile the data for each segmented object, if not grouped.
            if groupObjects == 0
                %Write a header for each image
                mainHeaderObjects = {'Original Image', 'Dataset', 'ROI', 'Time Point', 'Channel Segmented', 'Number Pixels'};
                partEmptyLineObjects = {' ',' ',' ',' '};
                emptyLine = [];
                
                thisChannelsHeader = [];
                thisChannelsAroundHeader = [];
                objectDataOut1 = [];
                objectDataOut2 = [];
                objectDataAroundOut2 = [];
                if numMeasureChannels > 0
                    for thisHeader = 1:numMeasureChannels
                        thisChannelName = num2str(channelLabels{thisImage}{data{thisImage}{thisROI}{thisT}{thisHeader}.channel});
                        thisChannelsHeader = [thisChannelsHeader {['Summed Intensity Ch ', thisChannelName], ['Mean Intensity Ch ', thisChannelName], ['Standard Deviation Ch ', thisChannelName]}];
                    end
                    if numMeasureChannels < maxChannels
                        for thisPadding = numMeasureChannels+1:maxChannels
                            thisChannelsHeader = [thisChannelsHeader, {' ', ' ', ' '}];
                        end
                    end
                end
                
                if numMeasureAroundChannels > 0 && annulusSize > 0
                    for thisAroundHeader = 1:numMeasureAroundChannels
                        thisChannelAroundName = num2str(channelLabels{thisImage}{dataAround{thisImage}{thisROI}{thisT}{thisAroundHeader}.channel});
                        thisChannelsAroundHeader = [thisChannelsAroundHeader {['Summed Intensity ', num2str(annulusSize), 'px annulus Ch ', thisChannelAroundName], ['Mean Intensity ', num2str(annulusSize), 'px annulus Ch ', thisChannelAroundName], ['Standard Deviation ', num2str(annulusSize), 'px annulus Ch ', thisChannelAroundName], ['Number Pixels In Annulus ', thisChannelAroundName]}];
                    end
                    if numMeasureAroundChannels < maxAroundChannels
                        for thisPadding = numMeasureAroundChannels+1:maxAroundChannels
                            thisChannelsAroundHeader = [thisChannelsAroundHeader, {' ', ' ', ' ', ' '}];
                        end
                    end
                end
                
                if numMeasureChannels > 0
                    %numObjects = length(objectData{thisImage}{thisROI}{thisChannel});
                    numObjects = objectCounter{thisImage}{thisROI}{thisT}.numObjects;
                    objectDataOut1 = [];
                    for thisObject = 1:numObjects
                        %numMeasureChannels = length(objectData{thisImage}{thisROI}{thisObject}{thisChannel});
                        for thisChannel = 1:numMeasureChannels
                            if isfield(objectData{thisImage}{thisROI}{thisT}{thisObject}{thisChannel}, 'numPix')
                                numSegObjectPixels = objectData{thisImage}{thisROI}{thisT}{thisObject}{thisChannel}.numPix;
                                continue;
                            end
                        end
                        objectDataOut1 = [objectDataOut1 {roiShapes{thisImage}{thisROI}.origName datasetNames{thisImage} num2str(thisROI) num2str(timePoints(thisT)) channelLabels{thisImage}{segChannel} numSegObjectPixels}];
                        for thisChannel = 1:numMeasureChannels
                            objectDataOut1 = [objectDataOut1 {objectData{thisImage}{thisROI}{thisT}{thisObject}{thisChannel}.sumPix objectData{thisImage}{thisROI}{thisT}{thisObject}{thisChannel}.meanPix objectData{thisImage}{thisROI}{thisT}{thisObject}{thisChannel}.stdPix}];
                        end
                        if numMeasureChannels < maxChannels
                            for thisPadding = numMeasureChannels+1:maxChannels
                                objectDataOut1 = [objectDataOut1 {' ', ' ', ' '}];
                            end
                        end
                        objectDataOut2 = [objectDataOut2; objectDataOut1];
                        objectDataOut1 = [];
                    end
                end
                if annulusSize > 0
                    if numMeasureAroundChannels > 0
                        for thisObject = 1:numObjects
                            objectDataAroundThisObject = [];
                            for thisAroundChannel = 1:numMeasureAroundChannels
                                objectDataAroundThisObject = [objectDataAroundThisObject {objectDataAround{thisImage}{thisROI}{thisT}{thisAroundChannel}{thisObject}.sumPix objectDataAround{thisImage}{thisROI}{thisT}{thisAroundChannel}{thisObject}.meanPix objectDataAround{thisImage}{thisROI}{thisT}{thisAroundChannel}{thisObject}.stdPix objectDataAround{thisImage}{thisROI}{thisT}{thisAroundChannel}{thisObject}.numPix}];
                            end
                            objectDataAroundOut2 = [objectDataAroundOut2; objectDataAroundThisObject];
                            
                            if numMeasureAroundChannels < maxAroundChannels
                                for thisPadding = numMeasureAroundChannels+1:maxAroundChannels
                                    objectDataAroundOut2 = [objectDataAroundOut2 {' ', ' ', ' ',' '}];
                                end
                            end
                        end
                    end
                    [~, numDataOutCols] = size(objectDataOut2);
                    [~, numDataAroundOutCols] = size(objectDataAroundOut2);
                    totalCols = numDataOutCols + numDataAroundOutCols;
                    for thisCol = 1:totalCols
                        emptyLine = [emptyLine, {' '}];
                    end
                    
                    objectDataOut = [objectDataOut; [mainHeaderObjects thisChannelsHeader thisChannelsAroundHeader]; [objectDataOut2 objectDataAroundOut2]; emptyLine];
                else
                    [~, totalCols] = size(objectDataOut2);
                    for thisCol = 1:totalCols
                        emptyLine = [emptyLine, {' '}];
                    end
                    objectDataOut = [objectDataOut; [mainHeaderObjects thisChannelsHeader]; objectDataOut2; emptyLine];
                end
                
            end
            
        end
    end
end

saveFile = 0;
savePath = 0;
counter = 0;
while isnumeric(saveFile) && isnumeric(savePath)
    [saveFile savePath] = uiputfile('*.xls','Save Results','/VolumeIntensityMeasurements.xls');
    display(counter)
    counter = counter + 1;
    %if isnumeric(saveFile) && isnumeric(savePath)
    %return;
    %end
end

try
    xlswrite([savePath saveFile], dataOut, 'Data by ROI');
    if groupObjects == 0
        xlswrite([savePath saveFile], objectDataOut, 'Data by Object');
    end
catch
    %If the xlswriter fails (no MSOffice installed, e.g.) then manually
    %create a .csv file. Turn every cell to string to make it easier. Do
    %this for both the ROI-level and object-level data (if it exists)
    largestCell = 0;
    [rows cols] = size(dataOut);
    for thisRow = 1:rows
        for thisCol = 1:cols
            if isnumeric(dataOut{thisRow, thisCol})
                dataOut{thisRow, thisCol} = num2str(dataOut{thisRow, thisCol});
            end
        end
    end
    delete([savePath saveFile]); %Delete the .xls file and save again as .csv
    [savePart remain] = strtok(saveFile, '.');
    saveROI = [savePart '_ROI.csv'];
    saveObject = [savePart '_Object.csv'];
    fid = fopen([savePath saveROI], 'w');
    for thisRow = 1:rows
        for thisCol = 1:cols
            fprintf(fid, '%s', dataOut{thisRow, thisCol});
            fprintf(fid, '%s', ',');
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);
    if groupObjects == 0
        [obRows obCols] = size(objectDataOut);
        for thisRow = 1:obRows
            for thisCol = 1:obCols
                if isnumeric(objectDataOut{thisRow, thisCol})
                    objectDataOut{thisRow, thisCol} = num2str(objectDataOut{thisRow, thisCol});
                end
            end
        end
        fid = fopen([savePath saveObject], 'w');
        for thisRow = 1:obRows
            for thisCol = 1:obCols
                fprintf(fid, '%s', objectDataOut{thisRow, thisCol});
                fprintf(fid, '%s', ',');
            end
            fprintf(fid, '%s\n', '');
        end
        fclose(fid);
    end
end


%datasetChooser(credentials, handles);
