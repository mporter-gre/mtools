function YuabExtentAnalysis(parentHandles, parentFigureName)


imageIds = getappdata(parentHandles.(parentFigureName), 'imageIds');
imageNames = getappdata(parentHandles.(parentFigureName), 'imageNames');
roiShapes = getappdata(parentHandles.(parentFigureName), 'roiShapes');
channelLabels = getappdata(parentHandles.(parentFigureName), 'channelLabels');
pixels = getappdata(parentHandles.(parentFigureName), 'pixels');
datasetNames = getappdata(parentHandles.(parentFigureName), 'datasetNames');

numImages = length(imageIds);

progress = waitbar(0,'Analysing image...');

for thisImage = 1:numImages
    waitbar(thisImage/numImages, progress, ['Downloading image... ' num2str(thisImage) ' of ' num2str(numImages)])
    thisPixels = pixels{thisImage};
    numX = thisPixels.getSizeX.getValue;
    numY = thisPixels.getSizeY.getValue;
    numShapes = roiShapes{thisImage}{1}.numShapes;
    zStart = roiShapes{thisImage}{1}.shape1.getTheZ.getValue;
    zEnd = roiShapes{thisImage}{1}.(['shape' num2str(numShapes)]).getTheZ.getValue;
    ROIZ = (zStart:zEnd);
    numROIZ = length(ROIZ);
    
    %Get the green image data from the ROI z-sections...
    greenStack = zeros(numY, numX, numROIZ);
    for thisZ = 1:numROIZ
        greenStack(:,:,thisZ) = getPlaneFromPixelsId(thisPixels.getId.getValue, ROIZ(thisZ), 0, 0);
    end
    
    %Now segment the cells...
    greenSeg = seg3D(greenStack, 0, 1, 50);
    %[greenSignalStart greenExtent] = zExtent(greenSeg, thisPixels);
    
    %Get the red image data from the ROI z-sections...
    redStack = zeros(numY, numX, numROIZ);
    for thisZ = 1:numROIZ
        redStack(:,:,thisZ) = getPlaneFromPixelsId(thisPixels.getId.getValue, ROIZ(thisZ), 1, 0);
    end
    
    %Now segment the YuaB staining...
    waitbar(thisImage/numImages, progress, ['Analysing image... ' num2str(thisImage) ' of ' num2str(numImages)])
    redSeg = seg3D(redStack, 0, 1, 50);
    %[redSignalStart redExtent] = zExtent(redSeg, thisPixels);
    
    
%     %Find the pixel-stacks the don't have YuaB or cells...
%     NaNCheck = ones(numY, numX);
%     NaNCheck(redSignalStart==0 & greenSignalStart == 0) = nan;
%     greenSignalStart = greenSignalStart .* NaNCheck;
%     greenExtent = greenExtent .* NaNCheck;
%     redSignalStart = redSignalStart .* NaNCheck;
%     redExtent = redExtent .* NaNCheck;
%     
%     greenSignalStartMean(thisImage) = nanmean(reshape(greenSignalStart, [], 1));
%     greenSignalStartStd(thisImage) = nanstd(reshape(greenSignalStart, [], 1));
%     greenExtentMean(thisImage) = nanmean(reshape(greenExtent, [], 1));
%     greenExtentStd(thisImage) = nanstd(reshape(greenExtent, [], 1));
%     
%     redSignalStartMean(thisImage) = nanmean(reshape(redSignalStart, [], 1));
%     redSignalStartStd(thisImage) = nanstd(reshape(redSignalStart, [], 1));
%     redExtentMean(thisImage) = nanmean(reshape(redExtent, [], 1));
%     redExtentStd(thisImage) = nanstd(reshape(redExtent, [], 1));


    %Count the positive pixels per Z in each stack...
    [greenPos{thisImage} redPos{thisImage} greenStartZ(thisImage)] = pixelCountPerZ(greenSeg, redSeg, numROIZ);
    maxROIZ(thisImage) = numROIZ;
    [val idx] = max(redPos{thisImage});
