function [channelLabel] = getSegChannel(pixels)
%Ask the user which channel from the image should be used for segmentation.
%Use the Pixels object to get the number of channels, ask the pixelsService
%for the labels used for each channel then ask the user to choose.
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