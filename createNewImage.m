function newImage = createNewImage(imageName, channelList, pixelsType, physSizeX, physSizeY, physSizeZ, sizeX, sizeY, sizeZ, sizeT)
%Matlab inplementation of createImage as found
%http://trac.openmicroscopy.org.uk/omero/browser/trunk/components/common/sr
%c/ome/api/IPixels.java
%Also allows the choice of pixelsType which can set to 'uint8',
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

newDate = java.util.Date;
timeStamp = omero.rtypes.rtime(newDate.getTime);

newImage = omero.model.ImageI;
newPixels = omero.model.PixelsI;
newImage.setName(omero.rtypes.rstring(imageName));
newImage.setDescription(omero.rtypes.rstring('Created using omeroJava'));
newImage.setAcquisitionDate(timeStamp);

omeroPixelsType = omero.model.PixelsTypeI;
if strcmpi(pixelsType, '12bitCam')
    omeroPixelsType.setValue((omero.rtypes.rstring('uint16')));
else
    omeroPixelsType.setValue((omero.rtypes.rstring('uint16')));
end
dimOrder = omero.model.DimensionOrderI;
dimOrder.setValue(omero.rtypes.rstring('XYZCT'));

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

%Construct channel info
for thisChannel = 1:length(channelList)
    channel = omero.model.ChannelI;
    logicalChannel = omero.model.LogicalChannelI;
    channel.setLogicalChannel(logicalChannel);
    statsInfo = omero.model.StatsInfoI;
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
        case '12bitCam'
            statsInfo.setGlobalMin(omero.rtypes.rdouble(0));
            statsInfo.setGlobalMax(omero.rtypes.rdouble(4095));
    end

    channel.setStatsInfo(statsInfo);
    logicalChannel.setEmissionWave(omero.rtypes.rint(channelList{thisChannel}));
    newPixels.addChannel(channel);
end
newImage.addPixels(newPixels);

%Save and return our newly created Image Id
[client session gateway] = blitzkriegBop;
iUpdate = session.getUpdateService();
newImage = iUpdate.saveAndReturnObject(newImage);
gatewayDisconnect(client, session, gateway);


end
