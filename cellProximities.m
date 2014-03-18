function cellProps = cellProximities(cellProps, gfpSegBWL)
%Find all cells within 50px of each cell.

% Copyright (C) 2013-2014 University of Dundee & Open Microscopy Environment.
% All rights reserved.
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
            
            %Discount neighbours with a distance greater than 8px. These
            %cells are not touching.
            if neighbourDist(thisNeighbour) > 8
                neighbourDist(thisNeighbour) = inf;
                cellProxPxCoord(thisNeighbour,:) = [inf inf inf];
            end
            if neighbourDist(thisNeighbour) == 0
                disp('zero')
            end
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