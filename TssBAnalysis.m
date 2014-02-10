function cellProps = TssBAnalysis(gfpStack, TssBStack)

[sizeY, sizeX, numZ] = size(gfpStack);
gfpSeg = fpBacteriaSeg3D(gfpStack);
TssBSeg = fpBacteriaSeg3D(TssBStack);

gfpSegBWL = bwlabeln(gfpSeg);
TssBSegBWL = bwlabeln(TssBSeg);

cellVals = unique(gfpSegBWL(gfpSegBWL>0));
numCells = length(cellVals);
cellCentre = [];

for thisCell = 1:numCells
    numPix = [];
    workImg = zeros(sizeY, sizeX, numZ);
    workImg(gfpSegBWL==cellVals(thisCell)) = 1;
    zProj = logical(sum(workImg,3));
    yProj = logical(squeeze(sum(workImg,1)));
    [Y, X] = find(zProj);
    [~, Z] = find(yProj);
    meanX = int16(mean(X));
    meanY = int16(mean(Y));
    meanZ = int16(mean(Z));
    cellProps{thisCell}.centroid = [meanX meanY meanZ];
    
end