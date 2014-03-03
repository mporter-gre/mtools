function maxProj
%Point to a folder to do maximum intensity projections of the images.

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

tic;
datadir = uigetdir;
cd(datadir);
mkdir projections
%filelist = dir;
platerow = ['A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'; 'I'; 'J'; 'K'; 'L'; 'M'; 'N'; 'O'; 'P'];
platerow = cellstr(platerow);
platecol = strvcat('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24');
platecol = cellstr(platecol);
field = ['fld 01 '; 'fld 02 '; 'fld 03 '; 'fld 04 '; 'fld 05 '; 'fld 06 '; 'fld 07 '; 'fld 08 '; 'fld 09 '; 'fld 10 '; 'fld 11 '; 'fld 12 '; 'fld 13 '; 'fld 14 '; 'fld 15 '; 'fld 16 '; 'fld 17 '; 'fld 18 '; 'fld 19 '; 'fld 20 '];
field = cellstr(field);
wave = strvcat('wv D360_40x - HQ460_40M ', 'wv HQ480_40x - HQ535_50M ', 'wv HQ565_30x - HQ620_60M ', 'wv HQ620_60x - HQ700_75M ');
wave = cellstr(wave);
zSection = ['z 1).tif'; 'z 2).tif'; 'z 3).tif'; 'z 4).tif'];
zSection = cellstr(zSection);

for currRow = 1:16
    for currCol = 1:24
        for currField = 1:10
           for currWave = 1:4
               
                imgProjection = zeros(520,696);
                
                filename1 = [platerow{currRow} ' - ' platecol{currCol} '(' field{currField} ' ' wave{currWave} ' ' zSection{1}];
                filename2 = [platerow{currRow} ' - ' platecol{currCol} '(' field{currField} ' ' wave{currWave} ' ' zSection{2}];
                filename3 = [platerow{currRow} ' - ' platecol{currCol} '(' field{currField} ' ' wave{currWave} ' ' zSection{3}];
                filename4 = [platerow{currRow} ' - ' platecol{currCol} '(' field{currField} ' ' wave{currWave} ' ' zSection{4}];
                
%                 filename1 = [platerow{currRow} ' - ' platecol{currCol} '(' field{currField} ' ' zSection{1}];
%                 filename2 = [platerow{currRow} ' - ' platecol{currCol} '(' field{currField} ' ' zSection{2}];
%                 filename3 = [platerow{currRow} ' - ' platecol{currCol} '(' field{currField} ' ' zSection{3}];
%                 filename4 = [platerow{currRow} ' - ' platecol{currCol} '(' field{currField} ' ' zSection{4}];
%                 
                try
                    pixfile1 = uint16(imread(filename1));
                    pixfile2 = uint16(imread(filename2));
                    pixfile3 = uint16(imread(filename3));
                    pixfile4 = uint16(imread(filename4));
                    
                catch 
                    continue;
                end
               
                
                for i = 1:520
                    for j = 1:696
                        comparevector = [pixfile1(i,j) pixfile2(i,j) pixfile3(i,j) pixfile4(i,j)];
                        imgProjection(i,j) = max(max(comparevector));
                    end
                end
                filenameout = ['projections/' platerow{currRow} ' - ' platecol{currCol} '(' field{currField} ' ' wave{currWave} ' Proj).tif'];
                %filenameout = [platerow{currRow} ' - ' platecol{currCol} '(' field{currField} ' Proj).tif']
                imgProjection = uint16(imgProjection);
                imwrite(imgProjection, filenameout, 'tif');
                
            end
        end
    end
    currRow
end
toc;
