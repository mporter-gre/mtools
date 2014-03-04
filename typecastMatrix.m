function matrixOut = typecastMatrix(matrixIn, typeString)
%int8, uint8, int16, uint16, int32, uint32, int64, uint64, single, double,
%logical

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

switch typeString
    case 'int8'
        matrixOut = typecast(matrixIn, 'int8');    
    case 'uint8'
        matrixOut = typecast(matrixIn, 'uint8');
    case 'int16'
        matrixOut = typecast(matrixIn, 'int16');
    case 'uint16'
        matrixOut = typecast(matrixIn, 'uint16');
    case 'int32'
        matrixOut = typecast(matrixIn, 'int32');
    case 'uint32'
        matrixOut = typecast(matrixIn, 'uint32');
    case 'int64'
        matrixOut = typecast(matrixIn, 'int64');
    case 'uint64'
        matrixOut = typecast(matrixIn, 'uint64');
    case 'single'
        matrixOut = typecast(matrixIn, 'Single');
    case 'float'
        matrixOut = typecast(matrixIn, 'Single');
    case 'double'
        matrixOut = typecast(matrixIn, 'Double');
    case 'logical'
        matrixOut = typecast(matrixIn, 'logical');     
end


clear matrixIn;
