function [patches, measureSegChannel] = cutPatchesFromROI(roiShapes, channels, channelsToFetch, pixels, thisROI)
global session;

measureSegChannel = 1;

if ~ismember(channels, channelsToFetch)
    channelsToFetch = [channels channelsToFetch];
    measureSegChannel = 0;
end
for thisFetchChannel = channelsToFetch
    %for thisROI = 1:numROI
        numZ = roiShapes{thisROI}.numShapes;
        %numT = length(unique(roiShapes{thisROI}.T));
        thisPatch = 1;
        X = floor(roiShapes{thisROI}.shape1.getX.getValue+1);    %svg entry in xml file indexes from (0, 0) instead of (1, 1), so +1
        Y = floor(roiShapes{thisROI}.shape1.getY.getValue+1);
        width = int32(roiShapes{thisROI}.shape1.getWidth.getValue);
        height = int32(roiShapes{thisROI}.shape1.getHeight.getValue);
        %Check to see if there's a tranform (translate) on the shape and
        %modify the XY coords
        transformCheck = roiShapes{thisROI}.shape1.getTransform;
        if isempty(transformCheck)
            transform = 'none';
        else
            transform = char(roiShapes{thisROI}.shape1.getTransform.getValue.getBytes');
        end
        
        if ~strcmp(transform, 'none') || ~isempty(transform)
            if strncmp(transform, 'trans', 5)
                closeBracket = findstr(transform, ')');
                openBracket = findstr(transform, '(');
                transformData = transform(openBracket+1:closeBracket-1);
                spaceChar = findstr(transformData, ' ');
                if isempty(spaceChar)
                    firstTranslate = str2double(transformData(1:end));
                    secondTranslate = 0;
                else
                    firstTranslate = str2double(transformData(1:spaceChar-1));
                    secondTranslate = str2double(transformData(spaceChar+1:end));
                end
                X = X + firstTranslate;
                Y = Y + secondTranslate;
            end
            if strncmp(transform, 'matrix', 6)
                closeBracket = findstr(transform, ')');
                openBracket = findstr(transform, '(');
                transformData = transform(openBracket+1:closeBracket-1);
                spaceChars = findstr(transformData, ' ');
                firstPart = transformData(1:spaceChars(1)-1);
                secondPart = transformData(spaceChars(1)+1:spaceChars(2)-1);
                thirdPart = transformData(spaceChars(2)+1:spaceChars(3)-1);
                fourthPart = transformData(spaceChars(3)+1:spaceChars(4)-1);
                fifthPart = transformData(spaceChars(4)+1:spaceChars(5)-1);
                sixthPart = transformData(spaceChars(5)+1:end);
                
                transX = str2double(fifthPart);
                transY = str2double(sixthPart);
                X = X + transX;
                Y = Y + transY;
            end
        end
        maxX = pixels.getSizeX.getValue;
        maxY = pixels.getSizeY.getValue;
        pixelsId = pixels.getId.getValue;
        imageId = pixels.getImage.getId.getValue;

        for thisZ = 1:numZ
            for thisT = 1
                %for thisC = channelsToFetch(1:end)
                    thisPlane = getPlane(session, imageId, roiShapes{thisROI}.(['shape' num2str(thisZ)]).getTheZ.getValue, thisFetchChannel-1, 0); %roiShapes{thisROI}.T(thisT));
                    patch(:,:, thisPatch) = zeros(height,width);
                    
                    %Check for the ROI going outwith the image. If it does
                    %the patch will be contructed pixel by pixel. Otherwise
                    %it can be done with a quick matrix operation.
                    ROIEndX = X+width;
                    ROIEndY = Y+height;
                    if ROIEndX > maxX || ROIEndY > maxY || X < 0 || Y < 0
                        cropPatch = 1;
                    else
                        cropPatch = 0;
                    end

                    if cropPatch == 1
                        if X < 1
                            X = 1;
                        end
                        if Y < 1
                            Y = 1;
                        end
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
                                patch(row, col, thisPatch) = thisPlane(posY, posX);
                            end
                        end
                    else
                        posX = floor(X+width-1);
                        posY = floor(Y+height-1);
                        patch(:,:,thisPatch) = thisPlane(Y:posY,X:posX);
                    end
                    thisPatch = thisPatch + 1;
                    patches{thisFetchChannel} = patch;
                %end
            end
        end
        patch = [];
    %end
end
end