function selectROIFilesForVolumeIntensityMeasure(credentials, conditions, handles)
%Segment out selected regions in 3D and measure intensities, saving data
%into an Excel spreadsheet, or a .csv if Excel is not installed on the
%client machine. User will be asked to point to ROI files that relate to
%images on an Omero server. The ROIs must be rectangular, surrounding the
%object that in intended for segmentation, and can be propogated through Z
%but not T. Multiple ROIs can be segmented from the same image. Due to the
%poor memory handling of the figure windows, it is recommended to process
%fewer than 40 ROIs in a single batch. Images showing the segmentation
%masks will be uploaded to the original dataset on the server so the user
%can check the accuracy.
%
%Author Michael Porter m.porter@dundee.ac.uk

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

global gateway;
global segChannel;
segChannel = [];



numConditions = length(conditions);
paths = handles.conditionsPaths;
files = handles.conditionsFiles;

for thisCondition = 1:numConditions
    if ~iscell(files{thisCondition})
        numFiles = 1;
    else
        numFiles = length(files{thisCondition});
    end
    for thisFile = 1:numFiles
        %Read the ROIs and make the index structures.
        try
            [roiIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile}] = readROIs([paths{thisCondition} files{thisCondition}{thisFile}]);
        catch
            helpdlg(['There was a problem opening the ROI file ', files{thisCondition}{thisFile}, ', please check this file and retry it.'], 'Problem');
            set(handles.beginAnalysisButton, 'Enable', 'on');
            badImage = 1;
            return;
        end
        %Get the pixelIDs and pixels objects
        try
            [pixelsId{thisCondition}{thisFile}, imageName{thisCondition}{thisFile}] = getPixIdFromROIFile([paths{1} files{thisCondition}{thisFile}], credentials{1}, credentials{3});
            imageName{thisCondition}{thisFile} = files{thisCondition}{thisFile};
            pixelsId{thisCondition}{thisFile} = str2num(pixelsId{thisCondition}{thisFile});
            pixels{thisCondition}{thisFile} = gateway.getPixels(pixelsId{thisCondition}{thisFile});
            channelLabel{thisCondition}{thisFile} = getSegChannel(pixels{thisCondition}{thisFile});
        catch
            helpdlg(['Reference to ', files{thisCondition}{thisFile}, ' could not be found in your roiFileMap.xml. Please re-save the ROI file in Insight and try analysis again.']);
            set(handles.beginAnalysisButton, 'Enable', 'on');
            badImage = 1;
            return;
        end
    end
end

[segChannel measureChannels measureAroundChannels featherSize saveMasks verifyZ groupObjects minSize selectedSegType threshold] = ImageSegmentation(channelLabel, pixels, roishapeIdx, imageName);

for thisCondition = 1:numConditions
    if iscell(files{thisCondition})
        numFiles = length(files{thisCondition});
        for thisFile = 1:numFiles
            [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile} badImage badCredentials measureSegChannel, data{thisCondition}{thisFile}, dataAround{thisCondition}{thisFile}, objectData{thisCondition}{thisFile}, objectDataAround{thisCondition}{thisFile}, channelLabels, segChannel, groupObjects, numSegPixels{thisCondition}{thisFile}] = volumeIntensityMeasure(paths{thisCondition}, files{thisCondition}{thisFile}, credentials, thisFile, numFiles, thisCondition, numConditions, handles, segChannel, measureChannels, measureAroundChannels, featherSize, saveMasks, verifyZ, groupObjects, minSize, selectedSegType, threshold);
            if badImage == 0
                if badCredentials == 1
                    return;
                end

            else
                badImages = [badImages; thisCondition, thisFile];
                dataOut = [dataOut; {paths{thisCondition}, files{thisCondition}{thisFile}, 'Bad image or ROI file', '', '', ''}];
                continue;
            end
        end
    else
        thisFile = 1;
        numFiles{thisCondition} = 1;
        [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile} badImage, badCredentials, measureSegChannel, data{thisCondition}{thisFile}, dataAround{thisCondidion}{thisFile}, objectData{thisCondition}{thisFile}, objectDataAround{thisCondition}{thisFile}, channelLabels, segChannel, groupObjects, numSegPixels{thisCondition}{thisFile}] = volumeIntensityMeasure(paths{thisCondition}, files{thisCondition}{thisFile}, credentials, thisFile, numFiles{thisCondition}, thisCondition, numConditions, handles, measureChannels, measureAroundChannels, featherSize, saveMasks, verifyZ, groupObjects, minSize, selectedSegType, threshold);
        if badImage == 0
            if badCredentials == 1
                return;
            end
            numROI = length(ROIIdx{thisCondition}{thisFile}{1});
            for thisROI = 1:numROI
                %dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{thisROI}.origName roishapeIdx{thisCondition}{thisFile}{thisROI}.name conditions{thisCondition} roishapeIdx{thisCondition}{thisFile}{thisROI}.channel roishapeIdx{thisCondition}{thisFile}{thisROI}.sumPix roishapeIdx{thisCondition}{thisFile}{thisROI}.meanPix roishapeIdx{thisCondition}{thisFile}{thisROI}.stdPix roishapeIdx{thisCondition}{thisFile}{thisROI}.numPix}];
            end
        else
            %dataOut = [dataOut; {paths{thisCondition}, files{thisCondition}{thisFile}, 'Bad image or ROI file', '', '', ''}];
            continue;
        end
    end
