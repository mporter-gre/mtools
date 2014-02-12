function cellPropsToXLS(cellProps, imageName)

numCells = length(cellProps);
rowCounter = 1;
cellData = {'Image name', 'Cell', 'Size', 'Length', 'Num foci', 'Num Neighbours', 'Neighbours with foci', '% Neighbours with foci'};

for thisCell = 1:numCells
    props = cellProps{thisCell};
    cellData = [cellData; {imageName, thisCell, props.numPx, props.props.MajorAxisLength, props.numFoci, props.numNeighbours, props.neighboursWithFoci, props.perCentNeighboursWithFoci}];
end

neighbourData = {'Image name', 'Cell', 'Distance to neighbours'};
for thisCell = 1:numCells
    props = cellProps{thisCell};
    numNeighbours = props.numNeighbours;
    if numNeighbours > 0
        for thisNeighbour = 1:numNeighbours
            neighbourData = [neighbourData; {imageName, thisCell, props.neighbourDist(thisNeighbour)}];
        end
    else
        neighbourData = [neighbourData; {imageName, thisCell, 0}];
    end
end


focusData = {'Image name', 'Cell', 'Focus', 'Focus size', 'Focus Px in cell', 'Focus Px outside cell', 'Focus location %length', 'Focus distance to closest neighbour point'};
for thisCell = 1:numCells
    props = cellProps{thisCell};
    numFoci = props.numFoci;
    numNeighbours = props.numNeighbours;
    for thisFocus = 1:numFoci
        if numNeighbours > 0
            for thisNeighbour = 1:numNeighbours
                focusData = [focusData; {imageName, thisCell, thisFocus, props.numFocusPx(thisFocus), props.numFocusPxInCell(thisFocus), props.numFocusPxOutsideCell(thisFocus), props.focusPosition(thisFocus), props.proxToFocusDist(thisFocus, thisNeighbour)}];
            end
        else
            focusData = [focusData; {imageName, thisCell, thisFocus, props.numFocusPx(thisFocus), props.numFocusPxInCell(thisFocus), props.numFocusPxOutsideCell(thisFocus), props.focusPosition(thisFocus), 0}];
        end
    end
end

xlswrite(imageName, cellData, 'Cell Data');
xlswrite(imageName, neighbourData, 'Neighbour Data');
xlswrite(imageName, focusData, 'Focus Data');

end