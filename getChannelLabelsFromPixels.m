function channelLabels = getChannelLabelsFromPixels(pixels)
%Get the emission wavelengths of the channels in a pixels.

global session;

numChannels = pixels.getSizeC.getValue;
pixelsId = pixels.getId.getValue;
fakeChannelNum = 0;
for thisChannel = 1:numChannels
    try
        channelLabels{thisChannel} = session.getPixelsService.retrievePixDescription(pixelsId).getChannel(thisChannel-1).getLogicalChannel.getEmissionWave.getValue;
    catch
        channelLabels{thisChannel} = fakeChannelNum;
        fakeChannelNum = fakeChannelNum + 1;
    end
end

end