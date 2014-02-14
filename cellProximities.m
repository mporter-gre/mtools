function cellProps = cellProximities(cellProps, gfpSegBWL)
%Find all cells within 50px of each cell.

%Fish out the cell neighbours
% cellVals = unique(gfpSegBWL(gfpSegBWL>0));
numCells = length(cellProps);
[sizeX, sizeY, sizeZ] = size(gfpSegBWL);

for thisCell = 1:numCells
    if ~isempty(cellProps{thisCell}.neighbours)
        cellNeighbours{thisCell,:} = cellProps{thisCell}.neighbours;
    else
        cellNeighbours{thisCell,:} = 0;
    end
    centroids(thisCell,:) = cellProps{thisCell}.centroid;
end

%Get the pixels for valid cells neighbouring each cell.
% numCells = length(cellVals);
for thisCell = 1:numCells
    thisCellPxLoc = [];
    %     thisCellVal = gfpSegBWL(centroids(thisCell, 1), centroids(thisCell, 2), centroids(thisCell, 3));
    %     thisCellPxInd = find(gfpSegBWL==thisCellVal);
    thisCellVal = cellProps{thisCell}.cellVal;
    thisCellPxInd = find(gfpSegBWL==thisCellVal);
    [thisCellPxLoc(:,1), thisCellPxLoc(:,2), thisCellPxLoc(:,3)] = ind2sub([sizeY sizeX sizeZ], thisCellPxInd);
    thisCellNeighbours = cellNeighbours{thisCell,:};
    numNeighbours = cellProps{thisCell}.numNeighbours;
    cellProxPxCoord = [];
    neighbourProxPxCoord = [];
    neighbourDist = [];
    if numNeighbours > 0
        for thisNeighbour = 1:numNeighbours
            thisNeighbourPxLoc = [];
            %             thisNeighbourCentroid = cellProps{thisCellNeighbours(thisNeighbour)}.centroid;
            %             thisNeighbourVal = gfpSegBWL(thisNeighbourCentroid(1), thisNeighbourCentroid(2), thisNeighbourCentroid(3));
            thisNeighbourVal = cellProps{thisCellNeighbours(thisNeighbour)}.cellVal;
            thisNeighbourPxInd = find(gfpSegBWL==thisNeighbourVal);
            [thisNeighbourPxLoc(:,1), thisNeighbourPxLoc(:,2), thisNeighbourPxLoc(:,3)] = ind2sub([sizeY sizeX sizeZ], thisNeighbourPxInd);
            neighbourPxDist = pdist2(thisCellPxLoc, thisNeighbourPxLoc);
            [cellPxIdx, neighbourPxIdx] = find(neighbourPxDist==min2(neighbourPxDist));
            if length(cellPxIdx) > 1
                pxIdx = round(length(cellPxIdx)/2);
                cellPxIdx = cellPxIdx(pxIdx);
                neighbourPxIdx = neighbourPxIdx(pxIdx);
            end
            cellProxPxCoord(thisNeighbour,:) = thisCellPxLoc(cellPxIdx,:);
            neighbourProxPxCoord(thisNeighbour,:) = thisNeighbourPxLoc(neighbourPxIdx,:);
            neighbourDist(thisNeighbour) = pdist([cellProxPxCoord(thisNeighbour,:); neighbourProxPxCoord(thisNeighbour,:)]);
        end
    else
        neighbourDist(1) = inf;
        cellProxPxCoord = [inf inf inf];
    end
    cellProps{thisCell}.neighbourDist = neighbourDist;
    cellProps{thisCell}.cellProxPxCoords = cellProxPxCoord;
    
    %Measure the distance from these proximity coords to foci centroids.
    numFoci = cellProps{thisCell}.numFoci;
    proxToFocusDist = [];
    if numFoci > 0
        for thisFocus = 1:numFoci
            focusCentroid = cellProps{thisCell}.focusCentroid(thisFocus,:);
            for thisNeighbour = 1:numNeighbours
                proxCoord = cellProxPxCoord(thisNeighbour,:);
                proxToFocusDist(thisFocus, thisNeighbour) = pdist([focusCentroid; proxCoord]);
            end
        end
    else
        proxToFocusDist(1,1) = inf;
    end
    cellProps{thisCell}.proxToFocusDist = proxToFocusDist;
end
        
    
    
%     workImg = zeros(sizeY, sizeX, numZ);
%     workImg(gfpSegBWL==cellVals(thisCell)) = 1;
%     [row, col] = find(workImg);
%     numPx = length(row);
%     if numPx < 200 || numPx > 1800
%         continue;
%     end

%     
% end
% 
% for thisCell = 1:numCells
%     thisCentroid = cellCentroids(thisCell, :);
%     cellDistances = pdist2(thisCentroid, cellCentroids);
%     idx = find(cellDistances>0.001 & cellDistances<50);
%     cellProps{thisCell}.neighbours = idx;
% end
