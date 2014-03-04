function cellsOut = deleteElementFromCells(elementsForDeletion, cells)
%Use to remove an entry from an array of cells keeping the order of the other
%elements in tact with no gaps. {'one' 'two' 'three' 'four' 'five'} becomes 
%{'one' 'two' 'four' 'five'} and not {'one' 'two' {} 'four' 'five'} eg.
%Do cellsOut = deleteElementFromCells(element, cells); where 'element' is
%the entry to be deleted. A vector of elements to be deleted can also be
%passed in.

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

if isempty(elementsForDeletion)
    cellsOut = cells;
    return;
end
numToBeDeleted = length(elementsForDeletion);
for thisDelete = 1:numToBeDeleted
    element = elementsForDeletion(end);
    numElements = length(cells);
    if numElements < 2
        cellsOut = [];
        return;
    end
    if element ~= numElements
        for thisElement = element:numElements-1
            cells{thisElement} = cells{thisElement+1};
        end
        for thisElement = 1:numElements-1
            editedCells{thisElement} = cells{thisElement};
        end
        cellsOut = editedCells;
        cells = cellsOut;
    else
        for thisElement = 1:numElements-1
            editedCells{thisElement} = cells{thisElement};
        end
        cellsOut = editedCells;
        cells = cellsOut;
    end
    editedCells = {};
    elementsForDeletion = elementsForDeletion(1:end-1);
end