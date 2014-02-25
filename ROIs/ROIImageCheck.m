function [imageIdxNoROI roiShapes] = ROIImageCheck(imageIds, varargin)
%Collects ROIs for a vector of imageIds and returns indices of those
%without ROIs for removal from other lists. To filter for only specific
%types of ROI, list them in varargin. Choices are: 'line', 'ellipse',
%'rect' etc.

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

numImages = length(imageIds);
imageIdxNoROI = [];
for thisImage = 1:numImages
    imageId = imageIds(thisImage);
    ROIsThisImage = getROIsFromImageId(imageId);
    if ~isempty(varargin)
        numROIs = length(ROIsThisImage);
        if numROIs > 0
            ROIIdx = [];
            for thisROI = 1:numROIs
                shapeType = ROIsThisImage{thisROI}.shapeType;
                if ~strcmpi(shapeType, varargin)
                    ROIIdx = [ROIIdx thisROI];
                end
            end
            ROIsThisImage = deleteElementFromCells(ROIIdx, ROIsThisImage);
        end
    end
    roiShapes{thisImage} = ROIsThisImage;
    if isempty(roiShapes{thisImage});
        imageIdxNoROI = [imageIdxNoROI thisImage];
    end
end