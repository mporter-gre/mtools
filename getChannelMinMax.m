function [channelMinScaled channelGlobalMax channelGlobalMaxScaled] = getChannelMinMax(pixels, channel)
%Return the channel min and channel global max render settings from Omero.
%Do [channelMin channelMax] = getChannelMinMax(pixels, channel); where
%channel indexes from 0

global session;

pixelsId = pixels.getId.getValue;
renderingService = session.getRenderingSettingsService;
renderingSettings = renderingService.getRenderingSettings(pixelsId);
pixelsDescription = session.getPixelsService.retrievePixDescription(pixelsId);

channelBinding = renderingSettings.getChannelBinding(channel);
startVal = channelBinding.getInputStart.getValue;
endVal = channelBinding.getInputEnd.getValue;
channelGlobalMax = pixelsDescription.getChannel(channel).getStatsInfo.getGlobalMax.getValue;
channelGlobalMaxScaled = endVal/channelGlobalMax;
if channelGlobalMaxScaled > 1
    channelGlobalMaxScaled = 1;
end
channelMinScaled = startVal/channelGlobalMax;
