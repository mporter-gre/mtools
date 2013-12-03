function timePoints = getROITimePoints(roiShapes)
%Get the unique timepoints for a structure of roiShapes.
%timePoints = getROITimePoints(roiShapes);

sortedShapes = sortROIShapes(roiShapes, 'byT');
theTs = [];
numShapes = roiShapes.numShapes;
for thisShape = 1:numShapes
    theTs(thisShape) = roiShapes.(['shape' num2str(thisShape)]).getTheT.getValue;
end
timePoints = unique(theTs);
