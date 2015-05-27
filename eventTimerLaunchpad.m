function eventTimerLaunchpad(handles, credentials)
global progBar;
[images imageIds imageNames roiShapes datasetNames pixels channelLabels saveMasks frames] = eventTimer;
if isempty(images)
    return;
end

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
