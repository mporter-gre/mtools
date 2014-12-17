function newImage = createMaskImageFromROIPatches(masks, rois, imgSizeX, imgSizeY, imgSizeZ)


newImage = zeros(imgSizeX, imgSizeY, imgSizeZ);
numROIs = length(rois);

for thisROI = 1:numROIs
    
    [roiHeight, roiWidth, roiDepth] = size(masks{thisROI});
    
    roiX = ceil(rois{thisROI}.shape1.getX.getValue)+1;
    roiY = ceil(rois{thisROI}.shape1.getY.getValue)+1;
    roiZ = ceil(rois{thisROI}.shape1.getTheZ.getValue)+1;
    %roiT = rois{thisROI}.shape1.getTheT.getValue;
    
    newImage(roiY:roiY+roiHeight-1, roiX:roiX+roiWidth-1, roiZ:roiZ+roiDepth-1) = masks{thisROI};
    newImage = newImage .* 255;
end
    
