function roiShapes = eventTimerAndCrop(theImage, imageId, origImageName, roiShapes, pixels, frames, channelLabels, saveMasks)
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

%[filename filepath] = uigetfile('*.xml');
%Process the ROI file for cropping the images and passing the ROI's back to
%selectROIFiles.m

global gateway;
global session;
global progBar;

framesBefore = frames(1);
framesAfter = frames(2);
numROI = length(roiShapes);
% try
%     [roiIdx roishapeIdx] = readROIs([filepath filename]);
% catch
%     helpdlg(['There was a problem opening the ROI file ', filename, ', please check this file and retry it.', 'Problem']);
%     set(handles.beginAnalysisButton, 'Enable', 'on');
%     badImage = 1;
%     return;
% end
% try
%     [client, session, gateway] = gatewayConnect(credentials{1}, credentials{2}, credentials{3});
% catch
%     helpdlg('Could not log you on to the server. Check your username and password');
%     set(handles.beginAnalysisButton, 'Enable', 'on');
%     badCredentials = 1;
%     return;
% end
% try
%     [pixelsId, imageName] = getPixIdFromROIFile([filepath filename], credentials{1}, credentials{3});
%     [imageName remain] = strtok(filename, '.');
% catch
%     helpdlg(['Reference to ', filename, ' could not be found in your roiFileMap.xml. Please re-save the ROI file in Insight and try analysis again.']);
%     set(handles.beginAnalysisButton, 'Enable', 'on');
%     badImage = 1;
%     return;
% end

%Let the user know what's going on...
% scrsz = get(0,'ScreenSize');
% fig1 = figure('Name','Processing...','NumberTitle','off','MenuBar','none','Position',[(scrsz(3)/2)-150 (scrsz(4)/2)-80 300 80]);
% conditionText = uicontrol(fig1, 'Style', 'text', 'String', ['Condition ', num2str(conditionNum), ' of ' num2str(numConditions)], 'Position', [25 60 250 15]);
% fileText = uicontrol(fig1, 'Style', 'text', 'String', ['ROI file ',
% num2str(fileNum), ' of ' num2str(numFiles)], 'Position', [25 35 250 15]);
% drawnow;

% pixelsId = str2double(pixelsId);
% pixels = gateway.getPixels(pixelsId);
% imageId = pixels.getImage.getId.getValue;
% theImage = gateway.getImage(imageId);

maxX = pixels.getSizeX.getValue;
maxY = pixels.getSizeY.getValue;
fullZ = pixels.getSizeZ.getValue;
fullT = pixels.getSizeT.getValue;
numC = pixels.getSizeC.getValue;
pixelsType = pixels.getPixelsType.getValue.getValue;
pixelsType = char(pixelsType);
pixelsId = pixels.getId.getValue;
theImage = pixels.getImage;
imageId = theImage.getId.getValue;

%Ask the user about sending image masks to the server.
% if remembered == 0
%     [saveMasks framesBefore framesAfter remembered scope] = eventTimerChoices(origImageName{1});
%     drawnow;
%     if strcmp(scope, 'condition')
%         scope = conditionNum;
%     else
%         scope = -1;
%     end
% end


%Find the linear indices of the ROI's position on each frame (x,y,t,z).
%Use these indices to map intensity pixels from the original image to the
%new "Events" image. Also gather the 'deltaT' info for the first and last
%frames.

extraTBefore{numROI} = [];
extraTAfter{numROI} = [];
actualT{numROI} = [];
actualZ{numROI} = [];
%ROIText = uicontrol(fig1, 'Style', 'text', 'Position', [25 10 250 15]);
%planeInfoForPixels = gateway.findAllByQuery(['select info from PlaneInfo as info where pixels.id = ', num2str(pixelsId), ' and theZ = 0 and theC = 0 order by deltat']);


