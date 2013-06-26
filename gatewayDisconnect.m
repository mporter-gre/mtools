function gatewayDisconnect
%Disconnect from omero server using Blitz. 
%
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

global client;
global session;
global gateway;
global clientAlive;

try
    clientAlive.stop;
catch
    %If the client is no longer alive then there's nothing to close.
    return;
end
try
    gateway.close;
    session.close;
catch
    disp('Gateway not closed this time');
end
clear global clientAlive;
clear global gateway;
clear global session;
clear global client;

end