function [newImageId] = copyImageChangingParameters(imageId, parameters, pixels, credentials)
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

[client, session, gateway] = gatewayConnect(credentials{1}, credentials{2}, credentials{3});
sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
sizeT = pixels.getSizeT.getValue;
sizeZ = pixels.getSizeZ.getValue;
channelList = java.util.ArrayList;
for thisChannel = 1:length(parameters.channelList)
    channelList.add(int32(thisChannel-1));
end
imageName = java.lang.String(parameters.imageName);

channelList.size
newImageId = gateway.copyImage(imageId, sizeX, sizeY, sizeZ, sizeT, channelList, imageName);
gatewayDisconnect(client, session, gateway)

end