function selectfilesForFLIPAnalysis(credentials, conditions, handles)
%Analyse batches of FLIP movies and save the data into an Excel
%spreadsheet, or .csv file if Excel is not installed on the client machine.
%User will be asked to point to ROI files that relate to the movies on the
%Omero server. 4 ROIs must be drawn and lebelled
%specifically: 'FLIP' is the spot that is measured; 'Ref' is the spot used
%to get the diffusing fraction; 'BASE' is the background outside the cell;
%'Constant' is a single ROI on a few non-bleached movies to calculate the
%relative bleaching due to acquisition.
%ROIs must be the same number of timepoints in length.
%
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

numConditions = length(conditions);
paths = handles.conditionsPaths;
files = handles.conditionsFiles;
constantFiles = handles.constantFiles;
constantPaths = handles.constantPaths;
[meanConstants, constantsShapeIdx] = getAquisitionBleachingConstant(constantFiles, constantPaths, credentials);

for thisCondition = 1:numConditions
    if iscell(files{thisCondition})
        numFiles(thisCondition) = length(files{thisCondition});
    else
        numFiles(thisCondition) = 1;
    end
    for thisFile = 1:numFiles(thisCondition)
        if iscell(files{thisCondition})
            [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile} indices{thisCondition}{thisFile}] = FLIPMeasure(paths{thisCondition}, files{thisCondition}{thisFile}, credentials, thisFile, numFiles(thisCondition), thisCondition, numConditions, meanConstants);
        else
            [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile} indices{thisCondition}{thisFile}] = FLIPMeasure(paths{thisCondition}, files{thisCondition}, credentials, thisFile, numFiles(thisCondition), thisCondition, numConditions, meanConstants);
        end
    end
end

%Find the maximum number of columns necessary for writing out the data.
maxCols = 0;
for thisCondition = 1:numConditions
    for thisFile = 1:numFiles(thisCondition)
        thisCol = length(indices{thisCondition}{thisFile}.flipIdx);
        if thisCol > maxCols
            maxCols = thisCol;
        end
    end
end

%Enforce equal number of time points for all ROIs of an image.
for thisCondition = 1:numConditions
    for thisFile = 1:numFiles(thisCondition)
        TFlip = [];
        TRef = roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.refIdx}.T;
        TBase = roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.baseIdx}.T;
        commonT = intersect(TRef, TBase);
        numFlipsThisFile = length(indices{thisCondition}{thisFile}.flipIdx)
        for thisFlip = 1:numFlipsThisFile
            TFlip = roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.flipIdx(thisFlip)}.T;
            commonT = intersect(commonT, TFlip);
        end
        roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.refIdx}.T = commonT;
        roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.baseIdx}.T = commonT;
        for thisFlip = 1:numFlipsThisFile
            roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.flipIdx(thisFlip)}.T = commonT;
        end
    end
end        

