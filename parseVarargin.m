function [sessionId, server, port, workflow, datatype, ids] = parseVarargin(varargin)
varargin = varargin{1};
numArgs = length(varargin);

sessionIdFind = strfind(varargin, '--sid');
sessionIdIdx = findIndex(sessionIdFind) + 1;
portFind = strfind(varargin, '-p');
portIdx = findIndex(portFind) + 1;
serverFind = strfind(varargin, '-s');
serverIdx = findIndex(serverFind) + 1;
workflowFind = strfind(varargin, '-w');
workflowIdx = findIndex(workflowFind) + 1;
datatypeFind = strfind(varargin, '-t');
datatypeIdx = findIndex(datatypeFind) + 1;
idsFind = strfind(varargin, 'id');
idsIdx = findIndex(idsFind) + 1;


sessionId = varargin{sessionIdIdx};
server = varargin{serverIdx};
port = varargin{portIdx};
workflow = varargin{workflowIdx};
datatype = varargin{datatypeIdx};
ids = varargin{idsIdx:end};
