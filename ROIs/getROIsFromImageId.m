function roiShapes = getROIsFromImageId(imageId)
%Fetch the ROIs associated with imageId and extract the shapes for each
%ROI. Label the ROI as being of type of shape1 'ellipse', 'rect' etc.
%roiShapes = getROIsFromImageId(imageId)

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