dataOut = [];
normDataOut = [];
for thisCondition = 1:numConditions
    for thisFile = 1:numFiles(thisCondition)
        if iscell(files{thisCondition})
            headerText = [roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.flipIdx(1)}.imageName, ' FLIP - ', conditions{thisCondition}];
        else
            headerText = [roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.flipIdx(1)}.imageName, ' FLIP - ', conditions{thisCondition}];
        end
        fileHeader = [headerText, {''}];
        dataByTimepoint = {'Base', 'Reference'};
        
        
        for thisFlip = 1:maxCols
            if thisFlip > length(indices{thisCondition}{thisFile}.flipIdx)
                fileHeader = [fileHeader, {''}];  %Add empty cells to pad to the same width as the data portion.
                dataByTimepoint = [dataByTimepoint, {''}];
            else
                fileHeader = [fileHeader, {''}];  %Add empty cells to pad to the same width as the data portion.
                dataByTimepoint = [dataByTimepoint roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.flipIdx(thisFlip)}.ROIName];
            end
        end
        lineByTimepoint = [];
        for thisT = 1:length(roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.flipIdx(1)}.T)
            lineByTimepoint = {roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.baseIdx}.baseData(thisT), roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.refIdx}.refData(thisT)};
            for thisFlip = 1:maxCols
                if thisFlip > length(indices{thisCondition}{thisFile}.flipIdx)
                    lineByTimepoint = [lineByTimepoint {''}];
                else
                    lineByTimepoint = [lineByTimepoint roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.flipIdx(thisFlip)}.flipData(thisT)];
                end
            end
            dataByTimepoint = [dataByTimepoint; lineByTimepoint];
        end
        emptyRow = {''};
        for thisCol = 1:maxCols+1
            emptyRow = [emptyRow, {''}];
        end
       
        dataByTimepoint = [dataByTimepoint; emptyRow];
        dataByTimepointWithHeader = [fileHeader; dataByTimepoint];
        dataOut = [dataOut; dataByTimepointWithHeader];

        if iscell(files{thisCondition})
            normHeaderText = [roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.flipIdx(1)}.imageName, ' FLIP - ', conditions{thisCondition}, ' Normalised and Corrected Data'];
        else
            normHeaderText = [roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.flipIdx(1)}.imageName, ' FLIP - ', conditions{thisCondition}, ' Normalised and Corrected Data'];
        end
        normFileHeader = normHeaderText;
        normDataByTimepoint = {'Reference'};
        flipCounter = 0;
        for thisFlip = 1:maxCols  %indices{thisCondition}{thisFile}.flipIdx
            flipCounter = flipCounter + 1;
            if thisFlip > length(indices{thisCondition}{thisFile}.flipIdx)
                normFileHeader = [normFileHeader, {''}];  %Add empty cells to pad to the same width as the data portion.
                normDataByTimepoint = [normDataByTimepoint, {''}];
            else
                normFileHeader = [normFileHeader, {''}];  %Add empty cells to pad to the same width as the data portion.
                normDataByTimepoint = [normDataByTimepoint, roishapeIdx{thisCondition}{thisFile}{thisFlip}.ROIName];
            end
        end
        normLineByTimepoint = [];
        for thisT = 1:length(roishapeIdx{thisCondition}{thisFile}{thisFlip}.T)
            normLineByTimepoint = {roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.refIdx}.flipBkgNormCorr(thisT)};
            flipCounter = 1;
            for thisFlip = 1:maxCols %indices{thisCondition}{thisFile}.flipIdx
                if flipCounter > length(indices{thisCondition}{thisFile}.flipIdx)
                    normLineByTimepoint = [normLineByTimepoint, {''}];
                else
                    normLineByTimepoint = [normLineByTimepoint roishapeIdx{thisCondition}{thisFile}{indices{thisCondition}{thisFile}.flipIdx(flipCounter)}.flipNormCorr(thisT)];
                    flipCounter = flipCounter +1;
                end
            end
            normDataByTimepoint = [normDataByTimepoint; normLineByTimepoint];
        end
        emptyRow = {''};
        for thisCol = 1:maxCols
            emptyRow = [emptyRow, {''}];
        end
        
        normDataByTimepoint = [normDataByTimepoint; emptyRow];
        normDataByTimepointWithHeader = [normFileHeader; normDataByTimepoint];
        normDataOut = [normDataOut; normDataByTimepointWithHeader];

    end
end

[saveFile savePath] = uiputfile('*.xls','Save Results',[handles.currDir, '/FlipAnalysisResults.xls']);
if isnumeric(saveFile) && isnumeric(savePath)
    return;
end

try
    xlswrite([savePath saveFile], dataOut, 'Data All Timepoints');
    xlswrite([savePath saveFile], normDataOut, 'Normalised Data All Timepoints');
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
    [rowsNorm colsNorm] = size(normDataOut);
    for thisRow = 1:rowsNorm
        for thisCol = 1:colsNorm
            if isnumeric(normDataOut{thisRow, thisCol})
                normDataOut{thisRow, thisCol} = num2str(normDataOut{thisRow, thisCol});
            end
        end
    end
    
    delete([savePath saveFile]); %Delete the .xls file and save again as .csv
    [savePart remain] = strtok(saveFile, '.');
    saveFile = [savePart '.csv'];
    saveFileNorm = [savePart 'Normalised.csv'];
    
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
    
    %Write out normDataOut to file
    fid = fopen([savePath saveFileNorm], 'w');
    for thisRow = 1:rowsNorm
        for thisCol = 1:colsNorm
            fprintf(fid, '%s', normDataOut{thisRow, thisCol});
            fprintf(fid, '%s', ',');
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);

end


end