function stackOut = DICSegFromZRange(stackIn, minObjSize, zRange)
%stackOut = DICSeg(stackIn, minObjSize, zRange); to segment out objects in
%a z-stack of DIC images. 'minObjSize' sets the minimum number of voxels an
%object can have to aid in removing e.g. dust from the image. 'zRange' sets
%the sections that contain *some* information on all of the objects desired
%for segmentation. This allows for removal of noise in sections above and
%below the sample.
%Example: stackOut = DICSeg(myDICStack, 60, [2:5]); excludes objects less
%than 60 voxels and not containing information in sections 2 to 5. 
%Returns a labelMatrix (new version of bwlabel image).

tic
[numY, numX, numZ] = size(stackIn);
numSegZ = zRange(end) - zRange(1) +1;
segStackXY = zeros(numY,numX,numZ);
segStackXZ = zeros(numY, numX, numZ);
segStackYZ = zeros(numY, numX, numZ);
segStack = zeros(numY, numX, numZ);

means = zeros(numZ,1);
stDevs = zeros(numZ,1);
meansXZ = zeros(numX,1);
stDevsXZ = zeros(numX,1);
meansYZ = zeros(numY,1);
stDevsYZ = zeros(numY,1);

%Statistics of the stack for segmentation. Segment in all three
%orientations using the maximum means + stDev as threshold.
for thisZ = 1:numZ
    means(thisZ) = mean2(stackIn(:,:,thisZ));
    stDevs(thisZ) = std2(stackIn(:,:,thisZ));
end

for thisX = 1:numX
    meansXZ(thisX) = mean2(stackIn(:,thisX,:));
    stDevsXZ(thisX) = std2(stackIn(:,thisX,:));
end

for thisY = 1:numY
    meansYZ(thisY) = mean2(stackIn(thisY,:,:));
    stDevsYZ(thisY) = std2(stackIn(thisY,:,:));
end

maxMean = max2(means);
maxStDev = max2(stDevs);
maxValXY = maxMean + maxStDev;
maxMeanXZ = max2(meansXZ);
maxStDevXZ = max2(stDevsXZ);
maxValXZ = maxMeanXZ + maxStDevXZ;
maxMeanYZ = max2(meansYZ);
maxStDevYZ = max2(stDevsYZ);
maxValYZ = maxMeanYZ + maxStDevYZ;


for thisZ = zRange
    plane = squeeze(stackIn(:,:,thisZ));
        thisSeg = zeros(numY,numX);
        %thisSeg(plane>maxValXY) = 150;
        thisSeg(plane>(means(thisZ) + 1.1*stDevs(thisZ))) = 150;
        segStackXY(:,:,thisZ) = thisSeg;    
end


for thisX = 1:numX
    plane = squeeze(stackIn(:,thisX,zRange));
    thisSeg = zeros(numY,numSegZ);
    %thisSeg(plane>maxValXZ) = 150;
    thisSeg(plane>(meansXZ(thisX) + 1.1*stDevsXZ(thisX))) = 150;
    segStackXZ(:,thisX,zRange) = thisSeg;
end

for thisY = 1:numY
    plane = squeeze(stackIn(thisY,:,zRange));
    thisSeg = zeros(numX,numSegZ);
    %thisSeg(plane>maxValYZ) = 150;
    thisSeg(plane>(meansYZ(thisY) + 1.1*stDevsYZ(thisY))) = 150;
    segStackYZ(thisY,:,zRange) = thisSeg;
end

%Only accept a voxel that is segmented in all 3 orientations.

segStack = segStackXY .* segStackXZ .* segStackYZ;
segStack(segStack>0) = 150;
% for thisZ = 1:numZ
%     for thisX = 1:numX
%         for thisY = 1:numY
%             if segStackXY(thisY,thisX,thisZ) > 1 && segStackXZ(thisY,thisX,thisZ) > 1 && segStackYZ(thisY,thisX,thisZ) > 1
%                 segStack(thisY,thisX,thisZ) = 1;
%             end
%         end
%     end
% end

%Remove small objects and those entirely outside the zRange.
segStackBWConn = bwconncomp(segStack);
segStackLM = labelmatrix(segStackBWConn);

segProps = regionprops(segStackLM, 'Area');

numObj = length(segProps);

for thisObj = 1:numObj
    areaThisObj = segProps(thisObj).Area;
    if areaThisObj < minObjSize % || areaThisObj > 1000
        segStackLM(segStackLM == thisObj) = 0;
    end
end

% allVals = unique(segStackLM);
% cellVals = unique(segStackLM(:,:,zRange));
% nonCellVals = setdiff(allVals, cellVals);
% [binLoc, imgLoc] = ismember(segStackLM, nonCellVals);
% segStackLM(binLoc) = 0;
toc
stackOut = segStackLM;