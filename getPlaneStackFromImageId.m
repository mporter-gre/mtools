function planeStack = getPlaneStackFromImageId(id, c, t, gateway)

pixels = gateway.getPixelsFromImage(id);
pixelsId = pixels.get(0).getId().getValue();
planeStack = gateway.getPlaneStack(pixelsId, c, t);

end