function [roishapeIdx, fullMaskImg] = ROISegmentAndOverlay(roishapeIdx, patches, pixels, ROIText)

set(ROIText, 'String', ['ROI ', num2str(thisROI), ' of ' num2str(numROI)]);
drawnow;
maxX = pixels.getSizeX.getValue;
maxY = pixels.getSizeY.getValue;
fullZ = pixels.getSizeZ.getValue;
fullMaskImg = zeros(maxY,maxX,fullZ);

for thisROI = 1:length(patches)
    baseZ = roishapeIdx{thisROI}.Z(1);
    numZ(thisROI) = length(unique(roishapeIdx{thisROI}.Z));
    numT(thisROI) = length(unique(roishapeIdx{thisROI}.T));
    maxX = pixels.getSizeX.getValue;
    maxY = pixels.getSizeY.getValue;
    width = roishapeIdx{thisROI}.Width(1);
    height = roishapeIdx{thisROI}.Height(1);
    patchMasks{thisROI} = seg3D(patches{thisROI}); %The 3D segmentation

    %Show the user the results of the segmentation, and ask them to specify
    %the correct range of Z-sections.
    showmeRaw(patchMasks{thisROI})
    startZ = inputdlg('What is the lowest correct Z-section?', 'Z Start');
    stopZ = inputdlg('What is the highest correct Z-section?', 'Z Stop');
    startZ = str2double(startZ);
    stopZ = str2double(stopZ);
    close(gcf);
    roishapeIdx{thisROI}.startZ = startZ;
    roishapeIdx{thisROI}.stopZ = stopZ;
    roishapeIdx{thisROI}.numZ = stopZ-startZ;
    numZ(thisROI) = stopZ-startZ+1;
    
    patchMasks{thisROI} = patchMasks{thisROI}(:,:,startZ:stopZ);

    X = roishapeIdx{thisROI}.X(1)+1;    %svg entry in xml file indexes from (0, 0) instead of (1, 1), so +1
    Y = roishapeIdx{thisROI}.Y(1)+1;
    partMaskImg{thisROI} = zeros(maxY,maxX,numZ(thisROI));
    thisROIIntensityShape{thisROI} = zeros(height,width,numZ(thisROI));
    for thisZ = 1:numZ(thisROI)
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
                partMaskImg{thisROI}(posY, posX, thisZ) = patchMasks{thisROI}(row, col, thisZ);
                if patchMasks{thisROI}(row, col, thisZ) == 1;
                    thisROIIntensityShape{thisROI}(row, col, thisZ) = patches{thisROI}(row, col, thisZ);
                    intensityVector = reshape(thisROIIntensityShape{thisROI},1,[]);
                    roishapeIdx{thisROI}.sumPix = sum(intensityVector);
                    roishapeIdx{thisROI}.numPix = length(find(intensityVector));
                    roishapeIdx{thisROI}.meanPix = roishapeIdx{thisROI}.sumPix / roishapeIdx{thisROI}.numPix;
                    roishapeIdx{thisROI}.stdPix = std(intensityVector);
                end
            end
        end
        %    end
        %Just for now, save the Mask image to the same dir as the ROI files came
        %from instead of on the server.
    end
    %imwrite(fullMaskImg, [filepath, roishapeIdx{thisROI}.name, '.tif'], 'tif');
    roiZ = 1;
    for thisZ = baseZ+startZ:baseZ+stopZ
        fullMaskImg(:,:,thisZ) = fullMaskImg(:,:,thisZ) + partMaskImg{thisROI}(:,:,roiZ);
        roiZ = roiZ + 1;
    end
   
end
fullMaskImg = fullMaskImg.*4095;
end