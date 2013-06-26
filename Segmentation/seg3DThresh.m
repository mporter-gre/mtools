function [maskStack minValue] = seg3DThresh(cube, featherSize, groupObjects, threshold, minSize, patchMax)
%Pass in a Z-stack (cube) and perform Otsu thresholding in all 3 dimensions
%to segment out the object. If there is only 1 Z-section then seg2D.m is 
%used instead. Pass it back as a stack of binary masks.

numY = length(cube(:,1,1));
numX = length(cube(1,:,1));
numZ = length(cube(1,1,:));

if numZ == 1
    [maskStack minValue] = seg2DThresh(cube, featherSize, groupObjects, threshold, minSize, patchMax);
else
%     for thisZ = 1:numZ
%         patchScZ = cube(:,:,thisZ)./max2(cube(:,:,thisZ));
%         patchMaskZ(:,:,thisZ) = im2bw(patchScZ, threshold);
%     end
%     for thisX = 1:numX
%         patchScX = squeeze(cube(:,thisX,:)./max2(cube(:,thisX,:)));
%         patchMaskX(:,:,thisX) = im2bw(patchScX, threshold);
%     end
%     for thisY = 1:numY
%         patchScY = squeeze(cube(thisY,:,:)./max2(cube(thisY,:,:)));
%         patchMaskY(:,:,thisY) = im2bw(patchScY, threshold);
%     end
%     maskStack = zeros(numY,numX,numZ);
%     for thisZ = 1:numZ
%         for thisX = 1:numX
%             for thisY = 1:numY
%                 if patchMaskY(thisX,thisZ,thisY) == 1 && patchMaskX(thisY,thisZ,thisX) == 1 && patchMaskZ(thisY,thisX,thisZ) == 1
%                     maskStack(thisY,thisX,thisZ) = 1;
%                 end
%             end
%         end
%     end
    maskStack = cube;
    maskStack(find(maskStack<threshold)) = 0;
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