end

%Find the maximum number of channels needing written out.
maxChannels = 0;
maxAroundChannels = 0;
for thisCondition = 1:numConditions
    if iscell(files{thisCondition})
        numFiles = length(files{thisCondition});
        thisFile = 1:numFiles;
    else
        numFiles{thisCondition} = 1;
        thisFile = 1;
    end
    for thisFile = thisFile
        thisChannel = length(data{thisCondition}{thisFile}{1});
        if thisChannel > maxChannels
            maxChannels = thisChannel;
        end
        thisAroundChannel = length(dataAround{thisCondition}{thisFile}{1});
        if thisAroundChannel > maxAroundChannels
            maxAroundChannels = thisAroundChannel;
        end
    end
end
mainHeader = {'Original Image', 'Mask Image', 'Condition', 'ROI', 'Channel Segmented', 'Number Objects', 'Number Pixels'};
partEmptyLine = {' ',' ',' ',' ',' ',' ',' '};
dataOut = [];
objectDataOut = [];
%Create the data structure for writing out to .xls
for thisCondition = 1:numConditions
    numFiles = length(ROIIdx{thisCondition});
    for thisFile = 1:numFiles
        %Output is variable in number of columns. Do the sums...
        numROI = length(ROIIdx{thisCondition}{thisFile});
        if ~isempty(data{thisCondition}{thisFile}{1}{1}.channel)
            numMeasureChannels = length(data{thisCondition}{thisFile}{1});
        else
            numMeasureChannels = 0;
        end
        if ~isempty(dataAround{thisCondition}{thisFile}{1}{1}.channel)
            numMeasureAroundChannels = length(dataAround{thisCondition}{thisFile}{1});
        else
            numMeasureAroundChannels = 0;
        end
        
        %Write a header line for each image
        dataOut3 = [];
        emptyLine = [];
        for thisROI = 1:numROI
            thisChannelsHeader = [];
            thisChannelsAroundHeader = [];
            if numMeasureChannels > 0
                for thisHeader = 1:numMeasureChannels
                    thisChannelName = num2str(channelLabels{data{thisCondition}{thisFile}{thisROI}{thisHeader}.channel});
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
                    thisChannelAroundName = num2str(channelLabels{dataAround{thisCondition}{thisFile}{thisROI}{thisAroundHeader}.channel});
                    thisChannelsAroundHeader = [thisChannelsAroundHeader {['Summed Intensity Around Ch ', thisChannelAroundName], ['Mean Intensity Around Ch ', thisChannelAroundName], ['Standard Deviation Around Ch ', thisChannelAroundName], ['Number Pixels', thisChannelAroundName]}];
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
            dataOut1 = [dataOut1 {roishapeIdx{thisCondition}{thisFile}{thisROI}.origName roishapeIdx{thisCondition}{thisFile}{thisROI}.name conditions{thisCondition} num2str(thisROI) channelLabels{segChannel} roishapeIdx{thisCondition}{thisFile}{thisROI}.numObjects numSegPixels{thisCondition}{thisFile}{thisROI}}];
            if numMeasureChannels > 0
                for thisChannel = 1:numMeasureChannels
                    dataOut2 = [dataOut2 {data{thisCondition}{thisFile}{thisROI}{thisChannel}.sumPix data{thisCondition}{thisFile}{thisROI}{thisChannel}.meanPix data{thisCondition}{thisFile}{thisROI}{thisChannel}.stdPix}];
                end
                if numMeasureChannels < maxChannels
                    for thisPadding = numMeasureChannels+1:maxChannels
                        dataOut2 = [dataOut2 {' ', ' ', ' '}];
                    end
                end
            end

            if numMeasureAroundChannels > 0
                for thisAroundChannel = 1:numMeasureAroundChannels
                    dataAroundOut2 = [dataAroundOut2 {dataAround{thisCondition}{thisFile}{thisROI}{thisAroundChannel}.sumPix dataAround{thisCondition}{thisFile}{thisROI}{thisAroundChannel}.meanPix dataAround{thisCondition}{thisFile}{thisROI}{thisAroundChannel}.stdPix dataAround{thisCondition}{thisFile}{thisROI}{thisAroundChannel}.numPix}];
                end
                if numMeasureAroundChannels < maxAroundChannels
                    for thisPadding = numMeasureAroundChannels+1:maxAroundChannels
                        dataAroundOut2 = [dataAroundOut2 {' ', ' ', ' ',' '}];
                    end
                end
            end
            dataOut3 = [dataOut3; [dataOut1 dataOut2 dataAroundOut2]];
        end
        %Make an empty line to separate image data
        totalCols = 5 + numMeasureChannels + numMeasureAroundChannels;
        for thisCol = 1:totalCols
            emptlyLine = [emptyLine, {' '}];
        end

        dataOut = [dataOut; [mainHeader thisChannelsHeader thisChannelsAroundHeader]; dataOut3; emptyLine];

        %Compile the data for each segmented object, if not grouped.
        if groupObjects == 0
            %Write a header for each image
            mainHeaderObjects = {'Original Image', 'Condition', 'ROI', 'Channel Segmented', 'Number Pixels'};
            partEmptyLineObjects = {' ',' ',' ',' '};
            emptyLine = [];
            for thisROI = 1:numROI
                thisChannelsHeader = [];
                thisChannelsAroundHeader = [];
                objectDataOut1 = [];
                objectDataOut2 = [];
                if numMeasureChannels > 0
                    for thisHeader = 1:numMeasureChannels
                        thisChannelName = num2str(channelLabels{data{thisCondition}{thisFile}{thisROI}{thisHeader}.channel});
                        thisChannelsHeader = [thisChannelsHeader {['Summed Intensity Ch ', thisChannelName], ['Mean Intensity Ch ', thisChannelName], ['Standard Deviation Ch ', thisChannelName]}];
                    end
                    if numMeasureChannels < maxChannels
                        for thisPadding = numMeasureChannels+1:maxChannels
                            thisChannelsHeader = [thisChannelsHeader, {' ', ' ', ' '}];
                        end
                    end
                end
                if numMeasureChannels > 0
                    numObjects = length(objectData{thisCondition}{thisFile}{thisROI});
                    objectDataOut1 = [];
                    for thisObject = 1:numObjects
                        numMeasureChannels = length(objectData{thisCondition}{thisFile}{thisROI}{thisObject});
                        for thisChannel = 1:numMeasureChannels
                            if isfield(objectData{thisCondition}{thisFile}{thisROI}{thisObject}{thisChannel}, 'numPix')
                                numSegObjectPixels = objectData{thisCondition}{thisFile}{thisROI}{thisObject}{thisChannel}.numPix;
                                continue;
                            end
                        end
                        objectDataOut1 = [objectDataOut1 {roishapeIdx{thisCondition}{thisFile}{thisROI}.origName conditions{thisCondition} num2str(thisROI) channelLabels{segChannel} numSegObjectPixels}];
                        for thisChannel = 1:numMeasureChannels
                            objectDataOut1 = [objectDataOut1 {objectData{thisCondition}{thisFile}{thisROI}{thisObject}{thisChannel}.sumPix objectData{thisCondition}{thisFile}{thisROI}{thisObject}{thisChannel}.meanPix objectData{thisCondition}{thisFile}{thisROI}{thisObject}{thisChannel}.stdPix}];
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

                %emptyLine = [emptyLine, partEmptyLine];
                objectDataOut = [objectDataOut; [mainHeaderObjects thisChannelsHeader]; objectDataOut2; emptyLine];



            end

        end
    end
end





[saveFile savePath] = uiputfile('*.xls','Save Results',[handles.currDir, '/VolumeIntensityMeasurements.xls']);
if isnumeric(saveFile) && isnumeric(savePath)
    return;
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
end
