function [signalStart extent] = zExtent(segStack, pixels)

% if isjava(pixels)
%     pixels = pixels.get(0);
% end

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

[numY numX numZ] = size(segStack);
%numX = pixels.getSizeX.getValue;
%numY = pixels.getSizeY.getValue;

extent = zeros(numY, numX);
signalStart = zeros(numY, numX);
for thisX = 1:numX
    for thisY = 1:numY
        stopState = 0;
        for thisZ = 1:numZ
            if segStack(thisY, thisX, thisZ) == 1
                if stopState == 0
                    signalStart(thisY, thisX) = thisZ;
                end
                stopState = 1;
            end
            if segStack(thisY, thisX, thisZ) == 0 && stopState == 1
                extent(thisY, thisX) = thisZ-1;
                break;
            end
            if thisZ == numZ && stopState == 1 && extent(thisY, thisX) > 0
                extent(thisY, thisX) = thisZ;
            end
        end
    end
end
