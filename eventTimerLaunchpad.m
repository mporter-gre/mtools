function eventTimerLaunchpad(handles, ids)
global progBar;
[images imageIds imageNames roiShapes datasetNames pixels channelLabels saveMasks frames] = eventTimer(ids);

numImages = length(imageIds);
for thisImage = 1:numImages
    if saveMasks == 1
        progBar = waitbar(0, ['Uploading mask for image ' num2str(thisImage)]);
    end
    [roiShapes{thisImage}] = eventTimerAndCrop(images.get(thisImage-1), imageIds(thisImage), imageNames{thisImage}, roiShapes{thisImage}, pixels{thisImage}, frames, channelLabels{thisImage}, saveMasks);
    close(progBar);
end
writeDataOut(roiShapes, datasetNames)



function writeDataOut(roiShapes, datasetNames)


mainHeader = {'Original Image', 'Mask Image', 'Dataset', 'ROI', 'Event Duration'};
dataOut = {'Original Image', 'Mask Image', 'Dataset', 'ROI', 'Event Duration'};

%Create the data structure for writing out to .xls
numImages = length(datasetNames);
for thisImage = 1:numImages
    %dataOut = [dataOut; {mainHeader}];
    numROI = length(roiShapes{thisImage});
    for thisROI = 1:numROI
       dataOut = [dataOut; {roiShapes{thisImage}{thisROI}.origName roiShapes{thisImage}{thisROI}.name datasetNames{thisImage} num2str(thisROI) roiShapes{thisImage}{thisROI}.deltaT}];
    end
    dataOut = [dataOut; {' ' ' ' ' ' ' ' ' '}];
end

[saveFile savePath] = uiputfile('*.xls','Save Results','/EventTimes.xls');
if isnumeric(saveFile) && isnumeric(savePath)
    return;
end

try
    xlswrite([savePath saveFile], dataOut, 'Event Times');
catch
    %If the xlswriter fails (no MSOffice installed, e.g.) then manually
    %create a .csv file. Turn every cell to string to make it easier. 
    [rows cols] = size(dataOut);
    for thisRow = 1:rows
        for thisCol = 1:cols
            if isnumeric(dataOut{thisRow, thisCol})
                dataOut{thisRow, thisCol} = num2str(dataOut{thisRow, thisCol});
            end
        end
    end
    delete([savePath saveFile]); %Delete the .xls file and save again as .csv
    dotIdx = findstr(saveFile, '.');
    newSaveFile = saveFile(1:dotIdx(end));
    newSaveFile = [newSaveFile 'csv'];
    fid = fopen([savePath newSaveFile], 'w');
    for thisRow = 1:rows
        for thisCol = 1:cols
            fprintf(fid, '%s', dataOut{thisRow, thisCol});
            fprintf(fid, '%s', ',');
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);
end