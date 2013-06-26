function imgStack = getStackFromPixels(pixels, theC, theT)

try
    numZ = pixels.get(0).getSizeZ.getValue;
    pixelsId = pixels.get(0).getId.getValue;
    sizeX = pixels.get(0).getSizeX.getValue;
    sizeY = pixels.get(0).getSizeY.getValue;
catch
    numZ = pixels.getSizeZ.getValue;
    pixelsId = pixels.getId.getValue;
    sizeX = pixels.getSizeX.getValue;
    sizeY = pixels.getSizeY.getValue;
end
imgStack = zeros(sizeY, sizeX, numZ);

for thisZ = 1:numZ
    imgStack(:,:,thisZ) = getPlaneFromPixelsId(pixelsId, thisZ-1, theC, theT);
end