function maskStack = blobDetect(stackIn)

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

[~, sizeX, numZ] = size(stackIn);

stackIn = double(stackIn);

%Put the Z stack into a single plane for processing, apply a filter for
%the background and exaggerate the gradients
imPlane = [];
for thisZ = 1:numZ
    imPlane = [imPlane stackIn(:,:,thisZ)];
end
%imPlane = medfilt2(imPlane);
%imPlane = imPlane.^2;

%imPlaneFilt = medfilt2(imPlane);

%Make a LoG filter and convolve with the image, preserving dimensions
logFilter = fspecial('disk', 3);
imPlaneFiltConv = conv2(imPlane, logFilter, 'same');

%Put the stack back together for seg3D
xStart = 1;
xEnd = sizeX;
for thisZ = 1:numZ
    planeFiltConvStack(:,:,thisZ) = imPlaneFiltConv(:,xStart:xEnd);
    xStart = xStart + sizeX;
    xEnd = xEnd + sizeX;
end

[maskStack, ~] = seg3D(planeFiltConvStack, 0, 0, 0);