function roiShapes = getROIsFromImageId(imageId)
%Fetch the ROIs associated with imageId and extract the shapes for each
%ROI. Label the ROI as being of type of shape1 'ellipse', 'rect' etc.
%roiShapes = getROIsFromImageId(imageId)

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

global session
global roiService

if ~isjava(roiService)
    roiService = session.getRoiService;
end

roiResult = roiService.findByImage(imageId, []);
rois = roiResult.rois;
numROIs = rois.size;
if numROIs == 0
    %disp('No rois for the image');
    roiShapes = [];
    return;
end

for thisROI  = 1:numROIs
    roi{thisROI} = rois.get(thisROI-1);
    numShapes = roi{thisROI}.sizeOfShapes;
    counter = 1;
    for thisShape = 1:numShapes
        if isempty(roi{thisROI}.getShape(thisShape-1))
            continue;
        end
        roiShapes{thisROI}.(['shape' num2str(counter)]) = roi{thisROI}.getShape(thisShape-1);
        counter = counter + 1;
    end
    roiShapes{thisROI}.shapeType = getShapeType(roiShapes{thisROI}.shape1);
    roiShapes{thisROI}.ROIId = roi{thisROI}.getId.getValue;
    roiShapes{thisROI}.numShapes = counter -1;
end

