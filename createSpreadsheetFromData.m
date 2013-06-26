function createSpreadsheetFromData(dataIn, header, filename)

[sizeY sizeX] = size(dataIn);
dimY = ones(sizeY,1);
dimX = ones(1,sizeX);
if ~iscell(dataIn)
    dataCell = mat2cell(dataIn, dimY, dimX);
else
    dataCell = dataIn;
end
dataCellOut = [header; dataCell];

xlswrite(filename, dataCellOut);
