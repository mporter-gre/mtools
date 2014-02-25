function [channelMinScaled channelGlobalMax channelGlobalMaxScaled] = getChannelMinMax(pixels, channel)
%Return the channel min and channel global max render settings from Omero.
%Do [channelMin channelMax] = getChannelMinMax(pixels, channel); where
%channel indexes from 0

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
