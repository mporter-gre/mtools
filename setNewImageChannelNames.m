function setNewImageChannelNames(image, pixels, channelList, session)

% Copyright (C) 2013-2014 University of Dundee & Open Microscopy Environment.
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
