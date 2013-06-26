function setNewImageChannelNames(image, pixels, channelList, session)

pixelsId = pixels.get(0).getId.getValue;
for thisChannel = 1:length(channelList)
    channel = omero.model.ChannelI;
    logicalChannel = omero.model.LogicalChannelI;
    channel.setLogicalChannel(logicalChannel);
    logicalChannel.setEmissionWave(omero.rtypes.rint(thisChannel-1));
    channelInfo = omero.model.StatsInfoI();
    channelInfo.setGlobalMin(omero.rtypes.rdouble(0));
    channelInfo.setGlobalMax(omero.rtypes.rdouble(1));
    channel.setStatsInfo(channelInfo);
    pixels.get(0).addChannel(channel);
end
image.addPixels(pixels);
iUpdate = session.getUpdateService;
iUpdate.saveObject(image);

for thisChannel = 1:length(channelList)
    pixServiceDescription = session.getPixelsService.retrievePixDescription(pixelsId).getChannel(thisChannel-1).getLogicalChannel();
    thisChannelName = omero.rtypes.rstring(channelList{thisChannel});
    pixServiceDescription.setName(thisChannelName);
    iUpdate = session.getUpdateService();
    iUpdate.saveObject(pixServiceDescription);
end

end