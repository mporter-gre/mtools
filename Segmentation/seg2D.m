function [mask minValue] = seg2D(plane, featherSize, groupObjects, minSize)
%Pass in a 2D image (plane) and perform Otsu thresholding to segment out 
%the object. Pass it back as a binary mask.

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

patchSc = plane./max2(plane);
patch_01 = patchSc.*255;
imgThresh = otsu(patch_01)/255;
mask = im2bw(patchSc, imgThresh);

if groupObjects == 0
    mask = bwlabel(mask);
    %Exclude objects smaller than the minimum size.
    if minSize > 1
        exclusionList = [];
        regionProps = regionprops(mask, 'Area');
        numProps = length(regionProps);
        for thisProp = 1:numProps
            propArea = regionProps(thisProp).Area;
            if propArea < minSize
                exclusionList = [exclusionList thisProp];
            end
        end
        [loc1 loc2 maskVals] = find(mask);
        propValues = unique(maskVals);
        exclusionValues = propValues(exclusionList);
        numExclusions = length(exclusionList);
        for thisVal = 1:numExclusions
            exclusionIdx = find(mask == exclusionValues(thisVal));
            mask(exclusionIdx) = 0;
        end
    end
end

%Get the minimum value under the mask before feathering it out.
minValue = minUnderMask(plane, mask);

if featherSize > 0
    se = strel('disk', featherSize);
    mask = imdilate(mask, se);
end


end