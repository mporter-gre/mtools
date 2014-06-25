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
    %bytesOut = toByteArray(stackIn(:,:,thisPlane), pixels);
    byteArray = reshape(stackIn(:,:,thisPlane)', sizeX * sizeY, 1 );
    imageStack.addSlice('',byteArray);
end

imp = ij.ImagePlus();
imp.setStack(imageStack, numC, numZ, numT);

width = pixels.getPhysicalSizeX.getValue;
height = pixels.getPhysicalSizeY.getValue;
depth = pixels.getPhysicalSizeZ.getValue;

calibration = ij.measure.Calibration();
calibration.pixelWidth = width;
calibration.pixelHeight = height;
calibration.pixelDepth = depth;
imp.setCalibration(calibration);