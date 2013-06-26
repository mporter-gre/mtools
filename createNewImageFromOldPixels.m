function [newImage] = createNewImageFromOldPixels(oldImageId, channelList, imageName, pixelsType)
%Matlab inplementation of createImage as found
%http://trac.openmicroscopy.org.uk/omero/browser/trunk/components/common/sr
%c/ome/api/IPixels.java
%Also allows the choice of pixelsType. If you need the same space as the
%original image, pass '' for pixelsType. Otherwise you can set to 'uint8',
%'uint16', 'single', 'double' etc...
%
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

global session;
global gateway;

oldPixels = gateway.getPixelsFromImage(oldImageId);
oldPixelsId = oldPixels.get(0).getId.getValue;
oldNumChannels = oldPixels.get(0).getSizeC.getValue;
sizeX = oldPixels.get(0).getSizeX.getValue;
sizeY = oldPixels.get(0).getSizeY.getValue;
sizeT = oldPixels.get(0).getSizeT.getValue;
sizeZ = oldPixels.get(0).getSizeZ.getValue;
try
    physSizeX = oldPixels.get(0).getPhysicalSizeX.getValue;
    physSizeY = oldPixels.get(0).getPhysicalSizeY.getValue;
    physSizeZ = oldPixels.get(0).getPhysicalSizeZ.getValue;
catch
    physSizeX = 1;
    physSizeY = 1;
    physSizeZ = 1;
end
oldPixelsDescription = session.getPixelsService.retrievePixDescription(oldPixelsId);
oldPixelsType = oldPixels.get(0).getPixelsType.getValue.getValue;
oldPixelsType = char(oldPixelsType);
omeroPixelsType = omero.model.PixelsTypeI;
if ~isempty(pixelsType)
    omeroPixelsType.setValue((omero.rtypes.rstring(pixelsType)));
    newPixelsType = 1;
else
    omeroPixelsType.setValue((omero.rtypes.rstring(oldPixelsType)));
    newPixelsType = 0;
end
dimOrder = omero.model.DimensionOrderI;
dimOrder.setValue(omero.rtypes.rstring('XYZCT'));
newDate = java.util.Date;
timeStamp = omero.rtypes.rtime(newDate.getTime * .001);

newImage = omero.model.ImageI;
newPixels = omero.model.PixelsI;
newImage.setName(omero.rtypes.rstring(imageName));
newImage.setDescription(omero.rtypes.rstring('Created using omeroJava'));
newImage.setAcquisitionDate(timeStamp);

newPixels.setPhysicalSizeX(omero.rtypes.rdouble(physSizeX));
newPixels.setPhysicalSizeY(omero.rtypes.rdouble(physSizeY));
newPixels.setPhysicalSizeZ(omero.rtypes.rdouble(physSizeZ));
newPixels.setPixelsType(omeroPixelsType);
newPixels.setSizeX(omero.rtypes.rint(sizeX));
newPixels.setSizeY(omero.rtypes.rint(sizeY));
newPixels.setSizeZ(omero.rtypes.rint(sizeZ));
newPixels.setSizeC(omero.rtypes.rint(length(channelList)));
newPixels.setSizeT(omero.rtypes.rint(sizeT));
newPixels.setSha1(omero.rtypes.rstring('Pending...'));
newPixels.setDimensionOrder(dimOrder);

%Create channel data.
for thisChannel = 1:length(channelList)
    channel = omero.model.ChannelI;
    logicalChannel = omero.model.LogicalChannelI;
    channel.setLogicalChannel(logicalChannel);
    statsInfo = omero.model.StatsInfoI;
    if thisChannel > oldNumChannels
        %Bit of a hack, for setting min/max of 'events' channel of
        %EventTimerAndCrop (an extra channel).
        statsInfo.setGlobalMin(omero.rtypes.rdouble(0));
        statsInfo.setGlobalMax(omero.rtypes.rdouble(255));
    else
        if newPixelsType == 0
            statsInfo.setGlobalMin(omero.rtypes.rdouble(oldPixelsDescription.getChannel(thisChannel-1).getStatsInfo.getGlobalMin.getValue));
            statsInfo.setGlobalMax(omero.rtypes.rdouble(oldPixelsDescription.getChannel(thisChannel-1).getStatsInfo.getGlobalMax.getValue));
        else
            switch pixelsType
                case 'uint8'
                    statsInfo.setGlobalMin(omero.rtypes.rdouble(0));
                    statsInfo.setGlobalMax(omero.rtypes.rdouble(255));
                case 'uint16'
                    statsInfo.setGlobalMin(omero.rtypes.rdouble(0));
                    statsInfo.setGlobalMax(omero.rtypes.rdouble(65535));
                case 'uint32'
                    statsInfo.setGlobalMin(omero.rtypes.rdouble(0));
                    statsInfo.setGlobalMax(omero.rtypes.rdouble((2^32)-1));
                case 'uint64'
                    statsInfo.setGlobalMin(omero.rtypes.rdouble(0));
                    statsInfo.setGlobalMax(omero.rtypes.rdouble((2^64)-1));
            end
        end

    end
    channel.setStatsInfo(statsInfo);
    try
        logicalChannel.setEmissionWave(omero.rtypes.rint(channelList{thisChannel}{1}));
    catch
        logicalChannel.setEmissionWave(omero.rtypes.rint(channelList{thisChannel}));
    end
    newPixels.addChannel(channel);
end
newImage.addPixels(newPixels);

%Save and return our newly created Image Id
iUpdate = session.getUpdateService();
newImage = iUpdate.saveAndReturnObject(newImage);

end