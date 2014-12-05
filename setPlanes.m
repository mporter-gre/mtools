function setPlanes(session, imagePlanes, newPixels, channelIdx, timeIdx)
%setPlanes(session, imagePlanes, newPixels, channelIdx, timeIdx)
%Make sure the imagePlanes are of the same pixelsType as the created image.
%channelIdx and timeIdx both index from 0.

store = session.createRawPixelsStore;
newPixelsId = newPixels.getId.getValue;
store.setPixelsId(newPixelsId, false);

[~, ~, numZ] = size(imagePlanes);

for thisZ = 1:numZ
    planeAsBytes = toByteArray(imagePlanes(:,:,thisZ)', newPixels);
    store.setPlane(planeAsBytes, thisZ-1, channelIdx, timeIdx);
end
store.save();
store.close();