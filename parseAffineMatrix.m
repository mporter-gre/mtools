function affineMatrix = parseAffineMatrix(transform)

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

closeBracket = strfind(transform, ')');
openBracket = strfind(transform, '(');
transformData = transform(openBracket+1:closeBracket-1);
spaceChars = strfind(transformData, ' ');
firstPart = str2double(transformData(1:spaceChars(1)-1));
secondPart = str2double(transformData(spaceChars(1)+1:spaceChars(2)-1));
thirdPart = str2double(transformData(spaceChars(2)+1:spaceChars(3)-1));
fourthPart = str2double(transformData(spaceChars(3)+1:spaceChars(4)-1));
fifthPart = str2double(transformData(spaceChars(4)+1:spaceChars(5)-1));
sixthPart = str2double(transformData(spaceChars(5)+1:end));

affineMatrix = [firstPart thirdPart fifthPart; secondPart fourthPart sixthPart; 0 0 1];
