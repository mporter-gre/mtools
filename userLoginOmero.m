function userLoginOmero(username, password, server, port)

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
global client;
global session;

if isnumeric(port)
    port = num2str(port);
end

warndlg('line 26 userLoginOmero');
props = java.util.Properties();
props.setProperty('omero.host', server);
props.setProperty('omero.user', username);
props.setProperty('omero.pass', password);
props.setProperty('omero.port', port);
props.setProperty('omero.keep_alive', '60');

[client, session] = connectOmero(props);
