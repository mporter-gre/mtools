function [newImage] = createNewImageFromOldPixels(oldImageId, channelList, imageName, pixelsType)
%Matlab inplementation of createImage as found
%http://trac.openmicroscopy.org.uk/omero/browser/trunk/components/common/sr
%c/ome/api/IPixels.java
%Also allows the choice of pixelsType. If you need the same space as the
%original image, pass '' for pixelsType. Otherwise you can set to 'uint8',
%'uint16', 'single', 'double' etc...
%
%Author Michael Porter

% Copyright (C) 2009-2014 University of Dundee.
% All rights reserved.
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

global session;
global gateway;

theImage = getImages(session, oldImageId);
oldPixels = theImage.getPrimaryPixels;
oldPixelsId = oldPixels.getId.getValue;
oldNumChannels = oldPixels.getSizeC.getValue;
sizeX = oldPixels.getSizeX.getValue;
sizeY = oldPixels.getSizeY.getValue;
sizeT = oldPixels.getSizeT.getValue;
sizeZ = oldPixels.getSizeZ.getValue;
try
    physSizeX = oldPixels.getPhysicalSizeX;
    physSizeY = oldPixels.getPhysicalSizeY;
    physSizeZ = oldPixels.getPhysicalSizeZ;
catch
    physSizeX = omero.model.LengthI(1, omero.model.enums.UnitsLength.MICROMETER);
    physSizeY = omero.model.LengthI(1, omero.model.enums.UnitsLength.MICROMETER);
    physSizeZ = omero.model.LengthI(1, omero.model.enums.UnitsLength.MICROMETER);
end

oldPixelsDescription = session.getPixelsService.retrievePixDescription(oldPixelsId);
oldPixelsType = oldPixels.getPixelsType.getValue.getValue;
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

newPixels.setPhysicalSizeX(physSizeX);
newPixels.setPhysicalSizeY(physSizeY);
newPixels.setPhysicalSizeZ(physSizeZ);
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
        lengthObj = omero.model.LengthI(channelList{thisChannel}{1}, omero.model.enums.UnitsLength.NANOMETER);
        logicalChannel.setEmissionWave(lengthObj);
    catch
        lengthObj = omero.model.LengthI(channelList{thisChannel}, omero.model.enums.UnitsLength.NANOMETER);
        logicalChannel.setEmissionWave(lengthObj);
    end
    newPixels.addChannel(channel);
end
newImage.addPixels(newPixels);

%Save and return our newly created Image Id
iUpdate = session.getUpdateService();
newImage = iUpdate.saveAndReturnObject(newImage);

end
