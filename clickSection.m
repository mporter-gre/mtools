function clickSection(hObject, eventData, handles)

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