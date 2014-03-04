function gatewayConnect(username, password, server, port)
%Connect to omero server using Blitz. Username and password are
%top secret, of course.
%mage = 134.36.65.50
%nightshade = 134.36.65.51
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

global client;
global session;
global gateway;
global clientAlive;

if nargin < 4
    port = '4064';
end

client = omero.client(server, str2double(port)); %standard port is 4064 after omero 4.2, 4063 previously.
session = client.createSession(username, password);
gateway = session.createGateway();
clientAlive = omeroKeepAlive(client);

end
