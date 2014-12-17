function patch = getPatchFromRectROI(session, imageId, roi, c)
%patch = getPatchFromRectROI(session, imageId, roi, c)

numShapes = roi.numShapes;
patch = [];

for thisShape = 1:numShapes
    x = floor(roi.(['shape' num2str(thisShape)]).getX.getValue);
    y = floor(roi.(['shape' num2str(thisShape)]).getY.getValue);
    w = roi.(['shape' num2str(thisShape)]).getWidth.getValue;
    h = roi.(['shape' num2str(thisShape)]).getHeight.getValue;
    z = roi.(['shape' num2str(thisShape)]).getTheZ.getValue;
    t = roi.(['shape' num2str(thisShape)]).getTheT.getValue;
    
    shapePatch = getTile(session, imageId, z, c, t, x, y, w, h);
    patch(:,:,end+1) = shapePatch;
end

patch(:,:,1) = [];


    