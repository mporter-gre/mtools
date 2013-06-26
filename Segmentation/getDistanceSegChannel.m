function channelLabel = getDistanceSegChannel(credentials, pixels)
%Ask the user which channel from the image should be used for segmentation.
%Use the Pixels object to get the number of channels, ask the pixelsService
%for the labels used for each channel then ask the user to choose.

global segChannel1;
global segChannel2;
global remembered;
global scope;

[client, session, gateway] = gatewayConnect(credentials{1}, credentials{2}, credentials{3});
numChannels = pixels.getSizeC.getValue;
pixelsId = pixels.getId.getValue;
for thisChannel = 1:numChannels
    channelLabel{thisChannel} = session.getPixelsService.retrievePixDescription(pixelsId).getChannel(thisChannel-1).getLogicalChannel.getEmissionWave.getValue;
end
gatewayDisconnect(client, session, gateway);

[stuff segChannel1 segChannel2 remembered scope] = distanceChannelSelector(channelLabel);

end