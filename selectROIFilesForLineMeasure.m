function selectROIFilesForLineMeasure(credentials, conditions, handles)
%Events in a timelapse movie can be timed and output to an Excel
%spreadsheet, or a .csv file if Excel is not installed on the client
%machine. User will be asked to select ROI files that point to movies on an
%Omero server. Multiple ROIs can be timed from a single movie. New movies
%will be uploaded to the server, to the original dataset, containing
%intensity data for the regions marked by ROIs, and numbered according to
%the entries in the spreadsheet.
%
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

global remembered;
global scope;
remembered = 0;
scope = 0;

numConditions = length(conditions);
dataOut = {'Movie', 'Condition', 'Ref Line', 'Measure Line', 'Time Point', 'Angle', 'Length', 'Units';};
paths = handles.conditionsPaths;
files = handles.conditionsFiles;

for thisCondition = 1:numConditions
    if scope ~= -1
        remembered = 0;
    end
    if iscell(files{thisCondition})
        numFiles{thisCondition} = length(files{thisCondition});
        for thisFile = 1:numFiles{thisCondition}
            [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile} lineMeasurements{thisCondition}{thisFile}] = measureLines(paths{thisCondition}, files{thisCondition}{thisFile}, credentials, thisFile, numFiles{thisCondition}, thisCondition, numConditions, handles);
            numROI = length(lineMeasurements{thisCondition}{thisFile});
            for thisROI = 1:numROI
                for thisT = 1:length(lineMeasurements{thisCondition}{thisFile}{thisROI}.T)
                    dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{1}.imageName conditions{thisCondition} lineMeasurements{thisCondition}{thisFile}{thisROI}.refName  lineMeasurements{thisCondition}{thisFile}{thisROI}.lineName lineMeasurements{thisCondition}{thisFile}{thisROI}.T(thisT)+1 lineMeasurements{thisCondition}{thisFile}{thisROI}.RelativeAngle(thisT) lineMeasurements{thisCondition}{thisFile}{thisROI}.Length(thisT) lineMeasurements{thisCondition}{thisFile}{thisROI}.units}];
                end
            end
        end
    else
        thisFile = 1;
        numFiles{thisCondition} = 1;
        [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile} lineMeasurements{thisCondition}{thisFile}] = measureLines(paths{thisCondition}, files{thisCondition}{thisFile}, credentials, thisFile, numFiles{thisCondition}, thisCondition, numConditions, handles);
        numROI = length(lineMeasurements{thisCondition}{thisFile});
        for thisROI = 1:numROI
            for thisT = 1:length(lineMeasurements{thisCondition}{thisFile}{thisROI}.T)
                dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{1}.imageName conditions{thisCondition} lineMeasurements{thisCondition}{thisFile}{thisROI}.refName  lineMeasurements{thisCondition}{thisFile}{thisROI}.lineName lineMeasurements{thisCondition}{thisFile}{thisROI}.T(thisT)+1 lineMeasurements{thisCondition}{thisFile}{thisROI}.RelativeAngle(thisT) lineMeasurements{thisCondition}{thisFile}{thisROI}.Length(thisT) lineMeasurements{thisCondition}{thisFile}{thisROI}.units}];
            end
        end
    end
end

[saveFile savePath] = uiputfile('*.xls','Save Results',[handles.currDir, '/LineMeasureResults.xls']);
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