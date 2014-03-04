function matrixOut = setMatrixType(matrixIn, typeString)
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
        matrixOut = int8(matrixIn);    
    case 'uint8'
        matrixOut = uint8(matrixIn);
    case 'int16'
        matrixOut = int16(matrixIn);
    case 'uint16'
        matrixOut = uint16(matrixIn);
    case 'int32'
        matrixOut = int32(matrixIn);
    case 'uint32'
        matrixOut = uint32(matrixIn);
    case 'int64'
        matrixOut = int64(matrixIn);
    case 'uint64'
        matrixOut = uint64(matrixIn);
    case 'single'
        matrixOut = single(matrixIn);
    case 'float'
        matrixOut = single(matrixIn);
    case 'double'
        matrixOut = double(matrixIn);
    case 'logical'
        matrixOut = logical(matrixIn);     
end


clear matrixIn;
