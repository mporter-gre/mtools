function vectorOut = deleteElementFromVector(elementsForDeletion, vector)
%Use to remove an entry from a vector keeping the order of the other
%elements in tact with no gaps. [1 2 3 4 5] becomes [1 2 4 5] and not 
%[1 2 [] 4 5] eg.
%Do vectorOut = deleteElementFromVector(element, vector); where 'element' is
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
    vectorOut = vector;
    return;
end
numToBeDeleted = length(elementsForDeletion);
for thisDelete = 1:numToBeDeleted
    element = elementsForDeletion(end);
    numElements = length(vector);
    if numElements < 2
        vectorOut = [];
        return;
    end
    if element ~= numElements
        for thisElement = element:numElements-1
            vector(thisElement) = vector(thisElement+1);
        end
        for thisElement = 1:numElements-1
            editedVector(thisElement) = vector(thisElement);
        end
        vectorOut = editedVector;
        vector = vectorOut;
    else
        for thisElement = 1:numElements-1
            editedVector(thisElement) = vector(thisElement);
        end
        vectorOut = editedVector;
        vector = vectorOut;
    end
    editedVector = [];
    elementsForDeletion = elementsForDeletion(1:end-1);
end
