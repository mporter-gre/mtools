function myDatasets = getMyDatasets(username)
%Gets the daset names and Id's linked to username input by the user. If no
%user is found by that name the script will exit.
%Do myDatasets = getMyDatasets('username');

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