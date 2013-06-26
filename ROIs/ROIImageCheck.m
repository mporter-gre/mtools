function [imageIdxNoROI roiShapes] = ROIImageCheck(imageIds)
%Collects ROIs for a vector of imageIds and returns indices of those
%without ROIs for removal from other lists.

numImages = length(imageIds);
imageIdxNoROI = [];
for thisImage = 1:numImages
    imageId = imageIds(thisImage);
    roiShapes{thisImage} = getROIsFromImageId(imageId);
    if isempty(roiShapes{thisImage});
        imageIdxNoROI = [imageIdxNoROI thisImage];
    end
end