function [newImage, newPixels] = createImage(session, sizeX, sizeY, numZ, numC, numT, pixelsType, dimensionOrder, imageName, datasetId)

iUpdate = session.getUpdateService();

dimOrder = omero.model.DimensionOrderI;
dimOrder.setValue(omero.rtypes.rstring(dimensionOrder)); %Default should be 'XYZCT'
newDate = java.util.Date;
timeStamp = omero.rtypes.rtime(newDate.getTime * .001);

newImage = omero.model.ImageI;
newPixels = omero.model.PixelsI;
newImage.setName(omero.rtypes.rstring(imageName));
newImage.setDescription(omero.rtypes.rstring('Created using omeroJava'));
newImage.setAcquisitionDate(timeStamp);

omeroPixelsType = omero.model.PixelsTypeI;
omeroPixelsType.setValue((omero.rtypes.rstring(pixelsType)));
newPixels.setPixelsType(omeroPixelsType);
newPixels.setSizeX(omero.rtypes.rint(sizeX));
newPixels.setSizeY(omero.rtypes.rint(sizeY));
newPixels.setSizeZ(omero.rtypes.rint(numZ));
newPixels.setSizeC(omero.rtypes.rint(numC));
newPixels.setSizeT(omero.rtypes.rint(numT));
newPixels.setSha1(omero.rtypes.rstring('Pending...'));
newPixels.setDimensionOrder(dimOrder);

for thisC = 1:numC
    channel = omero.model.ChannelI;
    logicalChannel = omero.model.LogicalChannelI;
    channel.setLogicalChannel(logicalChannel);
    statsInfo = omero.model.StatsInfoI;
    switch pixelsType
        case 'bit'
            statsInfo.setGlobalMin(omero.rtypes.rdouble(0));
            statsInfo.setGlobalMax(omero.rtypes.rdouble(1));
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
    
    channel.setStatsInfo(statsInfo);
    newPixels.addChannel(channel);
end

newImage.addPixels(newPixels);
newImage = iUpdate.saveAndReturnObject(newImage);
newImageId = newImage.getId.getValue;
newPixels = newImage.getPrimaryPixels;
newPixelsId = newPixels.getId.getValue;

newLink = omero.model.DatasetImageLinkI();
newLink.setParent(omero.model.DatasetI(datasetId, false));
newLink.setChild(omero.model.ImageI(newImageId, false));
iUpdate.saveObject(newLink);