function [maskStack minValue] = seg3D(cube, featherSize, groupObjects, minSize)
%Pass in a Z-stack (cube) and perform Otsu thresholding in all 3 dimensions
%to segment out the object. If there is only 1 Z-section then seg2D.m is 
%used instead. Pass it back as a stack of binary masks.

cube = double(cube);
numY = length(cube(:,1,1));
numX = length(cube(1,:,1));
numZ = length(cube(1,1,:));

if numZ == 1
    [maskStack minValue] = seg2D(cube, featherSize, groupObjects, minSize);
else
    for thisZ = 1:numZ
        patchScZ = cube(:,:,thisZ)./max2(cube(:,:,thisZ));
        patch_01Z = patchScZ.*255;
        imgThreshZ = otsu(patch_01Z)/255;
        patchMaskZ(:,:,thisZ) = im2bw(patchScZ, imgThreshZ);
    end
    for thisX = 1:numX
        patchScX = squeeze(cube(:,thisX,:)./max2(cube(:,thisX,:)));
        patch_01X = patchScX.*255;
        imgThreshX = otsu(patch_01X)/255;
        patchMaskX(:,:,thisX) = im2bw(patchScX, imgThreshX);
    end
    for thisY = 1:numY
        patchScY = squeeze(cube(thisY,:,:)./max2(cube(thisY,:,:)));
        patch_01Y = patchScY.*255;
        imgThreshY = otsu(patch_01Y)/255;
        patchMaskY(:,:,thisY) = im2bw(patchScY, imgThreshY);
    end
    
    %Where the segmentation in all 3 planes agree keep the pixel.
    maskStack = zeros(numY,numX,numZ);
    for thisZ = 1:numZ
        for thisX = 1:numX
            for thisY = 1:numY
                if patchMaskY(thisX,thisZ,thisY) == 1 && patchMaskX(thisY,thisZ,thisX) == 1 && patchMaskZ(thisY,thisX,thisZ) == 1
                    maskStack(thisY,thisX,thisZ) = 1;
                end
            end
        end
    end
    maskStack = logical(maskStack);
    if groupObjects == 0
        maskStack = bwlabeln(maskStack);
        %Exclude objects smaller than the minimum size.
        if minSize > 1
            exclusionList = [];
            regionProps = regionprops(maskStack, 'Area');
            numProps = length(regionProps);
            for thisProp = 1:numProps
                propArea = regionProps(thisProp).Area;
                if propArea < minSize
                    exclusionList = [exclusionList thisProp];
                end
            end
            [loc1 loc2 maskStackVals] = find(maskStack);
            propValues = unique(maskStackVals);
            exclusionValues = propValues(exclusionList);
            numExclusions = length(exclusionList);
            for thisVal = 1:numExclusions
                exclusionIdx = find(maskStack == exclusionValues(thisVal));
                maskStack(exclusionIdx) = 0;
            end
        end
    end

    %Get the minimum value under the mask before feathering it out.
    minValue = minUnderMask(cube, maskStack);

    %Dilate the remaining objects by the requested number of pixels.
    if featherSize > 0
        se = strel('disk', featherSize);
        maskStack = imdilate(maskStack, se);
    end
    
    
    clear patchScZ;
    clear patchScX;
    clear patchScY;
    clear patch_01Z;
    clear patch_01X;
    clear patch_01Y;
    clear patchMaskX;
    clear patchMaskY;
    clear patchMaskZ;
end

end