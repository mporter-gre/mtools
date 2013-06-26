function addShapeAndUpdate(roi, shapeObj)
%addShapeAndUpdate(roi, shapeObj)

global session
global iUpdate

if ~isjava(iUpdate)
    iUpdate = session.getUpdateService;
end

roi.addShapeData(shapeObj);
iUpdate.saveObject(roi.asIObject)