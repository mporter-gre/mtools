function [client, session, gateway] = blitzkriegBop
%Connect to omero server using Blitz. Change the server to connect to in
%'iceconfig' file which is in the Matlab path. Username and password are
%top secret, of course.
%Do [client, session, gateway] = blitzkriegBop;
%mage = 134.36.65.50
%nightshade = 134.36.65.51

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

%client = omero.client(java.lang.String('C:\Documents and Settings\Michael\My Documents\MATLAB\iceconfig'));
client = omero.client('134.36.65.51', 4063);
session = client.createSession('mike', 'Homer'); %Obviously top secret.
gateway = session.createGateway();

end
