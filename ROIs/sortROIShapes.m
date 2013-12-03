function sortedShapes = sortROIShapes(roiShapes, sorting)
%By default ROI shapes are returned sorted by id. Sort them into Z by doing
%sortedShapes = sortROIShapes(roiShapes, sorting), where sorting is string
%'byZ', or by T using ('byT'). Sort by one then the other with strings
%'byZbyT' or 'byTbyZ'

if strcmpi(sorting, 'byZ')
    theZs = [];
    numShapes = roiShapes.numShapes;
    for thisShape = 1:numShapes
        theZs(thisShape) = roiShapes.(['shape' num2str(thisShape)]).getTheZ.getValue;
    end
    [Zs idx] = sort(theZs);
    for thisShape = 1:numShapes
        thisIdx = idx(thisShape);
        sortedShapes.(['shape' num2str(thisShape)]) = roiShapes.(['shape' num2str(thisIdx)]);
    end
    sortedShapes.shapeType = roiShapes.shapeType;
    sortedShapes.numShapes = roiShapes.numShapes;
end

if strcmpi(sorting, 'byT')
    theTs = [];
    numShapes = roiShapes.numShapes;
    for thisShape = 1:numShapes
        theTs(thisShape) = roiShapes.(['shape' num2str(thisShape)]).getTheT.getValue;
    end
    [Ts idx] = sort(theTs);
    for thisShape = 1:numShapes
        thisIdx = idx(thisShape);
        sortedShapes.(['shape' num2str(thisShape)]) = roiShapes.(['shape' num2str(thisIdx)]);
    end
    sortedShapes.shapeType = roiShapes.shapeType;
    sortedShapes.numShapes = roiShapes.numShapes;
end

if strcmpi(sorting, 'byTbyZ')
    theTs = [];
    numShapes = roiShapes.numShapes;
    for thisShape = 1:numShapes
        theTZ(thisShape,1) = roiShapes.(['shape' num2str(thisShape)]).getTheT.getValue;
        theTZ(thisShape,2) = roiShapes.(['shape' num2str(thisShape)]).getTheZ.getValue;
    end
    [listItems, idx] = sortrows(theTZ, [1,2]);
    for thisShape = 1:numShapes
        thisIdx = idx(thisShape);
        sortedShapes.(['shape' num2str(thisShape)]) = roiShapes.(['shape' num2str(thisIdx)]);
    end
    sortedShapes.shapeType = roiShapes.shapeType;
    sortedShapes.numShapes = roiShapes.numShapes;
end

if strcmpi(sorting, 'byZbyT')
    theTs = [];
    numShapes = roiShapes.numShapes;
    for thisShape = 1:numShapes
        theZT(thisShape,1) = roiShapes.(['shape' num2str(thisShape)]).getTheT.getValue;
        theZT(thisShape,2) = roiShapes.(['shape' num2str(thisShape)]).getTheZ.getValue;
    end
    [listItems, idx] = sortrows(theZT, [2,1]);
    for thisShape = 1:numShapes
        thisIdx = idx(thisShape);
        sortedShapes.(['shape' num2str(thisShape)]) = roiShapes.(['shape' num2str(thisIdx)]);
    end
    sortedShapes.shapeType = roiShapes.shapeType;
    sortedShapes.numShapes = roiShapes.numShapes;
end

