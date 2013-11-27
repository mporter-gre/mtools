function [imageIdxNoROI roiShapes] = ROIImageCheck(imageIds, varargin)
%Collects ROIs for a vector of imageIds and returns indices of those
%without ROIs for removal from other lists. To filter for only specific
%types of ROI, list them in varargin. Choices are: 'line', 'ellipse',
%'rect' etc.



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