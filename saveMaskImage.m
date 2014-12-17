function saveMaskImage(maskImg, imageName, datasetId)

global session

[sizeY, sizeX, numZ] = size(maskImg);

store = session.createRawPixelsStore;
[newImage, newPixels] = createImage(session, sizeX, sizeY, numZ, 1, 1, 'uint8', 'XYZCT', imageName, datasetId);
newPixelsId = newPixels.getId.getValue;
store.setPixelsId(newPixelsId, false);


for thisZ = 1:numZ
    planeAsBytes = toByteArray(uint8(maskImg(:,:,thisZ))', newPixels);
    store.setPlane(planeAsBytes, thisZ-1, 0, 0);
end
store.save();
store.close();