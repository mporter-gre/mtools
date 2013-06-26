function roiObj = buildROIObj(roiShapes)
%Build up an Omero roi object from an roiShapes structure. Each shape is a
%field in the roiShapes cell that is passed to this method.
%roiObj = buildROIObj(roiShapes)

numShapes = roiShapes.numShapes;
roiObj = pojos.ROIData;
for thisShape = 1:numShapes
    shapeObj = roiShapes.(['shape' num2str(thisShape)]);
    roiObj.addShapeData(shapeObj);
end
            
