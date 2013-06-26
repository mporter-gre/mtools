function [roiShapes, fullMaskImg, data, dataAround, objectData, objectDataAround numSegPixels measureSegChannel] = ROISegmentMeasureAndMask(roiShapes, pixels, measureChannels, measureAroundChannels, segChannel, verifyZ, featherSize, groupObjects, minSize, selectedSegType, threshold, channelsToFetch, numROI, annulusSize, gapSize)
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

global fig1;
global ROIText;
global sectionClicked;
global sectionFigure;

maxX = pixels.getSizeX.getValue;
maxY = pixels.getSizeY.getValue;
fullZ = pixels.getSizeZ.getValue;
fullMaskImg = uint8(zeros(maxY,maxX,fullZ));
%numChannels = length(patches);
%numROI = length(patches{segChannel});

for thisROI = 1:numROI
    [patches measureSegChannel] = cutPatchesFromROI(roiShapes, segChannel, channelsToFetch, pixels, thisROI);
    set(ROIText, 'String', ['ROI ', num2str(thisROI), ' of ' num2str(numROI)]);
    drawnow;
    baseZ = roiShapes{thisROI}.shape1.getTheZ.getValue;
    numZ(thisROI) = roiShapes{thisROI}.numShapes;
    numT(thisROI) = 1; %length(unique(roiShapes{thisROI}.T));
    maxX = pixels.getSizeX.getValue;
    maxY = pixels.getSizeY.getValue;
    width = roiShapes{thisROI}.shape1.getWidth.getValue;
    height = roiShapes{thisROI}.shape1.getHeight.getValue;
    patchMax = max(reshape(patches{segChannel}, 1, []));
    if strcmpi(selectedSegType, 'Otsu')
        [patchMasks lowestValue] = seg3D(patches{segChannel}, featherSize, groupObjects, minSize); %The 3D segmentation
    elseif strcmpi(selectedSegType, 'Absolute')
        [patchMasks lowestValue] = seg3DThresh(patches{segChannel}, featherSize, groupObjects, threshold, minSize, patchMax);
    elseif strcmpi(selectedSegType, 'Sigma')
        sigmaMultiplier = threshold;
        threshold = getSigmaThreshold(patches{segChannel}, sigmaMultiplier);
        [patchMasks lowestValue] = seg3DThresh(patches{segChannel}, featherSize, groupObjects, threshold, minSize, patchMax);
    end
    

    %Show the user the results of the segmentation, and ask them to specify
    %the correct range of Z-sections. If there is only 1 Z or there is nothing segmented
    %then just use it.
    maxPatch = max(max(max(patchMasks)));
    if numZ(thisROI) > 1 && maxPatch > 0
        if verifyZ == 1
            [startZ stopZ] = zChooser(patchMasks);
        else
            startZ = 1;
            stopZ = numZ(thisROI);
        end
    else
        startZ = 1;
        stopZ = 1;
    end
    set(ROIText, 'String', 'Creating mask and calculating intensities...');
    drawnow;
    roiShapes{thisROI}.startZ = startZ;
    roiShapes{thisROI}.stopZ = stopZ;
    roiShapes{thisROI}.numZ = stopZ-startZ;
    numZ(thisROI) = stopZ-startZ+1;

    patchMasks = patchMasks(:,:,startZ:stopZ);
    numSegPixels{thisROI} = length(find(reshape((patchMasks>0),1,[])));

    X = roiShapes{thisROI}.shape1.getX.getValue+1;    %svg entry in xml file indexes from (0, 0) instead of (1, 1), so +1
    Y = roiShapes{thisROI}.shape1.getY.getValue+1;
    partMaskImg = uint8(zeros(maxY,maxX,numZ(thisROI)));

    %Measure intensities under the segmentation mask for the intended
    %channels.
    counter = 1;
    for thisMeasureChannel = measureChannels
        thisROIIntensityShape{counter} = zeros(height,width,numZ(thisROI));
        ROIEndX = X+width;
        ROIEndY = Y+height;
        if ROIEndX > maxX || ROIEndY > maxY || X < 0 || Y < 0
            cropPatch = int8(1);
            if X < 1
                X = 1;
            end
            if Y < 1
                Y = 1;
            end
        else
            cropPatch = 0;
        end

        for thisZ = 1:numZ(thisROI)
            if fix(cropPatch) == 1
                for col = 1:width
                    posX = col+X-1;
                    if posX > maxX  %If the ROI was drawn to extend off the image, set the crop to the edge of the image only.
                        posX = maxX;
                    end
                    for row = 1:height
                        posY = row+Y-1;
                        if posY > maxY
                            posY = maxY;
                        end
                        partMaskImg(posY, posX, thisZ) = patchMasks(row, col, thisZ);
                    end
                end
            else
                posX = X+width-1;
                posY = Y+height-1;
                partMaskImg(Y:posY,X:posX, thisZ) = patchMasks(:,:, thisZ);
            end
            [patchYLocs, patchXLocs] = find(patchMasks(:,:,thisZ));
            lengthPatchLocs = length(patchYLocs);
            for thisPatchLoc = 1:lengthPatchLocs
                thisROIIntensityShape{counter}(patchYLocs(thisPatchLoc),patchXLocs(thisPatchLoc),thisZ) = patches{thisMeasureChannel}(patchYLocs(thisPatchLoc), patchXLocs(thisPatchLoc), thisZ);
            end
        end
        %thisROIIntensityShape{counter}(patchMasks) = patches{thisMeasureChannel}(patchMasks);
        counter = counter + 1;
    end

    %Measure intensities around the segmentation mask for the intended
    %channels. Detect if the 'around' signal come from an annulus.
    counter = 1;
    for thisMeasureAroundChannel = measureAroundChannels
        thisAroundROIIntensityShape{counter} = zeros(height,width,numZ(thisROI));
        %for thisZ = 1:numZ(thisROI)
        if annulusSize > 0
            diskSize = annulusSize + gapSize;
            se = strel('disk', diskSize);
            seGap = strel('disk', gapSize);
            patchMasksBkg = patchMasks;
            patchMasksBkgDil = imdilate(patchMasksBkg, se);
            patchMasksSigPlusGap = imdilate(patchMasksBkg, seGap);
            patchMasksBkgDil(patchMasksSigPlusGap>0) = 0;
            %patchMasksBkgBwl = bwlabeln(patchMasksBkg);
            %patchMasksBkgBwlDil = imdilate(patchMasksBkgBwl, se);
            %patchMasksBkgBwlDil(patchMasks>0) = 0;
            thisAroundROIIntensityShape{counter}(logical(patchMasksBkgDil)) = patches{thisMeasureAroundChannel}(logical(patchMasksBkgDil));
        else
            thisAroundROIIntensityShape{counter}(~patchMasks) = patches{thisMeasureAroundChannel}(~patchMasks);
        end
        %end
        counter = counter + 1;
    end

    roiZ = 1;
    for thisZ = baseZ+startZ:baseZ+stopZ
        fullMaskImg(:,:,thisZ) = fullMaskImg(:,:,thisZ) + partMaskImg(:,:,roiZ);
        roiZ = roiZ + 1;
    end

    counter = 1;
    if ~isempty(measureChannels)
        for thisMeasureChannel = measureChannels
            intensityVector = thisROIIntensityShape{counter}(patchMasks>0);
            data{thisROI}{counter}.sumPix = sum(intensityVector);
            data{thisROI}{counter}.numPix = length(intensityVector);
            data{thisROI}{counter}.meanPix = data{thisROI}{counter}.sumPix / data{thisROI}{counter}.numPix;
            data{thisROI}{counter}.stdPix = std(intensityVector);
            data{thisROI}{counter}.channel = thisMeasureChannel;
            
            if groupObjects == 0
                [row, col, objectValues] = find(unique(patchMasks));
                numObjects = length(objectValues);
                roiShapes{thisROI}.numObjects = numObjects;
                %If there are no segmented pixels per object enter zero.
                if isempty(objectValues)
                    objectData{thisROI}{1}{counter}.sumPix = 0;
                    objectData{thisROI}{1}{counter}.numPix = 0;
                    objectData{thisROI}{1}{counter}.meanPix = 0;
                    objectData{thisROI}{1}{counter}.stdPix = 0;
                    objectData{thisROI}{1}{counter}.channel = thisMeasureChannel;
                else
                    objectIntensityVector = {};
                    for thisObject = 1:numObjects
                        objectIntensityVector{thisObject} = thisROIIntensityShape{counter}(find(patchMasks==objectValues(thisObject)));
                        objectData{thisROI}{thisObject}{counter}.sumPix = sum(objectIntensityVector{thisObject});
                        objectData{thisROI}{thisObject}{counter}.numPix = length(objectIntensityVector{thisObject});
                        objectData{thisROI}{thisObject}{counter}.meanPix = objectData{thisROI}{thisObject}{counter}.sumPix / objectData{thisROI}{thisObject}{counter}.numPix;
                        objectData{thisROI}{thisObject}{counter}.stdPix = std(objectIntensityVector{thisObject});
                        objectData{thisROI}{thisObject}{counter}.channel = thisMeasureChannel;
                    end
                end
            else
                objectData = [];
                roiShapes{thisROI}.numObjects = 1;
            end
            
            counter = counter + 1;
        end
    else
        data{thisROI}{counter}.sumPix = [];
        data{thisROI}{counter}.numPix = [];
        data{thisROI}{counter}.meanPix = [];
        data{thisROI}{counter}.stdPix = [];
        data{thisROI}{counter}.channel = [];
        if groupObjects == 1
            objectData = [];
        end
    end

    counter = 1;
    if ~isempty(measureAroundChannels)
        for thisMeasureAroundChannel = measureAroundChannels
            intensityAroundVector = thisAroundROIIntensityShape{counter}(find(thisAroundROIIntensityShape{counter}));
            dataAround{thisROI}{counter}.sumPix = sum(intensityAroundVector);
            dataAround{thisROI}{counter}.numPix = length(intensityAroundVector);
            dataAround{thisROI}{counter}.meanPix = dataAround{thisROI}{counter}.sumPix / dataAround{thisROI}{counter}.numPix;
            dataAround{thisROI}{counter}.stdPix = std(intensityAroundVector);
            dataAround{thisROI}{counter}.channel = thisMeasureAroundChannel;
            
            %Think about objectDataAround a bit more before including this
            %kind of code.
            if groupObjects == 0 && annulusSize > 0
                [row, col, objectValues] = find(unique(patchMasksBkg));
                numObjects = length(objectValues);
                for thisObject = 1:numObjects
                    objectIntensityVector = thisAroundROIIntensityShape{counter}(patchMasksBkgDil==objectValues(thisObject));
                    objectDataAround{thisROI}{counter}{thisObject}.sumPix = sum(objectIntensityVector);
                    objectDataAround{thisROI}{counter}{thisObject}.numPix = length(objectIntensityVector);
                    objectDataAround{thisROI}{counter}{thisObject}.meanPix = objectDataAround{thisROI}{counter}{thisObject}.sumPix / objectDataAround{thisROI}{counter}{thisObject}.numPix;
                    objectDataAround{thisROI}{counter}{thisObject}.stdPix = std(objectIntensityVector);
                    objectDataAround{thisROI}{counter}{thisObject}.channel = thisMeasureChannel;
                end
            else
                 objectDataAround = [];
            end
            
            counter = counter + 1;
        end
    else
        dataAround{thisROI}{counter}.sumPix = [];
        dataAround{thisROI}{counter}.numPix = [];
        dataAround{thisROI}{counter}.meanPix = [];
        dataAround{thisROI}{counter}.stdPix = [];
        dataAround{thisROI}{counter}.channel = [];
%        if groupObjects == 1
            objectDataAround = [];
%        end
    end
end
fullMaskImg = fullMaskImg.*255;
clear('patchMasks');
clear('intensityVector');
clear('partMaskImg');
clear('thisROIIntensityShape');
end