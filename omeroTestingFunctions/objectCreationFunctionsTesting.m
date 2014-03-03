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