%     redIntensity = redStack(:,:,idx);
%     redSeg1Z = redSeg(:,:,idx);
    redIntensity = redStack(:,:,greenStartZ(thisImage));
    redSeg1Z = redSeg(:,:,greenStartZ(thisImage));
    redIntensityLinear = redIntensity(redSeg1Z == 1);
    redIntensitySummary{thisImage,1} = imageIds(thisImage);
    redIntensitySummary{thisImage,2} = mean(redIntensityLinear);
    redIntensitySummary{thisImage,3} = std(redIntensityLinear);
    redIntensitySummary{thisImage,4} = length(redIntensityLinear);
    redIntensitySummary{thisImage,5} = idx;
    redIntensitySummary{thisImage,6} = datasetNames{thisImage};
end

maxGreenStartZ = max(greenStartZ);
minGreenStartZ = min(greenStartZ);
maxROIZ = max(maxROIZ);
maxPosSize = maxROIZ - minGreenStartZ + 1;
maxNegSize = maxGreenStartZ -1;
greenPosMatrix = zeros(maxPosSize, numImages+1);
greenPosMatrix(:,:) = nan;
redPosMatrix = zeros(maxPosSize, numImages+1);
redPosMatrix(:,:) = nan;
greenNegMatrix = zeros(maxNegSize, numImages+1);
greenNegMatrix(:,:) = nan;
redNegMatrix = zeros(maxNegSize, numImages+1);
redNegMatrix(:,:) = nan;

for thisImage = 1:numImages
    posCounter = 1;
    [posSizeThisImage ~] = size(greenPos{thisImage});
    for thisPos = greenStartZ(thisImage):posSizeThisImage
        greenPosMatrix(posCounter, thisImage+1) = greenPos{thisImage}(thisPos);
        redPosMatrix(posCounter, thisImage+1) = redPos{thisImage}(thisPos);
        posCounter = posCounter + 1;
    end
    negCounter = maxNegSize;
    maxNegThisImage = greenStartZ(thisImage) - 1;
    for thisNeg = maxNegThisImage:-1:1
        greenNegMatrix(negCounter, thisImage+1) = greenPos{thisImage}(thisNeg);
        redNegMatrix(negCounter, thisImage+1) = redPos{thisImage}(thisNeg);
        negCounter = negCounter - 1;
    end
end

greenMatrix = [greenNegMatrix; greenPosMatrix];
redMatrix = [redNegMatrix; redPosMatrix];


numRows = maxPosSize + maxNegSize;
rowCounter = 1;
for thisRow = numRows:-1:1
    greenMatrix(thisRow, 1) = maxPosSize - rowCounter;
    redMatrix(thisRow, 1) = maxPosSize - rowCounter;
rowCounter = rowCounter + 1;
end

disp('hi');
% 
% minStart = maxGreenStartZ-1 - maxGreenStartZ;
% minStartCounter = minStart;
% greenCounts = zeros(maxROIZ, numImages+1);
% redCounts = zeros(maxROIZ, numImages+1);
% 
% for thisROIZ = 1:maxROIZ
%     greenCount(thisROIZ,1) = minStartCounter;
%     redCount(thisROIZ,1) = minStartCounter;
%     for thisImage = 1:numImages
%         minStartThisImage = minStart - greenStartZ(thisImage);
%     end
%     minStart = minStartCounter+1;
% end

setappdata(parentHandles.(parentFigureName), 'greenMatrix', greenMatrix);
setappdata(parentHandles.(parentFigureName), 'redMatrix', redMatrix);
%setappdata(parentHandles.(parentFigureName), 'greenStartZ', greenStartZ);

close(progress);

% setappdata(parentHandles.(parentFigureName), 'greenSignalStartMean', greenSignalStartMean);
% setappdata(parentHandles.(parentFigureName), 'greenSignalStartStd', greenSignalStartStd);
% setappdata(parentHandles.(parentFigureName), 'greenExtentMean', greenExtentMean);
% setappdata(parentHandles.(parentFigureName), 'greenExtentStd', greenExtentStd);
% setappdata(parentHandles.(parentFigureName), 'redSignalStartMean', redSignalStartMean);
% setappdata(parentHandles.(parentFigureName), 'redSignalStartStd', redSignalStartStd);
% setappdata(parentHandles.(parentFigureName), 'redExtentMean', redExtentMean);
% setappdata(parentHandles.(parentFigureName), 'redExtentStd', redExtentStd);

