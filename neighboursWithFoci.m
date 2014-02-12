function cellProps = neighboursWithFoci(cellProps)

numCells = length(cellProps);
for thisCell = 1:numCells
    numNeighbours = cellProps{thisCell}.numNeighbours;
    neighboursWithFoci = 0;
    perCentWithFoci = 0;
    if numNeighbours > 0
        neighbours = cellProps{thisCell}.neighbours;
        for thisNeighbour = 1:numNeighbours
            neighbourIdx = neighbours(thisNeighbour);
            if cellProps{neighbourIdx}.numFoci > 0
                neighboursWithFoci = neighboursWithFoci + 1;
            end
        end
        perCentWithFoci = (neighboursWithFoci/numNeighbours)*100;
    end
    cellProps{thisCell}.neighboursWithFoci = neighboursWithFoci;
    cellProps{thisCell}.perCentNeighboursWithFoci = perCentWithFoci;
end