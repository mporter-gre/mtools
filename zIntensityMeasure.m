function [roiIdx roishapeIdx] = zIntensityMeasure(filepath, filename, username, password, fileNum, numFiles, conditionNum, numConditions)
%Let the user know what's going on, position it in the centre of the screen...
scrsz = get(0,'ScreenSize');
fig1 = figure('Name','Processing...','NumberTitle','off','MenuBar','none','Position',[(scrsz(3)/2)-150 (scrsz(4)/2)-80 300 80]);
conditionText = uicontrol(fig1, 'Style', 'text', 'String', ['Condition ', num2str(conditionNum), ' of ' num2str(numConditions)], 'Position', [25 60 250 15]);
fileText = uicontrol(fig1, 'Style', 'text', 'String', ['ROI file ', num2str(fileNum), ' of ' num2str(numFiles)], 'Position', [25 35 250 15]);
drawnow;

%Process the ROI file for cropping the images and passing the ROI's back to
%selectROIFiles.m
[roiIdx roishapeIdx] = readROIs([filepath filename]);
[client, session, gateway] = gatewayConnect(username, password);
[pixelsId, imageName] = getPixIdFromROIFile(filename);
pixelsId = str2double(pixelsId);
pixels = gateway.getPixels(pixelsId);
imageId = pixels.getImage.getId.getValue;
maxX = pixels.getSizeX.getValue;
maxY = pixels.getSizeY.getValue;
numChannels = pixels.getSizeC.getValue;

%Get planes for each ROIShape listed, grouped by ROI, then copy the ROI
%patch to a new image and upload it to the server. Also get the deltaT via
%query for the first and last roishape T and Z.
numROI = length(roiIdx);
ROIText = uicontrol(fig1, 'Style', 'text', 'Position', [25 10 250 15]);
for thisROI = 1:numROI
    set(ROIText, 'String', ['ROI ', num2str(thisROI), ' of ' num2str(numROI)]);
    drawnow;
    numZ(thisROI) = length(unique(roishapeIdx{thisROI}.Z));
    numT(thisROI) = length(unique(roishapeIdx{thisROI}.T));
    thisPatch = 1;
    X = roishapeIdx{thisROI}.X(1)+1;    %svg entry in xml file indexes from (0, 0) instead of (1, 1), so +1
    Y = roishapeIdx{thisROI}.Y(1)+1;
    width = roishapeIdx{thisROI}.Width(1);
    height = roishapeIdx{thisROI}.Height(1);
    roishapeIdx{thisROI}.name = [imageName '_mask'];
    roishapeIdx{thisROI}.origName = imageName;

    for thisZ = 1:numZ(thisROI)
        for thisT = 1
            for thisC = 1
            %for thisC = 1:numChannels
                thisPlane = getPlaneFromPixelsId(pixelsId, roishapeIdx{thisROI}.Z(thisZ), thisC-1, roishapeIdx{thisROI}.T(thisT), gateway);
                patch(:,:, thisPatch) = zeros(height,width);
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
                thisPatch = thisPatch + 1;
            end
        end
    end

    patches{thisROI} = medfilt2(patch);
    patch = [];
end

%Piece together a mask image the same size as the original image, and send
%it back to the server.
fullMaskImg = zeros(maxY,maxX);
for thisROI = 1:length(patches)
    patchMask = seg2D(patches{thisROI});
    imageIdx = find(patchMask);
    width = roishapeIdx{thisROI}.Width(1);
    height = roishapeIdx{thisROI}.Height(1);
    X = roishapeIdx{thisROI}.X(1)+1;    %svg entry in xml file indexes from (0, 0) instead of (1, 1), so +1
    Y = roishapeIdx{thisROI}.Y(1)+1;
    roishapeIdx{thisROI}.sum = sum(sum(patches{thisROI}(imageIdx)));
    roishapeIdx{thisROI}.mean = mean2(patches{thisROI}(imageIdx));
    roishapeIdx{thisROI}.stdev = std2(patches{thisROI}(imageIdx));
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
            fullMaskImg(posY, posX) = patchMask(row, col);
        end
    end
end
%Just for now, save the Mask image to the same dir as the ROI files came
%from instead of on the server.
imwrite(fullMaskImg, [filepath, roishapeIdx{thisROI}.name, '.tif'], 'tif');


% for thisROI = 1:length(patches)
%     parameters.sizeX = roishapeIdx{thisROI}.Width(1);
%     parameters.sizeY = roishapeIdx{thisROI}.Height(1);
%     parameters.sizeT = numT(thisROI);
%     parameters.sizeZ = numZ(thisROI);
%     for thisChannel = 1:numChannels
%         parameters.channelList(thisChannel) = thisChannel;
%     end
%     parameters.imageName = roishapeIdx{thisROI}.name;
%     newImageId = copyImageChangingParameters(imageId, parameters);
%     newImage = gateway.getImage(newImageId);
%     newImage.setName(omero.rtypes.rstring(parameters.imageName));
%     gateway.saveObject(newImage);
%     newPixels = gateway.getPixelsFromImage(newImageId);
%     newPixelsId = newPixels.get(0).getId.getValue;
%     
%     for thisPlane = 1:length(patches{thisROI})
%         for thisZ = 1:numZ(thisROI)
%             for thisT = 1:numT(thisROI)
%                 for thisC = 1:numChannels
%                     planeAsBytes = omerojava.util.GatewayUtils.convertClientToServer(newPixels.get(0), patches{thisROI}(:,:,thisPlane)');
%                     gateway.uploadPlane(newPixelsId, thisZ-1, thisC-1, thisT-1, planeAsBytes)
%                     thisPlane = thisPlane + 1;
%                 end
%             end
%         end
%     end
%     
%     %Get a dataset object and do attachImageToDataset(Dataset, Image);
%                 
% end

close(fig1);

end