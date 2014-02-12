function cellProps = TssBAnalysis(gfpStack, TssBStack)

[sizeY, sizeX, numZ] = size(gfpStack);
gfpSeg = fpBacteriaSeg3D(gfpStack);
TssBSeg = fpBacteriaSeg3D(TssBStack);

gfpSegBWL = bwlabeln(gfpSeg);
TssBSegBWL = bwlabeln(TssBSeg);

cellVals = unique(gfpSegBWL(gfpSegBWL>0));
numCells = length(cellVals);

%cellProps = cell(1,numCells);
cellCounter = 1;

for thisCell = 1:numCells
    workImg = zeros(sizeY, sizeX, numZ);
    workImg(gfpSegBWL==cellVals(thisCell)) = 1;
    [row, col] = find(workImg);
    numPx = length(row);
    if numPx < 200 || numPx > 1800
        continue;
    end
    cellProps{cellCounter}.numPx = numPx;
    
    %Centroid of cell
    zProj = logical(sum(workImg,3));
    yProj = logical(squeeze(sum(workImg,1)));
    [Y, X] = find(zProj);
    [~, Z] = find(yProj);
    meanX = int16(mean(X));
    meanY = int16(mean(Y));
    meanZ = int16(mean(Z));
    cellCentroid = double([meanX meanY meanZ]);
    cellProps{cellCounter}.centroid = cellCentroid;
    
    %Using regoinprops...
    thisCellProps = regionprops(workImg(:,:,meanZ), 'Area', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Extrema');
    cellProps{cellCounter}.props = thisCellProps;
    
    %Find the foci associated with this cell
    overlap = TssBSegBWL.*workImg;
    TssBOutsideCells = TssBSegBWL-overlap;
    fociIds = unique(overlap(overlap>0));
    numFoci = length(fociIds);
    cellProps{cellCounter}.numFoci = numFoci;
    numFocusPxInCell = [];
    numFocusPxOutsideCell = [];
    numFocusPx = [];
    focusCentroid = [];
    fDist = [];
    
    %Properties of foci associated with this cell
    for thisFocus = 1:numFoci
        %numPx...
        numFocusPxInCell(thisFocus) = length(find(overlap==fociIds(thisFocus)));
        numFocusPxOutsideCell(thisFocus) = length(find(TssBOutsideCells==fociIds(thisFocus)));
        numFocusPx(thisFocus) = numFocusPxInCell(thisFocus) + numFocusPxOutsideCell(thisFocus);
        
        %Get the centroid of the focus....
        focusImg = zeros(sizeY, sizeX, numZ);
        focusImg(TssBSegBWL==fociIds(thisFocus)) = 1;
        zProj = logical(sum(focusImg, 3));
        yProj = logical(squeeze(sum(focusImg,1)));
        [Y, X] = find(zProj);
        [~, Z] = find(yProj);
        meanX = int16(mean(X));
        meanY = int16(mean(Y));
        meanZ = int16(mean(Z));
        focusCentroid(thisFocus,:) = double([meanX meanY meanZ]);
        
        %Distance of the focus from cell centroid
        fDist(thisFocus) = pdist([cellCentroid; focusCentroid(thisFocus,:)]);
        
    end
    
    cellProps{cellCounter}.numFocusPxInCell = numFocusPxInCell;
    cellProps{cellCounter}.numFocusPxOutsideCell = numFocusPxOutsideCell;
    cellProps{cellCounter}.numFocusPx = numFocusPx;
    cellProps{cellCounter}.focusCentroid = focusCentroid;
    cellProps{cellCounter}.focusDistance = fDist;
    
    cellCounter = cellCounter + 1;
end