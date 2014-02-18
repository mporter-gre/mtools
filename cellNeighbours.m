function cellProps = cellNeighbours(cellProps)
%Find all cells within 50px of each cell.

numCells = length(cellProps);
cellCentroids = [];

for thisCell = 1:numCells
    cellCentroids(thisCell,:) = cellProps{thisCell}.centroid;
end

for thisCell = 1:numCells
    thisCentroid = cellCentroids(thisCell, :);
    cellDistances = pdist2(thisCentroid, cellCentroids);
    idx = find(cellDistances>0.001 & cellDistances<7);
    cellProps{thisCell}.neighbours = idx;
    if length(idx)==1 && idx==0
        cellProps{thisCell}.numNeighbours = 0;
    else
        cellProps{thisCell}.numNeighbours = length(idx);
    end
end
