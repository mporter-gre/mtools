function selectROIFilesForDistanceMeasure(credentials, conditions, handles)
%Measure distances between objects in 2D/3D. User selects ROI files
%containing rectangular ROIs containing the objects intended for
%segmentation. For each ROI a projection of the relevant Zs is displayed
%and user selects channel(s) to display segmented. User can scroll through
%Z to see all of the objects for that channel, and clicks on the two
%objects they want to know the distance between. If metadata exists in the
%DB the results are expressed in microns, otherwise pixels are used.
%Results are saved in an Excel spreadsheet, or a .csv file if Excel is not
%found.
%
%
%Author Michael Porter m.porter@dundee.ac.uk
%Copyright 2009 University of Dundee. All rights reserved

numConditions = length(conditions);

paths = handles.conditionsPaths;
files = handles.conditionsFiles;

for thisCondition = 1:numConditions
    if iscell(files{thisCondition})
        numFiles = length(files{thisCondition});
        for thisFile = 1:numFiles
            [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile} badImage badCredentials data{thisCondition}{thisFile}] = distanceMeasure(paths{thisCondition}, files{thisCondition}{thisFile}, credentials, thisFile, numFiles, thisCondition, numConditions, handles);
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
        [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile} badImage, badCredentials, measureSegChannel, data{thisCondition}{thisFile}] = distanceMeasure(paths{thisCondition}, files{thisCondition}{thisFile}, credentials, thisFile, numFiles{thisCondition}, thisCondition, numConditions, handles);
        if badImage == 0
            numROI = length(ROIIdx{thisCondition}{thisFile}{1});
        else
            %dataOut = [dataOut; {paths{thisCondition}, files{thisCondition}{thisFile}, 'Bad image or ROI file', '', '', ''}];
            continue;
        end
    end
end

mainHeader = {'Original Image', 'Condition', 'ROI number', 'Object 1 Channel', 'Object 2 Channel', 'Centroid 1 (x,y,z)', 'Centroid 2 (x,y,z)', 'Distance', 'Units'};
emptyLine = {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '};
dataOut = mainHeader;

%Create the data structure for writing out to .xls
for thisCondition = 1:numConditions
    numFiles = length(ROIIdx{thisCondition});
    for thisFile = 1:numFiles
        if iscell(files{thisCondition})
            %numFiles{thisCondition} = length(files{thisCondition});
            for thisFile = 1:numFiles
                numROI = length(ROIIdx{thisCondition}{thisFile});
                for thisROI = 1:numROI
                    dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{thisROI}.origName conditions{thisCondition} num2str(thisROI) data{thisCondition}{thisFile}{thisROI}{1}{1} data{thisCondition}{thisFile}{thisROI}{2}{1} num2str(data{thisCondition}{thisFile}{thisROI}{7}.Centroid) num2str(data{thisCondition}{thisFile}{thisROI}{8}.Centroid) data{thisCondition}{thisFile}{thisROI}{9}} data{thisCondition}{thisFile}{thisROI}{10}];
                end
            end
        else
            thisFile = 1;
            numROI = length(ROIIdx{thisCondition}{thisFile});
            for thisROI = 1:numROI
                dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{thisROI}.origName conditions{thisCondition} num2str(thisROI) data{thisCondition}{thisFile}{1} data{thisCondition}{thisFile}{2} data{thisCondition}{thisFile}{7} data{thisCondition}{thisFile}{8} data{thisCondition}{thisFile}{9}} data{thisCondition}{thisFile}{10}];
            end
        end
    end
end



[saveFile savePath] = uiputfile('*.xls','Save Results',[handles.currDir, '/DistanceMeasurements.xls']);
if isnumeric(saveFile) && isnumeric(savePath)
    return;
end

try
    xlswrite([savePath saveFile], dataOut);
catch
    %If the xlswriter fails (no MSOffice installed, e.g.) then manually
    %create a .csv file. Turn every cell to string to make it easier.
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
    saveFile = [savePart '.csv'];
    fid = fopen([savePath saveFile], 'w');
    for thisRow = 1:rows
        for thisCol = 1:cols
            fprintf(fid, '%s', dataOut{thisRow, thisCol});
            fprintf(fid, '%s', ',');
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);
end
end