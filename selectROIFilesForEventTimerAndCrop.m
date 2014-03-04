function selectROIFilesForEventTimerAndCrop(credentials, conditions, handles)
%Events in a timelapse movie can be timed and output to an Excel
%spreadsheet, or a .csv file if Excel is not installed on the client
%machine. User will be asked to select ROI files that point to movies on an
%Omero server. Multiple ROIs can be timed from a single movie. New movies
%will be uploaded to the server, to the original dataset, containing
%intensity data for the regions marked by ROIs, and numbered according to
%the entries in the spreadsheet.
%
%Author Michael Porter

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

global remembered;
global scope;
remembered = 0;
scope = 0;

numConditions = length(conditions);
dataOut = {'Original Movie', 'Event Name' 'Condition', 'Time For Event (s)';};
paths = handles.conditionsPaths;
files = handles.conditionsFiles;

for thisCondition = 1:numConditions
    if scope ~= -1
        remembered = 0;
    end
    if iscell(files{thisCondition})
        numFiles{thisCondition} = length(files{thisCondition});
        for thisFile = 1:numFiles{thisCondition}
            [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile}] = eventTimerAndCrop(paths{thisCondition}, files{thisCondition}{thisFile}, credentials, thisFile, numFiles{thisCondition}, thisCondition, numConditions, handles);
            numROI = length(ROIIdx{thisCondition}{thisFile});
            for thisROI = 1:numROI
                dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{thisROI}.origName roishapeIdx{thisCondition}{thisFile}{thisROI}.name conditions{thisCondition} roishapeIdx{thisCondition}{thisFile}{thisROI}.deltaT}];
            end
        end
    else
        thisFile = 1;
        numFiles{thisCondition} = 1;
        [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile}] = eventTimerAndCrop(paths{thisCondition}, files{thisCondition}{thisFile}, credentials, thisFile, numFiles{thisCondition}, thisCondition, numConditions, handles);
        numROI = length(ROIIdx{thisCondition}{thisFile});
        for thisROI = 1:numROI
            dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{thisROI}.origName roishapeIdx{thisCondition}{thisFile}{thisROI}.name conditions{thisCondition} roishapeIdx{thisCondition}{thisFile}{thisROI}.deltaT}];
        end
    end
end

[saveFile savePath] = uiputfile('*.xls','Save Results',[handles.currDir, '/EventTimeResults.xls']);
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
