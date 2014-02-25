function myDatasets = getMyDatasets(username)
%Gets the daset names and Id's linked to username input by the user. If no
%user is found by that name the script will exit.
%Do myDatasets = getMyDatasets('username');

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

%Connect to the server
[client, session, gateway] = blitzkriegBop;

%Get all the users on the server
users = gateway.findAllByQuery('from Experimenter');
numUsers = users.size();

%Find the id of the user
for thisUser = 0:numUsers-1
    if strcmp(char(users.get(thisUser).omeName.val), username)
        userId = double(users.get(thisUser).id.val);
    end
end

%If no user found, exit.
if ~userId
    gateway.close();
    session.close();
    client.close();
    error('Sorry, that username not found');
end

%Get that users' datasets using the userId
%datasets = gateway.getDatasets(userId, false);
datasets = gateway.findAllByQuery(['from Dataset as d where owner_id = ', num2str(userId)]);

%Iterate through the datasets found, and put the id's and names in the
%myDatasets structure to be passed out.
iter = datasets.iterator;
counter = 1; 
while iter.hasNext(); 
    myDatasets{counter}.id = double(iter.next().id.val); 
    counter = counter + 1; 
end
iter = datasets.iterator;
counter = 1; 
while iter.hasNext(); 
    myDatasets{counter}.name = char(iter.next().name.val); 
    counter = counter + 1; 
end

%Close connection to the server.
gateway.close();
session.close();
client.close();

end
