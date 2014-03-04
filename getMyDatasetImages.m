function pixelsWithPlanes = getMyDatasetImages(datasetId)
%Feed in a dataset ID and get returned all of the pixel id's, pixel names
%and plane data (first z, c and t only) in one structure. You can use
%datasets = getDatasets('username') to get your datasets and id's.
%Do pixelsWithPlanes = getMyDatasetImages(datasetId);

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

tic

%Connect to the server.
[client, session, gateway] = blitzkriegBop;

%Get the dataset information for the datasetId entered. getLeaves = true.
dataset = gateway.getDataset(datasetId,true);

%Get the pixels in the dataset
pixels = gateway.getPixelsFromDataset(dataset);

%Iterate through the pixels and get the pixel names.
iter = pixels.iterator;
counter = 1; 
while iter.hasNext(); 
    pixelsWithPlanes{counter}.name = char(pixels.get(counter-1).image.getName); 
    iter.next(); 
    counter = counter + 1; 
end

%Iterate through the pixels and get the id to get the planes.
iter = pixels.iterator;
counter = 1; 
while iter.hasNext(); 
    pixelsWithPlanes{counter}.id = double(iter.next().id.val); 
    counter = counter + 1; 
end

%Get the first c, z and t for each plane Id.
for thisPlane = 1:length(pixelsWithPlanes)
    pixelsWithPlanes{thisPlane}.plane = gateway.getPlane(pixelsWithPlanes{thisPlane}.id,0,0,0);
    disp(['loading plane... ', num2str(thisPlane)]);
end

%Close the connection to the server.
gateway.close();
session.close();
client.close();

toc
end
