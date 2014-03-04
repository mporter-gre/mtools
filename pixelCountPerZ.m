function [greenPos redPos greenStartZ] = pixelCountPerZ(greenSegStack, redSegStack, numROIZ)

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

greenStart = 0;
greenPos = zeros(numROIZ,1);
redPos = zeros(numROIZ,1);
for thisROIZ = 1:numROIZ
    greenThisZLinear = reshape(greenSegStack(:,:,thisROIZ), [], 1);
    greenPos(thisROIZ) = sum(greenThisZLinear);
    if greenStart == 0
        if greenPos(thisROIZ) > 0
            greenStart = 1;
            greenStartZ = thisROIZ;
        end
    end
    redThisZLinear = reshape(redSegStack(:,:,thisROIZ), [], 1);
    redPos(thisROIZ) = sum(redThisZLinear);
end

