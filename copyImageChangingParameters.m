function [newImageId] = copyImageChangingParameters(imageId, parameters, pixels, credentials)
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

[client, session, gateway] = gatewayConnect(credentials{1}, credentials{2}, credentials{3});
sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
sizeT = pixels.getSizeT.getValue;
sizeZ = pixels.getSizeZ.getValue;
channelList = java.util.ArrayList;
for thisChannel = 1:length(parameters.channelList)
    channelList.add(int32(thisChannel-1));
end
imageName = java.lang.String(parameters.imageName);

channelList.size
newImageId = gateway.copyImage(imageId, sizeX, sizeY, sizeZ, sizeT, channelList, imageName);
gatewayDisconnect(client, session, gateway)

end
