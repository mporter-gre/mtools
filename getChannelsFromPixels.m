function [channelLabel] = getChannelsFromPixels(pixels)
%Use the Pixels object to get the number of channels, ask the pixelsService
%for the labels used for each channel.
global session;

numChannels = pixels.getSizeC.getValue;
pixelsId = pixels.getId.getValue;
fakeChannelNum = 0;
for thisChannel = 1:numChannels
    try
        channelLabel{thisChannel} = session.getPixelsService.retrievePixDescription(pixelsId).getChannel(thisChannel-1).getLogicalChannel.getEmissionWave.getValue;
    catch
        channelLabel{thisChannel} = fakeChannelNum;
        fakeChannelNum = fakeChannelNum + 1;
    end
end


end