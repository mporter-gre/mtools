function imp = createImagePlusFromStack(stackIn, pixelsOrImage, numC, numZ, numT)

objType = class(pixelsOrImage);

if strcmpi(objType, 'omero.model.PixelsI')
    pixels = pixelsOrImage;
else
    pixels = pixelsOrImage.getPrimaryPixels;
end

[sizeY, sizeX, numPlanes] = size(stackIn);

if numPlanes ~= numZ*numT*numC
    error('numPlanes ~= numZ*numT*numC')
end

imageStack = ij.ImageStack(sizeX,sizeY);
for thisPlane = 1:numPlanes
    bytesOut = toByteArray(stackIn(:,:,thisPlane), pixels);
    imageStack.addSlice('',bytesOut);
end

imp = ij.ImagePlus();
imp.setStack(imageStack, numC, numZ, numT);