function gatewayConnect(username, password, server, port)
%Connect to omero server using Blitz. Username and password are
%top secret, of course.
%mage = 134.36.65.50
%nightshade = 134.36.65.51
%
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

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