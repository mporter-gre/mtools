function [sessionId, server, tool, datatype, ids] = parseVarargin(varargin)
varargin = varargin{1};
numArgs = length(varargin);

sessionIdFind = strfind(varargin, 'sid');
sessionIdIdx = findIndex(sessionIdFind) + 1;
serverFind = strfind(varargin, 'server');
serverIdx = findIndex(serverFind) + 1;
toolFind = strfind(varargin, 'tool');
toolIdx = findIndex(toolFind) + 1;
datatypeFind = strfind(varargin, 'dataType');
datatypeIdx = findIndex(datatypeFind) + 1;
idsFind = strfind(varargin, 'ids');
idsIdx = findIndex(idsFind) + 1;



sessionId = varargin{sessionIdIdx};
server = varargin{serverIdx};
tool = varargin{toolIdx};
datatype = varargin{datatypeIdx};
ids = varargin{idsIdx};