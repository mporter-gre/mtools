function idx = findIndex(cellsIn)
%Find the index of the value 1 in a cell array

numCells = length(cellsIn);

for idx = 1:numCells
    if cellsIn{idx} == 1
        break;
    end
end