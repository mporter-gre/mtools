function FRAPLaunchpad(handles, credentials)

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

[images imageIds imageNames roiShapes datasetNames pixels] = FRAPChooser;

if isempty(images)
    return;
end

numImages = length(imageIds);
progBar = waitbar(0, 'Analysing...');
for thisImage = 1:numImages
    [roiShapes{thisImage} indices{thisImage}] = FRAPMeasure(images.get(thisImage-1), imageIds(thisImage), imageNames{thisImage}, roiShapes{thisImage}, datasetNames{thisImage}, pixels{thisImage});
    waitbar(thisImage/numImages, progBar);
end
close(progBar);

writeDataOut(roiShapes, indices, datasetNames);
gatewayDisconnect


function writeDataOut(roiShapes, indices, datasetNames)

numImages = length(roiShapes);
dataOut = [];
dataSummary = {'File Name', 'Dataset', 'T1/2', 'Mobile Fraction', 'Immobile Fraction'};

for thisImage = 1:numImages
    dataOut = [dataOut; {[roiShapes{thisImage}{indices{thisImage}.frapIdx}.name, ' Frap analysis. T1/2 = ', num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.Thalf), 's, mobile fraction = ', num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.mobileFraction), ', immobile fraction = ', num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.immobileFraction)],'','','','','',''}];
    dataOut = [dataOut; {'File Name', 'Dataset', 'Timestamp', 'Frap Intensities', 'Base Intensities', 'Whole Intensities', 'Frap Normalised Corrected';}];
    for thisTimestamp = 1:length(roiShapes{thisImage}{indices{thisImage}.frapIdx}.correctT)
        dataOut = [dataOut; {roiShapes{thisImage}{indices{thisImage}.frapIdx}.name datasetNames{thisImage} num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.timestamp(thisTimestamp))} roiShapes{thisImage}{indices{thisImage}.frapIdx}.frapData(thisTimestamp) roiShapes{thisImage}{indices{thisImage}.baseIdx}.baseData(thisTimestamp) roiShapes{thisImage}{indices{thisImage}.wholeIdx}.wholeData(thisTimestamp) roiShapes{thisImage}{indices{thisImage}.frapIdx}.frapNormCorr(thisTimestamp)];
    end
    dataOut = [dataOut; {' ',' ',' ',' ',' ',' ',' '}];
    dataSummary = [dataSummary; {roiShapes{thisImage}{indices{thisImage}.frapIdx}.name, datasetNames{thisImage}, num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.Thalf), num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.mobileFraction), num2str(roiShapes{thisImage}{indices{thisImage}.frapIdx}.immobileFraction)}];
end



[saveFile savePath] = uiputfile('*.xls','Save Results','/FrapAnalysisResults.xls');

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
