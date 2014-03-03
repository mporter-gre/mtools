function cellPropsToXLS(cellProps, imageName)

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


focusData = {'Image name', 'Cell', 'Focus', 'Focus size', 'Focus Px in cell', 'Focus Px outside cell', 'Focus location %length'};
for thisCell = 1:numCells
    props = cellProps{thisCell};
    numFoci = props.numFoci;
    for thisFocus = 1:numFoci
        focusData = [focusData; {imageName, thisCell, thisFocus, props.numFocusPx(thisFocus), props.numFocusPxInCell(thisFocus), props.numFocusPxOutsideCell(thisFocus), props.focusPosition(thisFocus)}];
    end
end



focusNeighbourData = {'Image name', 'Cell', 'Focus', 'Focus distance to closest neighbour point'};
for thisCell = 1:numCells
    props = cellProps{thisCell};
    numFoci = props.numFoci;
    numNeighbours = props.numNeighbours;
    for thisFocus = 1:numFoci
        if numNeighbours > 0
            for thisNeighbour = 1:numNeighbours
                focusNeighbourData = [focusNeighbourData; {imageName, thisCell, thisFocus, props.proxToFocusDist(thisFocus, thisNeighbour)}];
            end
        end
    end
end

xlswrite([imageName '.xls'], cellData, 'Cell Data');
xlswrite([imageName '.xls'], neighbourData, 'Neighbour Data');
xlswrite([imageName '.xls'], focusData, 'Focus Data');
xlswrite([imageName '.xls'], focusNeighbourData, 'Focus Neighbour Data');


end
