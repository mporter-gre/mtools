server = 'howe.openmicroscopy.org.uk';
user = 'user-1';
password = 'ome';
client = omero.client(server,4064);
session = client.createSession(user, password);
name = 'blee';



project = createProject(session, name); %Create a project
dataset = createDataset(session, name); %Create a dataset
dataset = createDataset(session, name, project);  %Create a dataset within project
projectId = project.getId.getValue;
%projectId = 5555;
dataset = createDataset(session, name, projectId);  %Create a dataset within project identified by projectId


screen = createScreen(session, name); %Create a screen
plate = createPlate(session, name); %Create a plate
plate = createPlate(session, name, screen);  %Create a plate within a screen
screenId = screen.getId.getValue;
screenId = 6666;
plate = createPlate(session, name, screenId);  %Create a plate within screen identified by screenId

