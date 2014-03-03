function [img2PerCellProps, img1Bwl, img2Bwl] = bodyCount(img1, img2)
%For two channels in an image, bodyCount will get the objects in channel 2
%(img2) that lie in the regions defined in channel 1 (img1). For instance,
%speckles in img2 that lie withing the DNA staining of img1.
%Do [img2PerCellProps, img1Bwl, img2Bwl] = bodyCount(img1, img2);

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

%Remove the background from the reference object image, filter out the salt
%and pepper, find the edges and fill the holes in.
[imgWidth, imgHeight] = size(img1);
img1Bkg = lineProfileBkgImage(img1, 0.5);
img1BkgMedFilt = medfilt2(img1Bkg);
img1Edged = getImageEdges(img1BkgMedFilt, 15);
img1EdgedFilled = imfill(img1Edged, 'holes');

%Remove the background of image2
img2Bkg = lineProfileBkgImage(img2, 0.5);
img2Bwl = bwlabel(img2Bkg);

%Make labelled image and define the individual cells.
img1Bwl = bwlabel(img1EdgedFilled);
img1Props = regionprops(img1Bwl, 'BoundingBox', 'Area');
%img1Mask = double(zeros(imgWidth, imgHeight));

for thisCell = 1:length(img1Props)
    xStart = img1Props(thisCell).BoundingBox(1);
    yStart = img1Props(thisCell).BoundingBox(2);
    xEnd = xStart + img1Props(thisCell).BoundingBox(3);
    yEnd = yStart + img1Props(thisCell).BoundingBox(4);

    if xStart <= 1 || yStart <= 1 || xEnd >= imgWidth || yEnd >= imgHeight
        img1Bwl(find(img1Bwl==thisCell)) = 0;
    end
end

%reset the counter of the bwlabel image
img1Bwl = bwlabel(img1Bwl);

for thisCell = 1:max2(img1Bwl)
    img2PerCell = img2Bkg;
    img2PerCell(find(img1Bwl~=thisCell)) = 0;
    img2PerCellBwl = bwlabel(img2PerCell);
    cellTitle = ['Cell No. ', num2str(thisCell)];
    img2PerCellProps{thisCell}.Cell = cellTitle;
    img2PerCellProps{thisCell}.Props = regionprops(img2PerCellBwl, 'Area', 'BoundingBox');
    %img2PerCellProps{thisCell}.Props(3) = cellTitle;
end


end