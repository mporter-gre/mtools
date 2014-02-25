function clickSection(hObject, eventData, handles)

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

global sectionClicked;
global sectionFigure;
global fig1;

theChildren = sort(allchild(hObject));
currentObject = get(sectionFigure, 'CurrentObject');
if currentObject == 1 || currentObject == 2 || currentObject == 3 || currentObject == 4
    return;
end
[itIs sectionClicked] = ismember(gca, theChildren);
set(get(gca,'Title'),'Color','r')
guidata(hObject, handles);
uiresume(sectionFigure);

end
