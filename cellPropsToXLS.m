function cellData = cellPropsToXLS(cellProps, imageName)

numCells = length(cellProps);
rowCounter = 1;
cellData = {};
cellData = {'Image Name', 'Cell Num', 'Num Neighbours', 'Num Foci', 'Neighbour Distance'};
for thisCell = 1:numCells
    numNeighbours = cellProps{thisCell}.numNeighbours;
    if numNeighbours > 0
        for thisNeighbour = 1:numNeighbours
            cellData = [cellData; {imageName, thisCell, numNeighbours, cellProps{thisCell}.numFoci, cellProps{thisCell}.neighbourDist(thisNeighbour)}];
        end
    else
        cellData = [cellData; {imageName, thisCell, numNeighbours, cellProps{thisCell}.numFoci, 0}];
    end
   
    
   
    
end