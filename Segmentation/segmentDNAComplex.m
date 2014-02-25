function [outputImage, edgedImage, restImage]  = segmentDNAComplex(image)
%This is designed to segment areas of DNA from 40x images. If needed the
%value at the end of the 'edgedImage' line can be altered - this will
%change the size of the window used to search for edges. It will also
%change the thickness of the line drawn around the objects.
%Do outputImage = segmentDNA(image)
%Do [outputImage, edgedImage, restImage] = segmentDNA(image) and alter here
%if troubleshooting.

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

%measure the image background.
bkg = 21; %otsu(image)/6;
%image(find(image<bkg)) = 6000;

%Find the edged of the DNA objects.
%image = imclearborder(image);
edgedImage = getImageEdges(image,3);
edgedImage2 = getImageEdges(image,5);
[x, y] = size(image);
for i = 1:x
    for j = 1:y
        if edgedImage2(i,j) == 1
            edgedImage(i,j) = 1;
        end
    end
end

%Filter out any noise by using a 10 pixel line as a guide object (unlikely
%noise will contain this). Then restore the DNA objects from the eroded
%image.
seLine = strel('line',20,0);
% seSlash = strel('line',10,45);
% sePipe = strel('line',10,90);
% seBackslash = strel('line',10,135);
seDisk = strel('disk',1);
seDisk2 = strel('disk', 2);
mask = imerode(edgedImage, seLine);
% mask2 = imerode(edgedImage, seSlash);
% mask3 = imerode(edgedImage, sePipe);
% mask4 = imerode(edgedImage, seBackslash);
% mask = logical(mask1 + mask2 + mask3 + mask4);
restImage = imreconstruct(mask, edgedImage);

%Use regionprops to deal with one object at a time. Use the ConvexImage to
%get a closed object, since some edges will not be closed. Thin away to get
%rid of the excess Convex Hull, add back the outline, then fill in the
%gaps. Finally do a manual labelling from 1 to 256.
restBWL = bwlabel(restImage);
restProps = regionprops(restBWL,'Image', 'ConvexImage', 'BoundingBox');
for i = 1:length(restProps)
    
    restImageDil = imdilate(restProps(i).Image, seDisk);
    imageDiff = restProps(i).ConvexImage - restImageDil;
    imageDiffOpenFirst = imopen(imageDiff, seDisk2);
    imageDiffOpen = double(bwareaopen(imageDiffOpenFirst, 10));
    
    imageDiffOpenBWL = bwlabel(imageDiffOpen);
    imageDiffOpenProps = regionprops(imageDiffOpenBWL, 'Centroid');
    numObjects = length(imageDiffOpenProps);
    if numObjects > 1
        loc = [];
        [loc(1,2), loc(1,1)] = size(imageDiffOpenBWL);
        loc = loc./2;
        for thisObject = 1:length(imageDiffOpenProps)
            loc(2,1) = imageDiffOpenProps(thisObject).Centroid(1);
            loc(2,2) = imageDiffOpenProps(thisObject).Centroid(2);
            distance(thisObject) = pdist(loc, 'euclidean');
        end
        [smallest, idx] = min(distance);
        distance = [];
        imageDiffOpenBWL(find(imageDiffOpenBWL~=idx)) = 0;
        imageDiffOpenBWL = logical(imageDiffOpenBWL);
    end
    restProps(i).ConvexImage = imadd(logical(imageDiffOpenBWL), logical(restProps(i).Image));
    restProps(i).ConvexImage = imfill(restProps(i).ConvexImage, 'holes');
     [ulY, ulX] = size(restProps(i).ConvexImage);
     widthX = floor(restProps(i).BoundingBox(3))-1;
     widthY = floor(restProps(i).BoundingBox(4))-1;
     
     intensityPatch = image(ulY:ulY+widthY, ulX:ulX+widthX);
     intensityPatch(find(intensityPatch<bkg)) = 0;

    restProps(i).ConvexImage(find(intensityPatch==0)) = 0;
    restProps(i).ConvexImage = imfill(restProps(i).ConvexImage, 'holes');
    
    [regionHeight, regionWidth] = size(restProps(i).ConvexImage);
    if regionHeight >90 || regionWidth > 90
        distanceRegion = bwdist(~restProps(i).ConvexImage, 'chessboard');
        distanceRegion = -distanceRegion;
        distanceRegion(~restProps(i).ConvexImage) = -Inf;
        waterRegion = watershed(distanceRegion);
        waterRegion(~restProps(i).ConvexImage) = 0;
        
        seDisk3 = strel('disk', 3);
        regionOpen = imopen(waterRegion, seDisk3);
        %regionOpenBWL = bwlabel(regionOpen);
        %regionOpenBWL(~restProps(i).Image) = 0;
        
        restProps(i).ConvexImage = logical(regionOpen);
    end
    
    restProps(i).ConvexImage = double(restProps(i).ConvexImage);
    
end

%Finally recreate the full image from these little patches.
convexImage = zeros(x,y);

for cell = 1:length(restProps)
    for row = 1:restProps(cell).BoundingBox(4)
        for col = 1:restProps(cell).BoundingBox(3)
            if restProps(cell).ConvexImage(row, col) > 0
                convexImage(floor(restProps(cell).BoundingBox(2))+row, floor(restProps(cell).BoundingBox(1))+col) = restProps(cell).ConvexImage(row, col);
            end
        end
    end
end
seDisk5 = strel('disk', 6);
remSmall = imopen(convexImage, seDisk5);
reconstructDNA = imreconstruct(remSmall, convexImage);
outputImage = bwlabel(reconstructDNA);


% restImageDil = imdilate(restImage, seDisk);
% imageDiff = convexImage;
% imageDiff(find(double(restImageDil))) = 0;
%imageDiffMajority = bwmorph(imageDiff, 'majority');
% outputImage = bwareaopen(imageDiff, 50);
%outputImage = convexImage;

end