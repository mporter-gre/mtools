function cellProps = TssBRunAnalysis(gfpStack, TssBStack, progress, progressFraction, datasetId, imageName)

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

global session;

waitbar(progressFraction, progress, 'Defining cells');
[sizeY, sizeX, numZ] = size(gfpStack);
middleZ = round(numZ/2);
gfpSeg = zeros(sizeY, sizeX, numZ);
%gfpSeg(:,:,middleZ-1:middleZ+1) = fpBacteriaSeg3D(gfpStack(:,:,middleZ-1:middleZ+1));
gfpSeg = fpBacteriaSeg3D(gfpStack);

TssBSeg = zeros(size(TssBStack));

%st = strel('disk', 1);

gfpSegBWL = bwlabeln(gfpSeg);
% gfpSegBWL = imdilate(gfpSegBWL, st);
% gfpSegBWL = imdilate(gfpSegBWL, st);
% gfpSegBWL = imdilate(gfpSegBWL, st);


cellVals = unique(gfpSegBWL(gfpSegBWL>0));
numCells = length(cellVals);

props = regionprops(gfpSegBWL, 'BoundingBox');
zStarts = [];
zEnds = [];
for thisCell = 1:numCells
    zStarts(end+1) = props(thisCell).BoundingBox(3);
    zEnds(end+1) = zStarts(end) + props(thisCell).BoundingBox(6);
end

minZ = ceil(min(zStarts));
maxZ = floor(max(zEnds));
    


% for thisCell = 1:numCells
%     x = floor(props(thisCell).BoundingBox(1));
%     y = floor(props(thisCell).BoundingBox(2));
%     z = floor(props(thisCell).BoundingBox(3));
%     w = floor(props(thisCell).BoundingBox(4));
%     h = floor(props(thisCell).BoundingBox(5));
%     d = floor(props(thisCell).BoundingBox(6));
%     
%     if x == 0
%         x = 1;
%     end
%     if y == 0
%         y = 1;
%     end
%     if z == 0
%         z = 1;
%     end
%     
%     
%     cellSegBWL = gfpSegBWL(y:y+h-1,x:x+w-1,z:z+d-1);
%     cellSegBWL(cellSegBWL~=thisCell) = 0;
%     %greenCell = gfpStacl(y:y+h,x:x+w,z:z+d);
%     redCell = TssBStack(y:y+h-1,x:x+w-1,z:z+d-1);
%     redCellSeg = zeros(size(redCell));
%         
%     redCell(cellSegBWL==0) = mean(redCell(cellSegBWL==thisCell));
%     redCellVals = unique(redCell(cellSegBWL==thisCell));
%     redValsEdge = edge(redCellVals);
%     edgeIdx = find(redValsEdge);
%     numPx = length(redCellVals);
%     numEdgeIdx = length(edgeIdx);
%     if isempty(numEdgeIdx)
%         continue;
%     end
%     for thisIdx = 1:numEdgeIdx
%         if edgeIdx(thisIdx) > numPx/2
%             redCellSeg(redCell>=redCellVals(edgeIdx(thisIdx))) = 1;
%             TssBSeg(y:y+h-1,x:x+w-1,z:z+d-1) = TssBSeg(y:y+h-1,x:x+w-1,z:z+d-1) + redCellSeg;
%             continue;
%         end
%     end    
% end
   

%TssBSeg = fpBacteriaSeg3D(TssBStack);
for thisZ = minZ:maxZ
    TssBSeg(:,:,thisZ) = logical(LoGBlob(double(TssBStack(:,:,thisZ)), 7, 10, 30, 100000));
    %TssBSeg(:,:,thisZ) = logical(TssBSeg(:,:,thisZ) + LoGBlob(double(TssBStack(:,:,thisZ)), 7, 10, 1000));
end
TssBSegBWL = bwlabeln(TssBSeg);

%Remove small foci (<21px)
focusProps = regionprops(TssBSegBWL, 'Area', 'BoundingBox');
focusVals = unique(TssBSegBWL(TssBSegBWL>0));
numFoci = length(focusProps);
axisLengths = [];
ecces = [];
for thisFocus = 1:numFoci
    
    
%     if focusProps(thisFocus).Area < 21 || focusProps(thisFocus).Area > 1000
%         TssBSegBWL(TssBSegBWL==focusVals(thisFocus)) = 0;
%         %disp('continued');
%         continue;
%     end
    
    x = floor(focusProps(thisFocus).BoundingBox(1));
    y = floor(focusProps(thisFocus).BoundingBox(2));
    z = floor(focusProps(thisFocus).BoundingBox(3));
    w = floor(focusProps(thisFocus).BoundingBox(4));
    h = floor(focusProps(thisFocus).BoundingBox(5));
    d = floor(focusProps(thisFocus).BoundingBox(6));
    
    if x == 0
        x = 1;
    end
    if y == 0
        y = 1;
    end
    if z == 0
        z = 1;
    end
    