for thisROI = 1:numROI
    %set(ROIText, 'String', ['ROI ', num2str(thisROI), ' of ' num2str(numROI)]);
    %drawnow;
    allZ = [];
    allT = [];
    numShapes = roiShapes{thisROI}.numShapes;
    for thisShape = 1:numShapes
        allZ = [allZ roiShapes{thisROI}.(['shape' num2str(thisShape)]).getTheZ.getValue];
        allT = [allT roiShapes{thisROI}.(['shape' num2str(thisShape)]).getTheT.getValue];
    end
    numZ(thisROI) = length(unique(allZ));
    numT(thisROI) = length(unique(allT));
    for thisT = 1:numT(thisROI)
        for thisZ = 1:numZ(thisROI)
            indices{thisROI}{thisT}{thisZ} = [];
        end
    end

    actualZ{thisROI} = unique(allZ); %indices of the Z and T of the original image that this ROI points to.
    actualT{thisROI} = unique(allT);
    %If the user specified, add frames to the start and end of
    %actualT{thisROI}. Don't let it go below 0 or over max T.
    if framesBefore > 0
        minActualT = min(actualT{thisROI});
        newMinActualT = minActualT - framesBefore;
        for newT = newMinActualT:minActualT-1
            if newT <= 0
                continue;
            end
            actualT{thisROI} = [actualT{thisROI} newT];
            extraTBefore{thisROI} = [extraTBefore{thisROI} newT];
        end
    end
    if framesAfter > 0
        maxActualT = max(actualT{thisROI});
        newMaxActualT = maxActualT + framesAfter;
        for newT = maxActualT+1:newMaxActualT
            if newT > fullT
                continue;
            end
            actualT{thisROI} = [actualT{thisROI} newT];
            extraTAfter{thisROI} = [extraTAfter{thisROI} newT];
        end
    end
    extraT{thisROI} = [extraTBefore{thisROI} extraTAfter{thisROI}];
   
    firstPlaneInfo = getPlaneInfo(session, imageId, 0, 0, roiShapes{thisROI}.shape1.getTheT.getValue);
    secondPlaneInfo = getPlaneInfo(session, imageId, 0, 0, roiShapes{thisROI}.(['shape' num2str(numShapes)]).getTheT.getValue);
    firstDeltaT = firstPlaneInfo.getDeltaT.getValue; %planeInfoForPixels.get(roiShapes{thisROI}.shape1.getTheT.getValue).getDeltaT.getValue;
    %planeInfoForPixels = gateway.findAllByQuery(['select info from PlaneInfo as info where pixels.id = ', num2str(pixelsId), ' and info.theT = ' num2str(roishapeIdx{thisROI}.T(end)), ' and theZ = ', num2str(roishapeIdx{thisROI}.Z(1)), ' and theC = 0']);
    lastDeltaT = secondPlaneInfo.getDeltaT.getValue; %planeInfoForPixels.get(roiShapes{thisROI}.(['shape' num2str(numShapes)]).getTheT.getValue).getDeltaT.getValue;
    roiShapes{thisROI}.deltaT = lastDeltaT - firstDeltaT;
    roiShapes{thisROI}.name = [origImageName '_event_' num2str(thisROI)];
    roiShapes{thisROI}.origName = origImageName;
end

%If the user has chosen so, save the mask to the server.
if saveMasks == 1
    store = session.createRawPixelsStore();
    currPlane = 0;
