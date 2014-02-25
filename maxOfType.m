function maxVal = maxOfType(pixels)
%Gets the pixels type and returns the maximum value allowed of that type.
%Do maxVal = maxOfType(pixels)

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

if strcmp(class(pixels), 'java.util.ArrayList');
    pixels = pixels.get(0);
end

pixType = char(pixels.getPixelsType.getValue.getValue);

switch pixType
    case 'int8'
        maxVal =  128; 
    case 'uint8'
        maxVal =  256;
    case 'int16'
        maxVal =  32768;
    case 'uint16'
        maxVal =  65536;
    case 'int32'
        maxVal =  2147500000;
    case 'uint32'
        maxVal = 429500000;
    case 'int64'
        maxVal = 9223400000000000000;
    case 'uint64'
        maxVal = 18447000000000000000;
    case 'single'
        maxVal = 3.4028e+038;
    case 'float'
        maxVal = 3.4028e+038;
    case 'double'
        maxVal = 1.7977e+308;
    case 'logical'
        maxVal = 1;
end