%     if focusProps(thisFocus).BoundingBox(6) < 3 % || focusProps(thisFocus).BoundingBox(4) > 11 || focusProps(thisFocus).BoundingBox(5) > 11
%         TssBSegBWL(TssBSegBWL==focusVals(thisFocus)) = 0;
%         continue;
%     end

    %Filter out cases where high background in the cell segments out the
    %width of the cell
    redCellSeg = TssBSegBWL(y:y+h-1,x:x+w-1,:);
    redCellSeg(redCellSeg~=focusVals(thisFocus)) = 0;
    redCellSegProj = sum(redCellSeg, 3);
    boxProps = regionprops(logical(redCellSegProj), 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity');
    
    if isempty(boxProps)
        continue;
    end
    numBlobs = length(boxProps);
    majAxis = [];
    if numBlobs > 1
        for thisBlob = 1:numBlobs
            majAxis(end+1) = boxProps(thisBlob).MajorAxisLength;
            ecces(end+1) = boxProps(thisBlob).Eccentricity;
        end
        MajorAxisLength = max(majAxis);
        Eccentricity = max(ecces);
    else
        MajorAxisLength = boxProps.MajorAxisLength;
        Eccentricity = boxProps.Eccentricity;
    end
    axisLengths(end+1) = MajorAxisLength;
    if MajorAxisLength > 15 || Eccentricity > 0.9
        TssBSegBWL(TssBSegBWL==focusVals(thisFocus)) = 0;
    end
end
        



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

%Save the intensity planes PLUS the segmentation planes back to the server.
store = session.createRawPixelsStore;
imageName = [imageName '_masks'];
[newImage, newPixels] = createImage(session, sizeX, sizeY, numZ, 4, 1, 'uint16', 'XYZCT', imageName, datasetId);
newPixelsId = newPixels.getId.getValue;
store.setPixelsId(newPixelsId, false);

gfp = gfpSegBWL;
gfp(gfp>0) = 1000;
cherry = TssBSegBWL;
cherry(cherry>0) = 1000;

for thisZ = 1:numZ
    planeAsBytes = toByteArray(uint16(gfpStack(:,:,thisZ))', newPixels);
    store.setPlane(planeAsBytes, thisZ-1, 0, 0);
    planeAsBytes = toByteArray(uint16(TssBStack(:,:,thisZ))', newPixels);
    store.setPlane(planeAsBytes, thisZ-1, 1, 0);
    planeAsBytes = toByteArray(uint16(gfp(:,:,thisZ))', newPixels);
    store.setPlane(planeAsBytes, thisZ-1, 2, 0);
    planeAsBytes = toByteArray(uint16(cherry(:,:,thisZ))', newPixels);
    store.setPlane(planeAsBytes, thisZ-1, 3, 0);
end
store.save();
store.close();

%Now set the render settings for each channel
renderingEngine = session.createRenderingEngine;
renderingEngine.lookupPixels(newPixelsId);
renderingEngine.resetDefaultSettings(1);
renderingEngine.lookupRenderingDef(newPixelsId);
renderingEngine.load();

renderingEngine.setActive(0,1);
renderingEngine.setChannelWindow(0, 120, 1000);
renderingEngine.setChannelWindow(1, 120, 1000);
renderingEngine.setChannelWindow(2, 0, 2000);
renderingEngine.setChannelWindow(3, 0, 2000);
renderingEngine.setRGBA(0, 0, 255, 0, 255);
renderingEngine.setRGBA(1, 255, 0, 0, 255);
renderingEngine.setRGBA(2, 0, 0, 255, 255);
renderingEngine.setRGBA(3, 0, 0, 255, 255);

renderingEngine.saveCurrentSettings;
renderingEngine.close();

%Set the channel names
pixServiceDescription = session.getPixelsService.retrievePixDescription(newPixelsId).getChannel(0).getLogicalChannel();
pixServiceDescription.setName(omero.rtypes.rstring('gfp'));
iUpdate = session.getUpdateService();
iUpdate.saveObject(pixServiceDescription);

pixServiceDescription = session.getPixelsService.retrievePixDescription(newPixelsId).getChannel(1).getLogicalChannel();
pixServiceDescription.setName(omero.rtypes.rstring('cherry'));
iUpdate = session.getUpdateService();
iUpdate.saveObject(pixServiceDescription);

pixServiceDescription = session.getPixelsService.retrievePixDescription(newPixelsId).getChannel(2).getLogicalChannel();
pixServiceDescription.setName(omero.rtypes.rstring('gfpSeg'));
iUpdate = session.getUpdateService();
iUpdate.saveObject(pixServiceDescription);

pixServiceDescription = session.getPixelsService.retrievePixDescription(newPixelsId).getChannel(3).getLogicalChannel();
pixServiceDescription.setName(omero.rtypes.rstring('cherrySeg'));
iUpdate = session.getUpdateService();
iUpdate.saveObject(pixServiceDescription);

cellProps = cellNeighbours(cellProps);
waitbar(progressFraction, progress, 'Measuring proximities');
cellProps = cellProximities(cellProps, gfpSegBWL);
cellProps = neighboursWithFoci(cellProps);
