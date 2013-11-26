function credentials = credentialsFromSession(session)

client = session.getSessionService.getMyOpenSessions.get(0).getDetails.getClient;
commandLineOptions = char(client.getProperties.getCommandLineOptions);
[~, credentials{1}] = strtok(commandLineOptions(7,:), '=');
credentials{1} = credentials{1}(2:end);
[~, credentials{2}] = strtok(commandLineOptions(1,:), '=');
credentials{2} = credentials{2}(2:end);
[~, credentials{3}] = strtok(commandLineOptions(18,:), '=');
credentials{3} = credentials{3}(2:end);
[~, credentials{4}] = strtok(commandLineOptions(19,:), '=');
credentials{4} = credentials{4}(2:end);
credentials = deblank(credentials);