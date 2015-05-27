function gatewayDisconnect
%Disconnect from omero server using Blitz. 
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


if isjava(client)
    client.closeSession;
end
% % global gateway;
% % global clientAlive;
% 
% % try
% %     clientAlive.stop;
% % catch
% %     %If the client is no longer alive then there's nothing to close.
% %     return;
% % end
% % try
% %     gateway.close;
% %     session.close;
% % catch
% %     disp('Gateway not closed this time');
% % end
% % clear global clientAlive;
% % clear global gateway;
clear global session;
clear global client;
% 
% end
