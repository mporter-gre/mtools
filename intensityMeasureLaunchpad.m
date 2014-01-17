function intensityMeasureLaunchpad(ids)

try
    [segChannel measureChannels measureAroundChannels featherSize saveMasks verifyZ groupObjects minSize selectedSegType threshold imageIds imageNames roiShapes channelLabels pixels datasetNames annulusSize gapSize] = ImageSegmentation(ids);
catch ME
    return;
end
numImages = length(roiShapes);
progBar = waitbar(0, 'Analysing image');

for thisImage = 1:numImages
    waitbar(thisImage/numImages, progBar, ['Analysing image ' num2str(thisImage) ' of ' num2str(numImages)]);
    [roiShapes{thisImage} measureSegChannel data{thisImage} dataAround{thisImage} objectData{thisImage} objectDataAround{thisImage} segChannel groupObjects numSegPixels{thisImage}] = volumeIntensityMeasure(segChannel, measureChannels, measureAroundChannels, featherSize, saveMasks, verifyZ, groupObjects, minSize, selectedSegType, threshold, imageIds(thisImage), imageNames{thisImage}, roiShapes{thisImage}, channelLabels, pixels{thisImage}, datasetNames, annulusSize, gapSize);
end
close(progBar);

writeDataOut(data, dataAround, objectData, objectDataAround, segChannel, groupObjects, numSegPixels, roiShapes, datasetNames, imageNames, channelLabels, annulusSize);



function writeDataOut(data, dataAround, objectData, objectDataAround, segChannel, groupObjects, numSegPixels, roiShapes, datasetNames, imageNames, channelLabels, annulusSize)

%Find the maximum number of channels needing written out.
maxChannels = 0;
maxAroundChannels = 0;
numDs = length(datasetNames);
numImages = length(imageNames);

for thisImage = 1:numImages
    numROI = length(roiShapes{thisImage});
    for thisROI = 1:numROI
        thisChannel = length(data{thisImage}{thisROI}{1});
        if thisChannel > maxChannels
            maxChannels = thisChannel;
        end
        thisAroundChannel = length(dataAround{thisImage}{thisROI}{1});
        if thisAroundChannel > maxAroundChannels
            maxAroundChannels = thisAroundChannel;
        end
    end
end

