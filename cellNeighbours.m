function cellProps = cellNeighbours(cellProps)
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
