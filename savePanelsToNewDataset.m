function savePanelsToNewDataset(session, projectId, origImageId, panels)
%Save panels into a new dataset with the name of the image that the panels
%came from. This would be run after splitToPanels.m
%Panels are already made and are in a variable as:
% panels{numPanels}{thisC}(:,:,thisPanelZ,thisPanelT)

%Create the dataset
origImage = getImages(session, origImageId);
imageName = char(origImage.getName.getValue.getBytes');
dataset = createDataset(session, imageName, projectId);
datasetId = dataset.getId.getValue;

pixels = origImage.getPrimaryPixels;

% sizeX = pixels.getSizeX.getValue;
% sizeY = pixels.getSizeY.getValue;
% numZ = pixels.getSizeZ.getValue;
numC = pixels.getSizeC.getValue;
% numT = pixels.getSizeT.getValue;

physSizeX = pixels.getPhysicalSizeX.getValue;
physSizeY = pixels.getPhysicalSizeY.getValue;
try
    physSizeZ = pixels.getPhysicalSizeZ.getValue;
catch
    physSizeZ = 1;
end
tInc = pixels.getTimeIncrement;

%Get the channels data
pixelsId = pixels.getId.getValue;
fakeChannelNum = 1;
for thisChannel = 1:numC
    try
        channelList{thisChannel} = session.getPixelsService.retrievePixDescription(pixelsId).getChannel(thisChannel-1).getLogicalChannel.getEmissionWave.getValue;
    catch
        channelList{thisChannel} = fakeChannelNum;
        fakeChannelNum = fakeChannelNum + 1;
    end
end

%Create the new images
store = session.createRawPixelsStore();
numPanels = length(panels);
numC = length(panels{1});
[sizeX, sizeY, numZ, numT] = size(panels{1}{1});
for thisPanel = 1:numPanels
    if thisPanel < 10
        newImageName = [imageName '_panel_0' num2str(thisPanel)];
    else
        newImageName = [imageName '_panel_' num2str(thisPanel)];
    end
    newImage = createNewImage(session, newImageName, channelList, 'uint16', physSizeX, physSizeY, physSizeZ, sizeX, sizeY, numZ, numT);
    newImageId = newImage.getId.getValue;
    newPixels = newImage.getPrimaryPixels;
    newPixelsId = newPixels.getId.getValue;
    store.setPixelsId(newPixelsId, false);
    for thisC = 1:numC
        for thisZ = 1:numZ
            for thisT = 1:numT
                newPlane = panels{thisPanel}{thisC}(:,:,thisZ, thisT);
                planeAsBytes = toByteArray(newPlane', newPixels);
                store.setPlane(planeAsBytes, thisZ-1, thisC-1, thisT-1);
            end
        end
    end
    store.save;
    % Link the new image to the dataset
    newLink = omero.model.DatasetImageLinkI();
    newLink.setParent(omero.model.DatasetI(datasetId, false));
    newLink.setChild(omero.model.ImageI(newImageId, false));
    session.getUpdateService().saveObject(newLink);
end
store.close;         


