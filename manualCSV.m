function manualCSV(data, filePath, fileName)
%Matlab csvwrite doesn't handle strings, so if you need to have strings in
%your csv do manualCSV(data, filePath, fileName). 

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

%Ensure the .csv extension.
%[fileName remain] = strtok(fileName, '.');
filePathName = [filePath fileName '.csv'];

%Make sure the data are all strings.
[rows cols] = size(data);
for thisRow = 1:rows
    for thisCol = 1:cols
        if isnumeric(data{thisRow, thisCol})
            data{thisRow, thisCol} = num2str(data{thisRow, thisCol});
        end
    end
end

%Write out data to file
fid = fopen(filePathName, 'a');
for thisRow = 1:rows
    for thisCol = 1:cols
        fprintf(fid, '%s', data{thisRow, thisCol});
        fprintf(fid, '%s', ',');
    end
    fprintf(fid, '%s\n', '');
end
fclose(fid);
