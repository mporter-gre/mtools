function cellProps = TssBRunAnalysis(gfpStack, TssBStack, progress, progressFraction)

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

waitbar(progressFraction, progress, 'Defining cells');
[sizeY, sizeX, numZ] = size(gfpStack);
gfpSeg = fpBacteriaSeg3D(gfpStack);
TssBSeg = fpBacteriaSeg3D(TssBStack);

gfpSegBWL = bwlabeln(gfpSeg);
TssBSegBWL = bwlabeln(TssBSeg);

cellVals = unique(gfpSegBWL(gfpSegBWL>0));
numCells = length(cellVals);

%cellProps = cell(1,numCells);
cellCounter = 1;
waitbar(progressFraction, progress, 'Measuring cells');
for thisCell = 1:numCells
    workImg = zeros(sizeY, sizeX, numZ);
    workImg(gfpSegBWL==cellVals(thisCell)) = 1;
    [row, col] = find(workImg);
    numPx = length(row);
    if numPx < 200 || numPx > 1800
        continue;
    end
    cellProps{cellCounter}.numPx = numPx;
    cellProps{cellCounter}.cellVal = cellVals(thisCell);
    
    %Centroid of cell
    zProj = logical(sum(workImg,3));
    yProj = logical(squeeze(sum(workImg,1)));
    [Y, X] = find(zProj);
    [~, Z] = find(yProj);
    meanX = int16(mean(X));
    meanY = int16(mean(Y));
    meanZ = int16(mean(Z));
    cellCentroid = double([meanY meanX meanZ]);
    cellProps{cellCounter}.centroid = cellCentroid;
    
    %Using regoinprops...
    thisCellProps = regionprops(workImg(:,:,meanZ), 'Area', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');
    cellProps{cellCounter}.props = thisCellProps;
    
    %Find the foci associated with this cell
    overlap = TssBSegBWL.*workImg;
    TssBOutsideCells = TssBSegBWL-overlap;
    fociIds = unique(overlap(overlap>0));
    if ~isempty(fociIds)
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
            focusCentroid(thisFocus,:) = double([meanY meanX meanZ]);
            
            %Distance of the focus from cell centroid
            fDist(thisFocus) = pdist([cellCentroid; focusCentroid(thisFocus,:)]);
            majorAxis = cellProps{cellCounter}.props.MajorAxisLength;
            halfLength = majorAxis/2;
            focusPosition(thisFocus) = (fDist(thisFocus)/halfLength)*100;
            
        end
        
        cellProps{cellCounter}.numFocusPxInCell = numFocusPxInCell;
        cellProps{cellCounter}.numFocusPxOutsideCell = numFocusPxOutsideCell;
        cellProps{cellCounter}.numFocusPx = numFocusPx;
        cellProps{cellCounter}.focusCentroid = focusCentroid;
        cellProps{cellCounter}.focusDistance = fDist;
        cellProps{cellCounter}.focusPosition = focusPosition;
    else
        cellProps{cellCounter}.numFoci = 0;
        cellProps{cellCounter}.numFocusPxInCell = 0;
        cellProps{cellCounter}.numFocusPxOutsideCell = 0;
        cellProps{cellCounter}.numFocusPx = 0;
        cellProps{cellCounter}.focusCentroid = 0;
        cellProps{cellCounter}.focusDistance = 0;
        cellProps{cellCounter}.focusPosition = 0;
    end
    
    cellCounter = cellCounter + 1;
end

cellProps = cellNeighbours(cellProps);
waitbar(progressFraction, progress, 'Measuring proximities');
cellProps = cellProximities(cellProps, gfpSegBWL);
cellProps = neighboursWithFoci(cellProps);
