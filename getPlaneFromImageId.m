function plane = getPlaneFromImageId(id, z, c, t, gateway)

pixels = gateway.getPixelsFromImage(id);
pixelsId = pixels.get(0).getId().getValue();
rawPlane = gateway.getPlane(pixelsId, z, c , t);
rawPlaneTypecast = setMatrixType(rawPlane, char(pixels.get(0).getPixelsType.getValue.getValue));
plane2D = reshape(rawPlaneTypecast, pixels.get(0).getSizeX.getValue, pixels.get(0).getSizeY.getValue);
plane = swapbytes(plane2D);

end