mainHeader = {'Original Image', 'Mask Image', 'Dataset', 'ROI', 'Channel Segmented', 'Number Objects', 'Number Pixels'};
partEmptyLine = {' ',' ',' ',' ',' ',' ',' '};
dataOut = [];
objectDataOut = [];
%Create the data structure for writing out to .xls
for thisImage = 1:numImages
    numROI = length(roiShapes{thisImage});
    for thisROI = 1:numROI
        %Output is variable in number of columns. Do the sums...
        %numROI = length(ROIIdx{thisImage}{thisROI});
        if ~isempty(data{thisImage}{thisROI}{1}.channel)
            numMeasureChannels = length(data{thisImage}{thisROI});
        else
            numMeasureChannels = 0;
        end
        if ~isempty(dataAround{thisImage}{thisROI}{1}.channel)
            numMeasureAroundChannels = length(dataAround{thisImage}{thisROI});
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
                    thisChannelName = num2str(channelLabels{thisImage}{data{thisImage}{thisROI}{thisHeader}.channel});
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
                    thisChannelAroundName = num2str(channelLabels{thisImage}{dataAround{thisImage}{thisROI}{thisAroundHeader}.channel});
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
            dataOut1 = [dataOut1 {roiShapes{thisImage}{thisROI}.origName roiShapes{thisImage}{thisROI}.name datasetNames{thisImage} num2str(thisROI) channelLabels{thisImage}{segChannel} roiShapes{thisImage}{thisROI}.numObjects numSegPixels{thisImage}{thisROI}}];
            if numMeasureChannels > 0
                for thisChannel = 1:numMeasureChannels
                    dataOut2 = [dataOut2 {data{thisImage}{thisROI}{thisChannel}.sumPix data{thisImage}{thisROI}{thisChannel}.meanPix data{thisImage}{thisROI}{thisChannel}.stdPix}];
                end
                if numMeasureChannels < maxChannels
                    for thisPadding = numMeasureChannels+1:maxChannels
                        dataOut2 = [dataOut2 {' ', ' ', ' '}];
                    end
                end
            end

            if numMeasureAroundChannels > 0
                for thisAroundChannel = 1:numMeasureAroundChannels
                    dataAroundOut2 = [dataAroundOut2 {dataAround{thisImage}{thisROI}{thisAroundChannel}.sumPix dataAround{thisImage}{thisROI}{thisAroundChannel}.meanPix dataAround{thisImage}{thisROI}{thisAroundChannel}.stdPix dataAround{thisImage}{thisROI}{thisAroundChannel}.numPix}];
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
        [blah totalCols] = size(dataOut3);
        for thisCol = 1:totalCols
            emptyLine = [emptyLine, {' '}];
        end

        dataOut = [dataOut; [mainHeader thisChannelsHeader thisChannelsAroundHeader]; dataOut3; emptyLine];

        %Compile the data for each segmented object, if not grouped.
        if groupObjects == 0
            %Write a header for each image
            mainHeaderObjects = {'Original Image', 'Dataset', 'ROI', 'Channel Segmented', 'Number Pixels'};
            partEmptyLineObjects = {' ',' ',' ',' '};
            emptyLine = [];
            
                thisChannelsHeader = [];
                thisChannelsAroundHeader = [];
                objectDataOut1 = [];
                objectDataOut2 = [];
                objectDataAroundOut2 = [];
                if numMeasureChannels > 0
                    for thisHeader = 1:numMeasureChannels
                        thisChannelName = num2str(channelLabels{thisImage}{data{thisImage}{thisROI}{thisHeader}.channel});
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
                        thisChannelAroundName = num2str(channelLabels{thisImage}{dataAround{thisImage}{thisROI}{thisAroundHeader}.channel});
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
                    numObjects = roiShapes{thisImage}{thisROI}.numObjects;
                    objectDataOut1 = [];
                    for thisObject = 1:numObjects
                        %numMeasureChannels = length(objectData{thisImage}{thisROI}{thisObject}{thisChannel});
                        for thisChannel = 1:numMeasureChannels
                            if isfield(objectData{thisImage}{thisROI}{thisObject}{thisChannel}, 'numPix')
                                numSegObjectPixels = objectData{thisImage}{thisROI}{thisObject}{thisChannel}.numPix;
                                continue;
                            end
                        end
                        objectDataOut1 = [objectDataOut1 {roiShapes{thisImage}{thisROI}.origName datasetNames{thisImage} num2str(thisROI) channelLabels{thisImage}{segChannel} numSegObjectPixels}];
                        for thisChannel = 1:numMeasureChannels
                            objectDataOut1 = [objectDataOut1 {objectData{thisImage}{thisROI}{thisObject}{thisChannel}.sumPix objectData{thisImage}{thisROI}{thisObject}{thisChannel}.meanPix objectData{thisImage}{thisROI}{thisObject}{thisChannel}.stdPix}];
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
                                objectDataAroundThisObject = [objectDataAroundThisObject {objectDataAround{thisImage}{thisROI}{thisAroundChannel}{thisObject}.sumPix objectDataAround{thisImage}{thisROI}{thisAroundChannel}{thisObject}.meanPix objectDataAround{thisImage}{thisROI}{thisAroundChannel}{thisObject}.stdPix objectDataAround{thisImage}{thisROI}{thisAroundChannel}{thisObject}.numPix}];
                            end
                            objectDataAroundOut2 = [objectDataAroundOut2; objectDataAroundThisObject];

                            if numMeasureAroundChannels < maxAroundChannels
                                for thisPadding = numMeasureAroundChannels+1:maxAroundChannels
                                    objectDataAroundOut2 = [objectDataAroundOut2 {' ', ' ', ' ',' '}];
                                end
                            end
                        end
                    end
                    [blah numDataOutCols] = size(objectDataOut2);
                    [blah numDataAroundOutCols] = size(objectDataAroundOut2);
                    totalCols = numDataOutCols + numDataAroundOutCols;
                    for thisCol = 1:totalCols
                        emptyLine = [emptyLine, {' '}];
                    end

                    objectDataOut = [objectDataOut; [mainHeaderObjects thisChannelsHeader thisChannelsAroundHeader]; [objectDataOut2 objectDataAroundOut2]; emptyLine];
                else
                    [blah totalCols] = size(objectDataOut2);
                    for thisCol = 1:totalCols
                        emptyLine = [emptyLine, {' '}];
                    end
                    objectDataOut = [objectDataOut; [mainHeaderObjects thisChannelsHeader]; objectDataOut2; emptyLine];
                end

            %end

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
