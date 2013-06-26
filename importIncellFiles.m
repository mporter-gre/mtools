function importIncellFiles(datasetId)
%At the moment this is only useful for importing single-fluorescent
%single-brightfield movies with no Z-stack with pixels type uint16

[xmlFile xmlPath] = uigetfile('*.xdce', 'Where is the XDCE file?');
currDir = xmlPath;
[fluoImageFiles imagePath] = uigetfile('*.tif', 'Where are the fluorescence Tiff files?', currDir, 'MultiSelect', 'on');
[brightImageFiles imagePath] = uigetfile('*.tif', 'Where are the brightfield Tiff files?', currDir, 'MultiSelect', 'on');
fluoImageFiles = sort(fluoImageFiles);
brightImageFiles = sort(brightImageFiles);

xmlStruct = xml2struct([xmlPath ,'\', xmlFile]);

%This is a hack for known files. Parse the file properly later!!!!!!
pixelHeight = str2double(xmlStruct.children(10).children(6).attributes(6).value);
pixelWidth = str2double(xmlStruct.children(10).children(6).attributes(7).value);
physSizeZ = 1;
sizeX = str2double(xmlStruct.children(10).children(8).children(8).attributes(2).value);
sizeY = str2double(xmlStruct.children(10).children(8).children(8).attributes(1).value);

numT = length(fluoImageFiles);
numZ = 1;
numC = 2;
pixelsType = '12bitCam';
channelList{1} = 565;
channelList{2} = 666;

imageName = strtok(fluoImageFiles{1}, 'wv');

newImage = createNewImage(imageName, channelList, pixelsType, pixelWidth, pixelHeight, physSizeZ, sizeX, sizeY, numZ, numT);

[client session gateway] = blitzkriegBop;
newImageId = newImage.getId.getValue;
newPixels = gateway.getPixelsFromImage(newImageId);
newPixelsId = newPixels.get(0).getId.getValue;
for thisImage = 1:numT
    fluoPlane = imread([imagePath, '\', fluoImageFiles{thisImage}], 'tif');
    brightPlane = imread([imagePath, '\', brightImageFiles{thisImage}], 'tif');
    fluoPlaneAsBytes = omerojava.util.GatewayUtils.convertClientToServer(newPixels.get(0), fluoPlane');
    brightPlaneAsBytes = omerojava.util.GatewayUtils.convertClientToServer(newPixels.get(0), brightPlane');
    gateway.uploadPlane(newPixelsId, 0, 0, thisImage-1, fluoPlaneAsBytes);
    gateway.uploadPlane(newPixelsId, 0, 1, thisImage-1, brightPlaneAsBytes);
end

%Set the server to create the rendering defs.
renderingEngine = session.createRenderingEngine;
renderingEngine.lookupPixels(newPixelsId);
renderingEngine.resetDefaults;
renderingEngine.lookupRenderingDef(newPixelsId);
renderingEngine.load();

%Fetch one of each channel to get the min and max
fluoPlane = imread([imagePath, '\', fluoImageFiles{1}], 'tif');
brightPlane = imread([imagePath, '\', brightImageFiles{1}], 'tif');
min_Max(1) = min2(fluoPlane);
min_Max(2) = max2(fluoPlane);
min_Max(3) = min2(brightPlane);
min_Max(4) = max2(brightPlane);
for thisC = 1:numC
    renderingEngine.setActive(thisC-1,1);
    renderingEngine.setChannelWindow(thisC-1, min(min_Max), max(min_Max));
end

%Link the new image into the dataset.
aDataset = gateway.getDataset(datasetId,0);
aDataset.unload;
newImage.unload;
newLink = omero.model.DatasetImageLinkI();
newLink.link(aDataset, newImage);
gateway.saveObject(newLink);
gatewayDisconnect(client, session, gateway);

end