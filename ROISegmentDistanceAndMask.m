function [roishapeIdx, fullMaskImg, data, dataAround] = ROISegmentDistanceAndMask(roishapeIdx, patches, pixels, channelsToMeasure)
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

global fig1;
global ROIText;
global sectionClicked;
global sectionFigure;
global objectViewer;
global objectClicked;

maxX = pixels.getSizeX.getValue;
maxY = pixels.getSizeY.getValue;
fullZ = pixels.getSizeZ.getValue;
fullMaskImg = uint8(zeros(maxY,maxX,fullZ));
numChannels = length(patches);
numROI = length(roishapeIdx);

for thisROI = 1:numROI
    set(ROIText, 'String', ['ROI ', num2str(thisROI), ' of ' num2str(numROI)]);
    drawnow;
    baseZ = roishapeIdx{thisROI}.Z(1);
    numZ(thisROI) = length(unique(roishapeIdx{thisROI}.Z));
    numT(thisROI) = length(unique(roishapeIdx{thisROI}.T));
    maxX = pixels.getSizeX.getValue;
    maxY = pixels.getSizeY.getValue;
    width = roishapeIdx{thisROI}.Width(1);
    height = roishapeIdx{thisROI}.Height(1);
    for thisChannel = 1:2
        patchMasks{thisChannel}{thisROI} = seg3D(patches{channelsToMeasure(thisChannel)}{thisROI}, 0); %The 3D segmentation
    end

    %Show the user the results of the segmentation, and ask them to specify
    %the correct range of Z-sections. If there is only 1 Z then just use
    %it.
    combinedPatchMasks = patchMasks{1}{thisROI} + patchMasks{2}{thisROI};
    if numZ > 1
        if numZ > 25
            showmeRawLargeScreenZSections(combinedPatchMasks);
        else
            showmeRaw(combinedPatchMasks);
        end
        sectionsChosen = 0;
        while sectionsChosen == 0
            set(ROIText, 'String', 'Click on the LOWEST correct Z-Section.');
            figure(fig1);
            drawnow;
            uiwait(fig1);
            startZ = sectionClicked;
            set(ROIText, 'String', 'Click on the Highest correct Z-Section.');
            figure(fig1);
            drawnow;
            uiwait(fig1);
            stopZ = sectionClicked;
            questionStr = ['Lowest Z = ', num2str(startZ), ', highest Z = ', num2str(stopZ), '?'];
            response = questdlg(questionStr, 'Correct Z-Sections?', 'Yes', 'No', 'Yes');
            if strcmp(response, 'Yes')
                sectionsChosen = 1;
            end
        end
        close(sectionFigure);
    else
        startZ = 1;
        stopZ = 1;
    end
    set(ROIText, 'String', 'Creating mask and calculating intensities...');
    drawnow;
    roishapeIdx{thisROI}.startZ = startZ;
    roishapeIdx{thisROI}.stopZ = stopZ;
    roishapeIdx{thisROI}.numZ = stopZ-startZ;
    numZ(thisROI) = stopZ-startZ+1;
    
    for thisChannel = 1:2
        patchMasks{thisChannel}{thisROI} = patchMasks{thisChannel}{thisROI}(:,:,startZ:stopZ);
    end
    
    X = roishapeIdx{thisROI}.X(1)+1;    %svg entry in xml file indexes from (0, 0) instead of (1, 1), so +1
    Y = roishapeIdx{thisROI}.Y(1)+1;
    partMaskImg{thisChannel}{thisROI} = uint8(zeros(maxY,maxX,numZ(thisROI)));
    
    %Find the number of objects segmented in the ROI in each channel. If
    %there is more than one then going to have to ask the user which one to
    %use.
    for thisChannel = 1:2
        [patchMasksbwln{thisChannel}{thisROI} numObjects{thisChannel}{thisROI}] = bwlabeln(patchMasks{thisChannel}{thisROI});
    end
    
    objectsChosen = 0;
    while objectsChosen == 0
        set(ROIText, 'String', 'Click on the object to measure the distance FROM.');
        objectViewAndSelect(patchMasksbwln{1}{thisROI});
        figure(objectViewer);
        drawnow;
        uiwait(objectViewer);
        object1 = objectClicked
        set(ROIText, 'String', 'Click on the object to measure the distance TO.');
        objectViewAndSelect(patchMasksbwln{2}{thisROI})
        figure(objectViewer);
        drawnow;
        uiwait(objectViewer);
        object2 = objectClicked
        questionStr = 'Are you sure?';
        response = questdlg(questionStr, 'Correct Z-Sections?', 'Yes', 'No', 'Yes');
        if strcmp(response, 'Yes')
            objectsChosen = 1;
        end
    end
    close(objectViewer);


    
    2+2;
    
    
    
    
    
    
    
    
    
    
    

    %Measure intensities under the segmentation mask for the intended
    %channels.
    counter = 1;
    for thisMeasureChannel = measureChannels
        thisROIIntensityShape{counter}{thisROI} = zeros(height,width,numZ(thisROI));
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
                end
            end
            partMaskImg{thisROI}(Y:Y+height-1,X:X+width-1, thisZ) = patchMasks{thisROI}(:,:, thisZ);
            thisROIIntensityShape{counter}{thisROI}(patchMasks{thisROI}(:,:,thisZ)) = patches{thisMeasureChannel}{thisROI}(patchMasks{thisROI}(:,:,thisZ));
        end
        counter = counter + 1;
    end
    
    %Measure intensities around the segmentation mask for the intended
    %channels.
    counter = 1;
    for thisMeasureAroundChannel = measureAroundChannels
        thisAroundROIIntensityShape{counter}{thisROI} = zeros(height,width,numZ(thisROI));
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
                end
            end
            thisAroundROIIntensityShape{counter}{thisROI}(~patchMasks{thisROI}(:,:,thisZ)) = patches{thisMeasureAroundChannel}{thisROI}(~patchMasks{thisROI}(:,:,thisZ));
        end
        counter = counter + 1;
    end
    
    roiZ = 1;
    for thisZ = baseZ+startZ:baseZ+stopZ
        fullMaskImg(:,:,thisZ) = fullMaskImg(:,:,thisZ) + partMaskImg{thisROI}(:,:,roiZ);
        roiZ = roiZ + 1;
    end
    
    counter = 1;
    if ~isempty(measureChannels)
        for thisMeasureChannel = measureChannels
            intensityVector = thisROIIntensityShape{counter}{thisROI}(find(thisROIIntensityShape{counter}{thisROI}));
            data{thisROI}{counter}.sumPix = sum(intensityVector);
            data{thisROI}{counter}.numPix = length(intensityVector);
            data{thisROI}{counter}.meanPix = data{thisROI}{counter}.sumPix / data{thisROI}{counter}.numPix;
            data{thisROI}{counter}.stdPix = std(intensityVector);
            data{thisROI}{counter}.channel = thisMeasureChannel;
            counter = counter + 1;
        end
    else
        data{thisROI}{counter}.sumPix = [];
        data{thisROI}{counter}.numPix = [];
        data{thisROI}{counter}.meanPix = [];
        data{thisROI}{counter}.stdPix = [];
        data{thisROI}{counter}.channel = [];
    end

    counter = 1;
    if ~isempty(measureAroundChannels)
        for thisMeasureAroundChannel = measureAroundChannels
            intensityAroundVector = thisAroundROIIntensityShape{counter}{thisROI}(find(thisAroundROIIntensityShape{counter}{thisROI}));
            dataAround{thisROI}{counter}.sumPix = sum(intensityAroundVector);
            dataAround{thisROI}{counter}.numPix = length(intensityAroundVector);
            dataAround{thisROI}{counter}.meanPix = dataAround{thisROI}{counter}.sumPix / dataAround{thisROI}{counter}.numPix;
            dataAround{thisROI}{counter}.stdPix = std(intensityAroundVector);
            dataAround{thisROI}{counter}.channel = thisMeasureAroundChannel;
            counter = counter + 1;
        end
    else
        dataAround{thisROI}{counter}.sumPix = [];
        dataAround{thisROI}{counter}.numPix = [];
        dataAround{thisROI}{counter}.meanPix = [];
        dataAround{thisROI}{counter}.stdPix = [];
        dataAround{thisROI}{counter}.channel = [];
    end


        
   
    %     else
    %         counter = 1;
    %         for thisMeasureChannel = measureChannels(2:end)
    %             intensityVector = reshape(thisROIIntensityShape{thisMeasureChannel}{thisROI},1,[]);
    %             data{thisROI}{counter}.sumPix = sum(intensityVector);
    %             data{thisROI}{counter}.numPix = length(find(intensityVector));
    %             data{thisROI}{counter}.meanPix = data{thisROI}{thisMeasureChannel}.sumPix / data{thisROI}{thisMeasureChannel}.numPix;
    %             data{thisROI}{counter}.stdPix = std(intensityVector);
    %             counter = counter + 1;
    %         end
    %    end

end
fullMaskImg = fullMaskImg.*255;
clear('patchMasks');
clear('intensityVector');
clear('partMaskImg');
clear('thisROIIntensityShape');
end