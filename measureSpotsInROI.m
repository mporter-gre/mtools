function dataOut = measureSpotsInROI(imageId, imageName, dsId, minSize, c, saveMasks)
%dataOut = measureSpotsInROI(imageId, c);

global session;
%iUpdate = session.getUpdateService();

rois = getROIsFromImageId(imageId);

numROIs = length(rois);
if numROIs == 0
    dataOut = [];
    return;
end


for thisROI = 1:numROIs
    patchStack{thisROI} = getPatchFromRectROI(session, imageId, rois{thisROI}, c);
    segStack{thisROI} = spotSeg3D(patchStack{thisROI});
    segStackBWL{thisROI} = bwlabeln(segStack{thisROI});
    props{thisROI} = regionprops(segStackBWL{thisROI}, 'Area');
    
    numSpots = length(props{thisROI});
    
    if numSpots == 0
        continue;
    end
    
    for thisSpot = 1:numSpots
        if props{thisROI}(thisSpot).Area < minSize
            segStack{thisROI}(segStackBWL{thisROI}==thisSpot) = 0;
        end
    end
        
    segStackBWL{thisROI} = bwlabeln(segStack{thisROI});
    props{thisROI} = regionprops(segStackBWL{thisROI}, 'Area');
    
    %Try to make a mask ROI in OMERO
%     x = rois{thisROI}.shape1.getX.getValue;
%     y = rois{thisROI}.shape1.getY.getValue;
%     z = rois{thisROI}.shape1.getTheZ.getValue;
%     t = rois{thisROI}.shape1.getTheT.getValue;
    
%     maskStack = createMask(x, y, segStack);
%     shape = setShapeCoordinates(maskStack, z, c, t);
%     newRoi = omero.model.RoiI;
%     newRoi.addShape(shape);
%     newRoi.setImage(omero.model.ImageI(imageId, false));
%     newRoi = iUpdate.saveAndReturnObject(newRoi);
end

%Move this all to another function when it's working...
if saveMasks == 1
    maskImg = createMaskImageFromROIPatches(segStack, rois, 1024, 1024, 18);
    saveMaskImage(maskImg, [imageName '_masks'], dsId);
end


dataOut = props;