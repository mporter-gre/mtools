function vectorOut = deleteElementFromVector(elementsForDeletion, vector)
%Use to remove an entry from a vector keeping the order of the other
%elements in tact with no gaps. [1 2 3 4 5] becomes [1 2 4 5] and not 
%[1 2 [] 4 5] eg.
%Do vectorOut = deleteElementFromVector(element, vector); where 'element' is
%the entry to be deleted. A vector of elements to be deleted can also be
%passed in.

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
