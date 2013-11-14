function plane = getPlaneFromImageId(imageId, z, c, t)

global gateway;

pixels = gateway.getPixelsFromImage(imageId);
pixels = pixels.get(0);
pixelsId = pixels.getId().getValue();

rawPlane = gateway.getPlane(pixelsId, z, c , t);
rawPlaneTypecast = typecastMatrix(rawPlane, char(pixels.getPixelsType.getValue.getValue));
plane2D = reshape(rawPlaneTypecast, pixels.getSizeX.getValue, pixels.getSizeY.getValue);
plane = swapbytes(plane2D');

clear('rawPlane');
clear('rawPlaneTypecast');
clear('plane2D');


end