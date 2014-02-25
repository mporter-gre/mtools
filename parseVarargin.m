function itemVal = parseVarargin(item, argsIn)
%Parse the varargin for specific switches to get the values. 'item' is a
%string relating to the switch. Possible switches are:
%       -k for sessionId
%       -s for server
%       -p for port
%       -w for workflow
%       -d for datasetId (one value only)
%       -i for imageId (one value only)
%       -t for type (dataset/image/plate etc)
%       id for one or more ids for the objects specified by -t.
%              These ids should terminate the list of arguments.


itemIdFind = strfind(argsIn, item);
itemIdx = findIndex(itemIdFind) +1;
if strcmpi(item, 'id')
    itemVal = varargin{itemIdx:end};
else
    itemVal = varargin{itemIdx};
end