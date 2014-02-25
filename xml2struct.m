function out = xml2struct(xmlfile)
% XML2STRUCT Read an XML file into a MATLAB structure.

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
xml = xmlread(xmlfile);

children = xml.getChildNodes;
for i = 1:children.getLength
    out(i) = node2struct(children.item(i-1));
end

function s = node2struct(node)

s.name = char(node.getNodeName);

if node.hasAttributes

    attributes = node.getAttributes;
    nattr = attributes.getLength;
    s.attributes = struct('name',cell(1,nattr),'value',cell(1,nattr));

    for i = 1:nattr
        attr = attributes.item(i-1);
        s.attributes(i).name = char(attr.getName);
        s.attributes(i).value = char(attr.getValue);
    end

else

    s.attributes = [];

end

try

    s.data = char(node.getData);

catch

    s.data = '';

end

if node.hasChildNodes

    children = node.getChildNodes;
    nchildren = children.getLength;
    c = cell(1,nchildren);
    s.children = struct('name',c,'attributes',c,'data',c,'children',c);

    for i = 1:nchildren
        child = children.item(i-1);
        s.children(i) = node2struct(child);
    end

else

    s.children = [];

end
