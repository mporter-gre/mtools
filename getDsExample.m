server = 'gretzky.openmicroscopy.org.uk';
user = 'user-1';
password = 'ome';
client = omero.client(server,4064);
session = client.createSession(user, password);
imageId = 527;

% planeInfo1 = getPlaneInfo(session, imageId); %works
% planeInfo2 = getPlaneInfo(session, getImages(session, imageId)); %works
% 
% planeInfo3 = getPlaneInfo(session, imageId);
% planeInfo4 = getPlaneInfo(session, getImages(session, imageId));
%Return information for the given (z, c, t) plane

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

z = 5;
c = 0;
t = 0;
sizeZ = 10;
sizeC = 2;
sizeT = 30;
% planeInfo5 = getPlaneInfo(session, imageId, z, c, t);
% planeInfo6 = getPlaneInfo(session, getImages(session, imageId), z, c, t);
%Return information for given planes arrays


% planeInfo7 = getPlaneInfo(session, imageId, [], c, t);
% planeInfo8 = getPlaneInfo(session, imageId, z, [], t);
% planeInfo9 = getPlaneInfo(session, imageId, z, c, []);
% planeInfo10 = getPlaneInfo(session, getImages(session, imageId), [], c, t);
% planeInfo11 = getPlaneInfo(session, getImages(session, imageId), z, [], t);
% planeInfo12 = getPlaneInfo(session, getImages(session, imageId), z, c, []);

%Exceptions...
%planeInfo13 = getPlaneInfo(session, -1);
%planeInfo14 = getPlaneInfo(session, imageId, -1, c, t);
%planeInfo15 = getPlaneInfo(session, imageId, z, -1, t);
%planeInfo16 = getPlaneInfo(session, imageId, z, c, -1);
%planeInfo17 = getPlaneInfo(session, imageId, sizeZ, c, t);
%planeInfo18 = getPlaneInfo(session, imageId, z, sizeC, t);
planeInfo19 = getPlaneInfo(session, imageId, z, c, sizeT);

numel(planeInfo9)
for i = 1:numel(planeInfo9),
    d = planeInfo9(i)
end 
client.closeSession();
