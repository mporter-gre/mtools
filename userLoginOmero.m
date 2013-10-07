function userLoginOmero(username, password, server, port)
global client;
global session;

if isnumeric(port)
    port = num2str(port);
end

props = java.util.Properties();
props.setProperty('omero.host', server);
props.setProperty('omero.user', username);
props.setProperty('omero.pass', password);
props.setProperty('omero.port', port);
props.setProperty('omero.keep_alive', '60');

[client, session] = connectOmero(props);
