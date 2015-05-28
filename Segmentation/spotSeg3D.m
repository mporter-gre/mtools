function segStack = spotSeg3D(stackIn)

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


[sizeY, sizeX, numZ] = size(stackIn);

for thisZ = 1:numZ
    otsuThresh(thisZ) = otsu(stackIn(:,:,thisZ));
end

otsuThresh = max(otsuThresh);
stackIn = double(stackIn);

%Find the mean + 2x standard deviations of pixels below otsuThresh
belowThresh = zeros(sizeY, sizeX, numZ);
belowThresh(stackIn<otsuThresh) = stackIn(stackIn<otsuThresh);
belowThresh = reshape(belowThresh, [], 1);
belowThresh(belowThresh==0) = [];
imageMax = max(max(max(stackIn)));
meanBelowThresh = mean(belowThresh);
stdBelowThresh = std(belowThresh);
%cannyThresh = (meanBelowThresh + (1*stdBelowThresh))/imageMax;
cannyThresh = meanBelowThresh/imageMax;

%Put the Z stack into a single plane for edge detection, apply a filter for
%the background and exaggerate the gradients
imPlane = [];
for thisZ = 1:numZ
    imPlane = [imPlane stackIn(:,:,thisZ)];
end
imPlane = medfilt2(imPlane);
imPlane = imPlane.^2;

%Perform edge detection
imPlaneFilt = medfilt2(imPlane);
imPlaneFilt = medfilt2(imPlaneFilt);
imPlaneEdge = edge(imPlaneFilt, 'canny', cannyThresh);

%Seal the gaps, fill the holes and remove non-blobs
se = strel('diamond', 1);
imPlaneEdgeDil = imdilate(imPlaneEdge, se);
imPlaneEdgeDilFill = imfill(imPlaneEdgeDil, 'holes');
imPlaneEdgeDilFillEr = imerode(imPlaneEdgeDilFill, se);
imPlaneEdgeDilFillErMaj = bwmorph(imPlaneEdgeDilFillEr, 'majority');

%Put the segmented stack back together
xStart = 1;
xEnd = sizeX;
for thisZ = 1:numZ
    segStack(:,:,thisZ) = imPlaneEdgeDilFillErMaj(:,xStart:xEnd);
    xStart = xStart + sizeX;
    xEnd = xEnd + sizeX;
end

segStack = bwlabeln(segStack);

