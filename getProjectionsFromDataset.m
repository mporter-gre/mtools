function projections = getProjectionsFromDataset(datasets, channel, gateway)
%get 'channel' from projections in the dataset listed in 'datasets'. 'datasets' 
%should contain only one dataset. This script will only use the first one if
%there are more than one.

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

allTheImages = omerojava.util.GatewayUtils.getImagesFromDataset(datasets.get(0));
numImages = allTheImages.size;
allTheImagesIter = allTheImages.iterator;
i = 1;
while allTheImagesIter.hasNext
    allTheImagesIter.next;
    imageId(i) = allTheImages.get(i-1).getId.getValue;
    projections{i}.imageName = allTheImages.get(i-1).getName.getValue.toCharArray';
    projections{i}.imageId = allTheImages.get(i-1).getId.getValue;
    projections{i}.channel = num2str(channel);
    projections{i}.plane = getPlaneFromImageId(projections{i}.imageId,0,channel-1,0,gateway);
    i = i + 1;
end
    

end
