function segStack = fpBacteriaSeg3D(stackIn)

[sizeY, sizeX, numZ] = size(stackIn);

for thisZ = 1:numZ
    otsuThresh(thisZ) = otsu(stackIn(:,:,thisZ));
end

otsuThresh = max(otsuThresh);

%Find the mean + 2x standard deviations of pixels below otsuThresh
belowThresh = zeros(sizeY, sizeX, numZ);
belowThresh(stackIn<otsuThresh) = stackIn(stackIn<otsuThresh);
belowThresh = reshape(belowThresh, [], 1);
belowThresh(belowThresh==0) = [];
imageMax = max(max(max(stackIn)));
meanBelowThresh = mean(belowThresh);
stdBelowThresh = std(belowThresh);
cannyThresh = (meanBelowThresh + (2*stdBelowThresh))/imageMax;

%Put the Z stack into a single plane for edge detection, apply a filter for
%the background and exaggerate the gradients
imPlane = [];
for thisZ = 1:numZ
    imPlane = [imPlane stackIn(:,:,thisZ)];
end
imPlane = medfilt2(imPlane);
imPlane = imPlane.^2;

%Perform edge detection
imPlaneFilt = medfilt2(imPlane);
imPlaneFilt = medfilt2(imPlaneFilt);
imPlaneEdge = edge(imPlaneFilt, 'canny', cannyThresh);

%Seal the gaps, fill the holes and remove non-blobs
se = strel('diamond', 1);
imPlaneEdgeDil = imdilate(imPlaneEdge, se);
imPlaneEdgeDilFill = imfill(imPlaneEdgeDil, 'holes');
imPlaneEdgeDilFillEr = imerode(imPlaneEdgeDilFill, se);
imPlaneEdgeDilFillErMaj = bwmorph(imPlaneEdgeDilFillEr, 'majority');

%Put the segmented stack back together
xStart = 1;
xEnd = sizeX;
for thisZ = 1:numZ
    segStack(:,:,thisZ) = imPlaneEdgeDilFillErMaj(:,xStart:xEnd);
    xStart = xStart + sizeX;
    xEnd = xEnd + sizeX;
end

