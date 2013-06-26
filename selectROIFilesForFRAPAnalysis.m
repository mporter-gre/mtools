function selectROIFilesForFRAPAnalysis(credentials, conditions, handles)
%Analyse batches of FRAP movies and save the data into an Excel
%spreadsheet, or .csv file if Excel is not installed on the client machine.
%User will be asked to point to ROI files that relate to the movies on the
%Omero server. 4 ROIs must be drawn for each movie and lebelled
%specifically: 'FRAP' is the spot that is bleached; 'WHOLE' is the whole
%cell; 'REF' is another spot that you would like to measure - this is not
%used for the analysis; 'BASE' is the background outside the cell. All 4
%ROIs must be the same number of timepoints in length.
%
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved


numConditions = length(conditions);
paths = handles.conditionsPaths;
files = handles.conditionsFiles;

dataOut = [];
dataSummary = {'File Name', 'Condition', 'T1/2', 'Mobile Fraction', 'Immobile Fraction'};

for thisCondition = 1:numConditions
    if iscell(files{thisCondition})
        numFiles{thisCondition} = length(files{thisCondition});
        for thisFile = 1:numFiles{thisCondition}
            [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile} indices] = FRAPMeasure(paths{thisCondition}, files{thisCondition}{thisFile}, credentials, thisFile, numFiles{thisCondition}, thisCondition, numConditions);
            dataOut = [dataOut; {[roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.name, ' Frap analysis. T1/2 = ', num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.Thalf), 's, mobile fraction = ', num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.mobileFraction), ', immobile fraction = ', num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.immobileFraction)],'','','','','','',''}];
            dataOut = [dataOut; {'File Name', 'Condition', 'Timestamp', 'Frap Intensities' 'Ref Intensities', 'Base Intensities', 'Whole Intensities', 'Frap Normalised Corrected';}];
            for thisTimestamp = 1:length(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.correctT)
                dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.name conditions{thisCondition} num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.timestamp(thisTimestamp))} roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.frapData(thisTimestamp) roishapeIdx{thisCondition}{thisFile}{indices.refIdx}.refData(thisTimestamp) roishapeIdx{thisCondition}{thisFile}{indices.baseIdx}.baseData(thisTimestamp) roishapeIdx{thisCondition}{thisFile}{indices.wholeIdx}.wholeData(thisTimestamp) roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.frapNormCorr(thisTimestamp)];
            end
            dataOut = [dataOut; {' ',' ',' ',' ',' ',' ',' ',' '}];
            dataSummary = [dataSummary; {roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.name, conditions{thisCondition}, num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.Thalf), num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.mobileFraction), num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.immobileFraction)}];
        end
    else
        thisFile = 1;
        numFiles{thisCondition} = 1;
        [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile} indices] = FRAPMeasure(paths{thisCondition}, files{thisCondition}, credentials, thisFile, numFiles{thisCondition}, thisCondition, numConditions);
        dataOut = [dataOut; {[roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.name, ' Frap analysis. T1/2 = ', num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.Thalf), 's, mobile fraction = ', num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.mobileFraction), ', immobile fraction = ', num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.immobileFraction)],'','','','','','',''}];
        dataOut = [dataOut; {'File Name', 'Condition', 'Timestamp', 'Frap Intensities' 'Ref Intensities', 'Base Intensities', 'Whole Intensities', 'Frap Normalised Corrected';}];
        for thisTimestamp = 1:length(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.correctT)
            dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.name conditions{thisCondition} num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.timestamp(thisTimestamp))} roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.frapData(thisTimestamp) roishapeIdx{thisCondition}{thisFile}{indices.refIdx}.refData(thisTimestamp) roishapeIdx{thisCondition}{thisFile}{indices.baseIdx}.baseData(thisTimestamp) roishapeIdx{thisCondition}{thisFile}{indices.wholeIdx}.wholeData(thisTimestamp) roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.frapNormCorr(thisTimestamp)];
        end
        dataOut = [dataOut; {' ',' ',' ',' ',' ',' ',' ',' '}];
        dataSummary = [dataSummary; {roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.name, conditions{thisCondition}, num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.Thalf), num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.mobileFraction), num2str(roishapeIdx{thisCondition}{thisFile}{indices.frapIdx}.immobileFraction)}];
    end
end

[saveFile savePath] = uiputfile('*.xls','Save Results',[handles.currDir, '/FrapAnalysisResults.xls']);

if isnumeric(saveFile) && isnumeric(savePath)
    return;
end

try
    xlswrite([savePath saveFile], dataOut, 'Data All Timepoints');
    xlswrite([savePath saveFile], dataSummary, 'Data Summary');
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
    [rowsSummary colsSummary] = size(dataSummary);
    for thisRow = 1:rowsSummary
        for thisCol = 1:colsSummary
            if isnumeric(dataSummary{thisRow, thisCol})
                dataSummary{thisRow, thisCol} = num2str(dataSummary{thisRow, thisCol});
            end
        end
    end
    
    delete([savePath saveFile]); %Delete the .xls file and save again as .csv
    [savePart remain] = strtok(saveFile, '.');
    saveFile = [savePart '.csv'];
    saveFileSummary = [savePart 'Summary.csv'];
    
    %Write out DataOut to file
    fid = fopen([savePath saveFile], 'w');
    for thisRow = 1:rows
        for thisCol = 1:cols
            fprintf(fid, '%s', dataOut{thisRow, thisCol});
            fprintf(fid, '%s', ',');
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);
    
    %Write out dataSummary to file
    fid = fopen([savePath saveFileSummary], 'w');
    for thisRow = 1:rowsSummary
        for thisCol = 1:colsSummary
            fprintf(fid, '%s', dataSummary{thisRow, thisCol});
            fprintf(fid, '%s', ',');
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);

end

end