%    set(ROIText, 'String', 'Sending images to server...');
%     countPlanes = 1;
    numPlanes = fullZ * fullT * (numC+1);
    for thisROI = 1:numROI
        for thisT = 1:numT(thisROI)
            for thisZ = 1:numZ(thisROI)
                X = roiShapes{thisROI}.(['shape' num2str(thisT*thisZ)]).getX.getValue + 1; %X = roishapeIdx{thisROI}.X(thisT*thisZ)+1;    %svg entry in xml file indexes from (0, 0) instead of (1, 1), so +1
                Y = roiShapes{thisROI}.(['shape' num2str(thisT*thisZ)]).getY.getValue + 1; %Y = roishapeIdx{thisROI}.Y(thisT*thisZ)+1;
                width = roiShapes{thisROI}.(['shape' num2str(thisT*thisZ)]).getWidth.getValue;
                height = roiShapes{thisROI}.(['shape' num2str(thisT*thisZ)]).getHeight.getValue;
                ROIMaxX = X+width;
                ROIMaxY = Y+height;

                if X < 1
                    X = 1;
                end
                if Y < 1
                    Y = 1;
                end
                if ROIMaxX > maxX
                    ROIMaxX = maxX;
                end
                if ROIMaxY > maxY
                    ROIMaxY = maxY;
                end
                indices{thisROI}{thisT}{thisZ}.X = X:ROIMaxX;
                indices{thisROI}{thisT}{thisZ}.Y = Y:ROIMaxY;
            end
        end
    end


    %Create the new Image on the server so we can upload planes to it.
    %channelLabels = getChannelLabelsFromPixels(pixels);
    channelLabels{end+1} = 1000;
    %channelLabels{1} = [channelLabels{1} 1000];
    newImage = createNewImageFromOldPixels(imageId, channelLabels, [origImageName, '_events'], '');
    newImageId = newImage.getId.getValue;
    newPixels = newImage.getPrimaryPixels;
    newPixelsId = newPixels.getId.getValue;
    store.setPixelsId(newPixelsId, false);

    %Make the full image from the ROI patches and send it to the server each
    %completed T at a time.
    drawnow;
    for thisT = 1:fullT
        for thisZ = 1:fullZ
            for thisC = 1:numC+1
                newPlane = zeros(maxY, maxX);
                newPlane = setMatrixType(newPlane, pixelsType);
                labelPlane = zeros(maxY, maxX);
                for thisROI = 1:numROI
                    if any(actualT{thisROI}(:) == thisT-1) && any(actualZ{thisROI}(:) == thisZ-1)
                        ROIZ = find(actualZ{thisROI}== thisZ-1);
                        ROIT = find(setdiff(actualT{thisROI}, extraT{thisROI})== thisT);
                        if isempty(ROIT)
                            %if ismember(thisT, extraTBefore{thisROI})
                                ROIT = 1;
                            %end
                            if ismember(thisT, extraTAfter{thisROI})
                                Tdiff = setdiff(actualT{thisROI}, extraT{thisROI});
                                ROIT = length(Tdiff);
                            end
                        end
                            if thisC > numC   %Make the channel to number these events on the image itself.
                                if ~ismember(thisT, extraTBefore{thisROI}) && ~ismember(thisT, extraTAfter{thisROI}) %Don't put the event number on leading or trailing frames to the ROI.
                                    ROIText = num2str(thisROI);
                                    lenLabel = length(ROIText);
                                    spacer = 0;
                                    labelX = roiShapes{thisROI}.(['shape' num2str(ROIT*ROIZ)]).getX.getValue + 1;
                                    if labelX <= 0
                                        labelX = 1;
                                    end
                                    if labelX > (maxX - 14)
                                        labelX = maxX - (lenLabel * 14);
                                    end
                                    labelY = roiShapes{thisROI}.(['shape' num2str(ROIT*ROIZ)]).getY.getValue + 1;
                                    if labelY <= 0
                                        labelY = 1;
                                    end
                                    if labelY > (maxY - 13)
                                        labelY = maxY - 13;
                                    end
                                    for thisLabel = 1:lenLabel
                                        labelPlane = numberOverlay(labelPlane, labelX+spacer, labelY, str2double(ROIText(thisLabel)));
                                        spacer = spacer + 7;
                                    end
                                    newPlane = labelPlane;
                                end
                            else  %Copy the intensity patch from the original image to the new plane;
                                thisPlane = getPlane(session, imageId, thisZ-1, thisC-1, thisT-1);
                                newPlane(indices{thisROI}{ROIT}{ROIZ}.Y,indices{thisROI}{ROIT}{ROIZ}.X) = thisPlane(indices{thisROI}{ROIT}{ROIZ}.Y,indices{thisROI}{ROIT}{ROIZ}.X);
                            end
                        
                    end
                end
                %planeAsBytes = omerojava.util.GatewayUtils.convertClientToServer(newPixels, newPlane');
                [sizeY, sizeX] = size(newPlane);
                planeAsBytes = typecast(swapbytes(reshape(newPlane, sizeX * sizeY, 1)), 'int8');
                store.setPlane(planeAsBytes, thisZ-1, thisC-1, thisT-1);
                %gateway.uploadPlane(newPixelsId, thisZ-1, thisC-1, thisT-1, planeAsBytes);
                %set(ROIText, 'String', ['Sending images to server... ' num2str(countPlanes) '/ ' numPlanes]);
                drawnow;
                currPlane = currPlane + 1;
                waitbar(currPlane/numPlanes, progBar);
            end
        end
    end
    store.save();
    store.close();
    %Now make the channel to number these events on the image itself

    %Set the new image's start and end display values the same as the original.
    %Start by getting the start and end values for each channel
    renderingEngine = session.createRenderingEngine;
    renderingEngine.lookupPixels(pixelsId);
    renderingEngine.lookupRenderingDef(pixelsId);
    renderingEngine.load();
    for thisC = 1:numC
        channelStart(thisC) = renderingEngine.getChannelWindowStart(thisC-1);
        channelEnd(thisC) = renderingEngine.getChannelWindowEnd(thisC-1);
    end
    renderingEngine.close();

    %Now load the rendersettings for the new image and apply the settings.
    renderingEngine = session.createRenderingEngine;
    renderingEngine.lookupPixels(newPixelsId);
    renderingEngine.resetDefaults;
    renderingEngine.lookupRenderingDef(newPixelsId);
    renderingEngine.load();
    for thisC = 1:numC
        renderingEngine.setActive(thisC-1,1);
        renderingEngine.setChannelWindow(thisC-1, channelStart(thisC), channelEnd(thisC));
    end
    pixServiceDescription = session.getPixelsService.retrievePixDescription(newPixelsId).getChannel(thisC).getLogicalChannel();
    pixServiceDescription.setName(omero.rtypes.rstring('Events'));
    iUpdate = session.getUpdateService();
    iUpdate.saveObject(pixServiceDescription);
    renderingEngine.setRGBA(thisC,255,255,255,200); %Set the label channel to grey, alpha 200;
    renderingEngine.saveCurrentSettings;
    renderingEngine.close();

    %Link the new image into the same dataset as the original image.
    thisImageLinks = gateway.findAllByQuery(['select link from DatasetImageLink as link where link.child.id = ', num2str(imageId)]);
    imageLinksIter = thisImageLinks.iterator;
    thisIter = 1;
    while imageLinksIter.hasNext
        imageLinks(thisIter) = imageLinksIter.next.getParent.getId.getValue;
        thisIter = thisIter + 1;
    end
    sortedLinks = sort(imageLinks);

    aDataset = gateway.getDataset(sortedLinks(1),0);
    aDataset.unload;
    newImage.unload;
    newLink = omero.model.DatasetImageLinkI();
    newLink.link(aDataset, newImage);
    gateway.saveObject(newLink);
end

%close(fig1);

end