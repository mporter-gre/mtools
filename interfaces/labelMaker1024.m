function varargout = labelMaker1024(varargin)
% LABELMAKER1024 M-file for labelmaker1024.fig
%      LABELMAKER1024, by itself, creates a new LABELMAKER1024 or raises the existing
%      singleton*.
%
%      H = LABELMAKER1024 returns the handle to a new LABELMAKER1024 or the handle to
%      the existing singleton*.
%
%      LABELMAKER1024('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABELMAKER1024.M with the given input arguments.
%
%      LABELMAKER1024('Property','Value',...) creates a new LABELMAKER1024 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before labelMaker1024_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to labelMaker1024_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help labelmaker1024

% Last Modified by GUIDE v2.5 01-Nov-2010 11:39:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @labelMaker1024_OpeningFcn, ...
                   'gui_OutputFcn',  @labelMaker1024_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before labelmaker1024 is made visible.
function labelMaker1024_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to labelmaker1024 (see VARARGIN)

global gateway;
warning off MATLAB:xlswrite:NoCOMServer
%Set up the play and pause buttons
startImage = imread('startImagePoints.jpg', 'jpg');
playIcon = imread('playButton.png', 'png');
pauseIcon = imread('pauseButton.png', 'png');
arrowIcon = imread('arrowButton.png', 'png');
crosshairIcon = imread('crosshairButton.png', 'png');
deletePointIcon = imread('deletePointButton.png', 'png');
set(handles.playButton,'CDATA',playIcon);
set(handles.pauseButton,'CDATA',pauseIcon);
set(handles.arrowButton,'CDATA',arrowIcon);
set(handles.crosshairButton,'CDATA',crosshairIcon);
set(handles.deletePointButton,'CDATA',deletePointIcon);

set(handles.labelMaker, 'WindowButtonUpFcn', {@imageAnchor_ButtonUpFcn, handles});
axes(handles.imageAxes);
imshow(startImage);

% Choose default command line output for labelmaker1024
set(handles.labelMaker, 'windowbuttonmotionfcn', {@windowButtonMotion, handles});
set(handles.labelMaker, 'keypressfcn', {@currentWindowKeypress, handles});
handles.output = hObject;

setappdata(handles.labelMaker, 'username', varargin{1});
setappdata(handles.labelMaker, 'server', varargin{2});
setappdata(handles.labelMaker, 'recentreROI', 0);
setappdata(handles.labelMaker, 'numT', 1);
setappdata(handles.labelMaker, 'numZ', 1);
setappdata(handles.labelMaker, 'modified', 0);
setappdata(handles.labelMaker, 'currDir', pwd);
setappdata(handles.labelMaker, 'zoomLevel', 1);
setappdata(handles.labelMaker, 'zoomROIMinMax', []);
setappdata(handles.labelMaker, 'setPoint', 0);
setappdata(handles.labelMaker, 'selectedPoint', []);
setappdata(handles.labelMaker, 'showLabelText', 0);
setappdata(handles.labelMaker, 'sizeXY', [900 900]);
setappdata(handles.labelMaker, 'filePath', []);
setappdata(handles.labelMaker, 'fileName', []);
setappdata(handles.labelMaker, 'labelsPath', []);
setappdata(handles.labelMaker, 'labelsName', []);
setappdata(handles.labelMaker, 'flattenZ', 0);
setappdata(handles.labelMaker, 'flattenT', 0);
setappdata(handles.labelMaker, 'cancelledOpenImage', 0);
set(handles.imageNameLabel, 'String', 'No File Open');
set(handles.tSlider, 'Enable', 'off');
setZSlider(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes labelmaker1024 wait for user response (see UIRESUME)
uiwait(handles.labelMaker);


% --- Outputs from this function are returned to the command line.
function varargout = labelMaker1024_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;



% --- Executes on slider movement.
function tSlider_Callback(hObject, eventdata, handles)
% hObject    handle to tSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

z = round(get(handles.zSlider, 'Value'));
t = round(get(hObject, 'Value'));
set(handles.tLabel, 'String', ['T = ' num2str(t)]);
getPlane(handles, z-1, t-1);
refreshDisplay(handles);


% --- Executes during object creation, after setting all properties.
function tSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function getPlane(handles, z, t)

pixelsId = getappdata(handles.labelMaker, 'pixelsId');
pixels = getappdata(handles.labelMaker, 'pixels');
numC = getappdata(handles.labelMaker, 'numC');
for thisC = 1:numC
    plane(:,:,thisC) = getPlaneFromPixelsId(pixelsId, z, thisC-1, t);
end
renderedImage = createRenderedImage(plane, pixels);
imageSize = size(renderedImage);
setappdata(handles.labelMaker, 'renderedImage', renderedImage);
setappdata(handles.labelMaker, 'imageSize', imageSize);




function setTSlider(handles)

numT = getappdata(handles.labelMaker, 'numT');
if numT > 1
    sliderSmallStep = 1/numT;
    set(handles.tSlider, 'Max', numT);
    set(handles.tSlider, 'Min', 1);
    set(handles.tSlider, 'Value', 1);
    set(handles.tSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
    set(handles.tSlider, 'Enable', 'on');
    set(handles.tLabel, 'String', 'T = 1');
else
    set(handles.zSlider, 'Enable', 'off');
    set(handles.zSlider, 'Value', 1);
end


function setZSlider(handles)

numZ = getappdata(handles.labelMaker, 'numZ');
if numZ > 1
    sliderSmallStep = 1/numZ;
    set(handles.zSlider, 'Max', numZ);
    set(handles.zSlider, 'Min', 1);
    set(handles.zSlider, 'Value', 1);
    set(handles.zSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
    set(handles.zSlider, 'Enable', 'on');
    set(handles.zLabel, 'String', 'Z = 1');
else
    set(handles.zSlider, 'Enable', 'off');
    set(handles.zSlider, 'Value', 1);
end


% --- Executes on slider movement.
function zSlider_Callback(hObject, eventdata, handles)
% hObject    handle to zSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

z = round(get(hObject, 'Value'));
t = round(get(handles.tSlider, 'Value'));
set(handles.zLabel, 'String', ['Z = ' num2str(z)]);
getPlane(handles, z-1, t-1);
refreshDisplay(handles);



% --- Executes during object creation, after setting all properties.
function zSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function imageAnchor_ButtonDownFcn(hObject, eventdata, handles)

pointer = get(gcf, 'Pointer');
if getappdata(handles.labelMaker, 'setPoint') == 1 && strcmp(pointer, 'crosshair')
    setPoint(handles);
end
if getappdata(handles.labelMaker, 'setPoint') == 0
    deselectPoint(handles);
end

function imageAnchor_ButtonUpFcn(hObject, eventdata, handles)

setappdata(handles.labelMaker, 'deleteLock', 0);


function redrawImage(handles)

displayImage = getappdata(handles.labelMaker, 'renderedImage');
handles.imageHandle = imshow(displayImage);
set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
setappdata(handles.labelMaker, 'thisImageHandle', handles.imageHandle);




function windowButtonMotion(hObject, eventdata, handles)

currentPoint = get(handles.imageAxes, 'CurrentPoint');
setappdata(handles.labelMaker, 'currentPoint', currentPoint);
axesPosition = get(handles.imageAxes, 'Position');
sizeXY = getappdata(handles.labelMaker, 'sizeXY');
xMod = axesPosition(3)/sizeXY(1);
yMod = axesPosition(4)/sizeXY(2);
if currentPoint(1) > 0 && currentPoint(1) <= (axesPosition(3) / xMod) && currentPoint(3) > 0 && currentPoint(3) <= (axesPosition(4) / yMod) && getappdata(handles.labelMaker, 'setPoint') == 1
    set(gcf, 'Pointer', 'crosshair');
else
    set(gcf, 'Pointer', 'arrow');
end




% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

numT = getappdata(handles.labelMaker, 'numT');
firstT = round(get(handles.tSlider, 'Value'));
%frameDelay = str2double(get(handles.delayText, 'String'));
%alignPos = getappdata(handles.labelMaker1024, 'alignPos');
%rotationView = getappdata(handles.labelMaker1024, 'rotationView');
%includeROI = getappdata(handles.labelMaker1024, 'includeROI');
% if frameDelay < 0.01
%     frameDelay = 0.01;
% end
if getappdata(handles.labelMaker, 'playing') == 1
    return;
end
setappdata(handles.labelMaker, 'interruptPlay', 0);
for thisT = firstT:numT
    interruptPlay = getappdata(handles.labelMaker, 'interruptPlay');
    if interruptPlay == 1
        break;
    end
    setappdata(handles.labelMaker, 'playing', 1);
    set(handles.tSlider, 'Value', thisT);
    set(handles.tLabel, 'String', ['T = ' num2str(thisT)]);
    thisZ = round(get(handles.zSlider, 'Value'));
    getPlane(handles, thisZ-1, thisT-1)
    %redrawImage(handles);
    refreshDisplay(handles);
    pause(0.05);
end
setappdata(handles.labelMaker, 'playing', 0);
setappdata(handles.labelMaker, 'interruptPlay', 0);



% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.labelMaker, 'interruptPlay', 1);



function currentWindowKeypress(hObject, eventdata, handles)

currentKey = eventdata.Key;
if strcmp(currentKey, 'escape')
    setappdata(handles.labelMaker, 'stopRecording', 1);
end
if strcmp(currentKey, 'f5')
    refreshDisplay(handles);
end
if strcmp(currentKey, 'delete')
    deletePoint(handles);
end



function mouseClick

robot = java.awt.Robot;
robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);


% --------------------------------------------------------------------
function viewMenu_Callback(hObject, eventdata, handles)
% hObject    handle to viewMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function fileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function openImageItem_Callback(hObject, eventdata, handles)
% hObject    handle to openImageItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

modified = getappdata(handles.labelMaker, 'modified');
if modified == 1
    answer = questdlg([{'The current set of points has been modified.'} {'Discard changes and open a new image?'}], 'Discard Changes?', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')
        return;
    end
end

imageId = getappdata(handles.labelMaker, 'imageId');
ImageSelector(handles, 'labelMaker');
cancelledOpenImage = getappdata(handles.labelMaker, 'cancelledOpenImage');
if cancelledOpenImage == 1
    setappdata(handles.labelMaker, 'cancelledOpenImage', 0);
    return;
end
newImageObj = getappdata(handles.labelMaker, 'newImageObj');
newImageId = newImageObj.getId.getValue;
if newImageId == imageId
    return;
end
setappdata(handles.labelMaker, 'theImage', newImageObj);
setappdata(handles.labelMaker, 'imageId', newImageId);
getMetadata(handles);
setappdata(handles.labelMaker, 'newImageObj', []);
setappdata(handles.labelMaker, 'newImageId', []);
setappdata(handles.labelMaker, 'points', []);
setappdata(handles.labelMaker, 'filePath', []);
setappdata(handles.labelMaker, 'fileName', []);
setappdata(handles.labelMaker, 'modified', 0);
redrawImage(handles);




% --------------------------------------------------------------------
function refreshItem_Callback(hObject, eventdata, handles)
% hObject    handle to refreshItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

refreshDisplay(handles);


function refreshDisplay(handles)

redrawImage(handles);
redrawPoints(handles);




% --- Executes during object creation, after setting all properties.
function roiSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function savePointsItem_Callback(hObject, eventdata, handles)
% hObject    handle to savePointsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

points = getappdata(handles.labelMaker, 'points');
if isempty(points)
    warndlg('There are no points to save.', 'No points');
    return;
end
filePath = getappdata(handles.labelMaker, 'filePath');
fileName = getappdata(handles.labelMaker, 'fileName');
if ~strcmpi(fileName(end-3:end), '.mat')
    fileName = [fileName '.mat'];
end
if isempty(fileName) || isempty(filePath);
    [fileName filePath] = uiputfile('*.mat', 'Save labels', [filePath fileName]);
    if fileName == 0
        return;
    end
end
labelText = getappdata(handles.labelMaker, 'labelText');
labelColour = getappdata(handles.labelMaker, 'labelColour');
projectId = getappdata(handles.labelMaker, 'projectId');
datasetId = getappdata(handles.labelMaker, 'datasetId');
imageId = getappdata(handles.labelMaker, 'imageId');

save([filePath fileName], 'points', 'projectId', 'datasetId', 'imageId', 'labelText', 'labelColour');
setappdata(handles.labelMaker, 'filePath', filePath);
setappdata(handles.labelMaker, 'fileName', fileName);
setappdata(handles.labelMaker, 'modified', 0);
msgbox('Points saved', 'Saved');




% --------------------------------------------------------------------
function savePointsAsItem_Callback(hObject, eventdata, handles)
% hObject    handle to savePointsAsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

points = getappdata(handles.labelMaker, 'points');
if isempty(points)
    warndlg('There are no points to save.', 'No points');
    return;
end
imageId = getappdata(handles.labelMaker, 'imageId');
labelText = getappdata(handles.labelMaker, 'labelText');
labelColour = getappdata(handles.labelMaker, 'labelColour');
projectId = getappdata(handles.labelMaker, 'projectId');
datasetId = getappdata(handles.labelMaker, 'datasetId');
imageId = getappdata(handles.labelMaker, 'imageId');

[fileName filePath] = uiputfile('*.mat', 'Save labels');

if fileName == 0
    return;
end

save([filePath fileName], 'points', 'points', 'projectId', 'datasetId', 'imageId', 'labelText', 'labelColour');
setappdata(handles.labelMaker, 'filePath', filePath);
setappdata(handles.labelMaker, 'fileName', fileName);
setappdata(handles.labelMaker, 'modified', 0);



% --------------------------------------------------------------------
function quitItem_Callback(hObject, eventdata, handles)
% hObject    handle to quitItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.labelMaker);



% --- Executes on button press in arrowButton.
function arrowButton_Callback(hObject, eventdata, handles)
% hObject    handle to arrowButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.labelMaker, 'setPoint', 0);


% --- Executes on button press in crosshairButton.
function crosshairButton_Callback(hObject, eventdata, handles)
% hObject    handle to crosshairButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.labelMaker, 'setPoint', 1);
deselectPoint(handles);


% --- Executes on button press in addLabelButton.
function addLabelButton_Callback(hObject, eventdata, handles)
% hObject    handle to addLabelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


defineLabel(handles);
newLabelColour = getappdata(handles.labelMaker, 'newLabelColour');
newLabelText = getappdata(handles.labelMaker, 'newLabelText');
labelText = getappdata(handles.labelMaker, 'labelText');
if isempty(labelText)
    firstLabel = 1;
else 
    firstLabel = 0;
end
labelColour = getappdata(handles.labelMaker, 'labelColour');
if ~isempty(newLabelText)
    labelText = [labelText {newLabelText}];
    labelColour = [labelColour {newLabelColour}];
    set(handles.labelSelect, 'String', labelText);
    if firstLabel == 0
        set(handles.labelSelect, 'Value', length(labelText));
        set(handles.labelSelect, 'ForegroundColor', newLabelColour);
    end
    setappdata(handles.labelMaker, 'labelText', labelText);
    setappdata(handles.labelMaker, 'labelColour', labelColour);
    if length(labelColour) == 1
        set(handles.labelSelect, 'ForegroundColor', labelColour{1});
    end
end
    


% --- Executes on selection change in labelSelect.
function labelSelect_Callback(hObject, eventdata, handles)
% hObject    handle to labelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns labelSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from labelSelect

labelIdx = get(hObject, 'Value');
labelString = get(hObject, 'String');
%labelText = labelString{labelIdx};
if ~strcmp(labelString, 'Add a label')
    labelColour = getappdata(handles.labelMaker, 'labelColour');
    thisColour = labelColour{labelIdx};
    set(hObject, 'ForegroundColor', thisColour);
end


% --- Executes during object creation, after setting all properties.
function labelSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in deleteLabel.
function deleteLabel_Callback(hObject, eventdata, handles)
% hObject    handle to deleteLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

labelText = getappdata(handles.labelMaker, 'labelText');
labelColour = getappdata(handles.labelMaker, 'labelColour');
points = getappdata(handles.labelMaker, 'points');
labelIdx = get(handles.labelSelect, 'Value');
labelSelectString = get(handles.labelSelect, 'String');
numLabels = length(labelText);
if strcmp(labelSelectString, 'Add a label')
    return;
end
answer = questdlg([{'Are you sure you want to delete this label?'} {'All points with this label will be deleted too.'}], 'Delete label?', 'Yes', 'No', 'No');
if strcmp(answer, 'No')
    return;
end
if labelIdx == numLabels
    if labelIdx == 1
        newLabelText = [];
        newLabelColour = [];
        set(handles.labelSelect, 'ForegroundColor', 'k');
        set(handles.labelSelect, 'String', 'Add a label');
    else
        for thisLabel = 1:numLabels-1
            newLabelText{thisLabel} = labelText{thisLabel};
            newLabelColour{thisLabel} = labelColour{thisLabel};
        end
        set(handles.labelSelect, 'Value', labelIdx-1);
        set(handles.labelSelect, 'ForegroundColor', newLabelColour{labelIdx-1});
        set(handles.labelSelect, 'String', newLabelText);
    end
else
    for thisLabel = 1:numLabels-1
        if thisLabel < labelIdx
            newLabelText{thisLabel} = labelText{thisLabel};
            newLabelColour{thisLabel} = labelColour{thisLabel};
        else
            newLabelText{thisLabel} = labelText{thisLabel+1};
            newLabelColour{thisLabel} = labelColour{thisLabel+1};
        end
    end
    if labelIdx ~= 1
        set(handles.labelSelect, 'Value', labelIdx-1);
        set(handles.labelSelect, 'ForegroundColor', newLabelColour{labelIdx-1});
    else
        set(handles.labelSelect, 'ForegroundColor', newLabelColour{1});
    end
    set(handles.labelSelect, 'String', newLabelText);
end

%Now remove all the points from the points cell structre
numPoints = length(points);
newPoints = [];
modifier = 0;
copyPoints = [];
for thisPoint = 1:numPoints
    if strcmpi(points{thisPoint}.label, labelSelectString{labelIdx});
        thePoint = points{thisPoint}.PointHandle;
        api = iptgetapi(thePoint);
        api.delete();
    else
        copyPoints = [copyPoints thisPoint];
    end
end
counter = 1;
for thisPoint = 1:numPoints
    if ismember(thisPoint, copyPoints)
        newPoints{counter} = points{thisPoint};
        counter = counter + 1;
    end
end

setappdata(handles.labelMaker, 'points', newPoints);
setappdata(handles.labelMaker, 'labelText', newLabelText);
setappdata(handles.labelMaker, 'labelColour', newLabelColour);



% --- Executes when user attempts to close labelMaker1024.
function labelMaker_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to labelMaker1024 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

modified = getappdata(handles.labelMaker, 'modified');
if modified == 1
    answer = questdlg([{'The current set of points has been modified.'} {'Quit the application anyway?'}], 'Discard Changes?', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')
        return;
    end
end
gatewayDisconnect;
delete(hObject);


function setPoint(handles)

points = getappdata(handles.labelMaker, 'points');
labelColour = getappdata(handles.labelMaker, 'labelColour');
currentPoint = getappdata(handles.labelMaker, 'currentPoint');
labelString = get(handles.labelSelect, 'String');
if strcmp(labelString, 'Add a label')
    errordlg('You must add a label before setting points.', 'No labels');
    setappdata(handles.labelMaker, 'setPoint', 0);
    return;
end
labelIdx = get(handles.labelSelect, 'Value');
label = labelString{labelIdx};
colour = labelColour{labelIdx};
thisZ = round(get(handles.zSlider, 'Value'));
thisT = round(get(handles.tSlider, 'Value'));
if iscell(points)
    currPoint = length(points)+1;
    thePoint = impoint(gca,currentPoint(1), currentPoint(3));
    set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
    points{currPoint}.label = label;
    points{currPoint}.Position = [currentPoint(1) currentPoint(3) thisZ thisT];
    points{currPoint}.PointHandle = thePoint;
    points{currPoint}.Colour = colour;
else
    thePoint = impoint(gca,currentPoint(1), currentPoint(3));
    set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
    points{1}.label = label;
    points{1}.Position = [currentPoint(1) currentPoint(3) thisZ thisT];
    points{1}.PointHandle = thePoint;
    points{1}.Colour = colour;
end

thePointHandle = findobj(thePoint,'-depth',0);
api = iptgetapi(thePoint);
fcn = makeConstrainToRectFcn('impoint', [currentPoint(1) currentPoint(1)], [currentPoint(3) currentPoint(3)]);
api.setPositionConstraintFcn(fcn);
api.setColor(colour);
iptaddcallback(thePointHandle, 'ButtonDownFcn', {@point_ButtonDownFcn, handles});
showLabels = getappdata(handles.labelMaker, 'showLabelText');
if showLabels == 1
    api.setString(label);
end

setappdata(handles.labelMaker, 'modified', 1);
setappdata(handles.labelMaker, 'points', points);



function point_ButtonDownFcn(hObject, eventdata, handles)

setappdata(handles.labelMaker, 'deleteLock', 1);
setPoint = getappdata(handles.labelMaker, 'setPoint');
if setPoint == 1
    return;
end
deselectPoint(handles);
thePoint = get(gcf, 'CurrentObject');
points = getappdata(handles.labelMaker, 'points');
numPoints = length(points);
for thisPoint = 1:numPoints
    if findobj(points{thisPoint}.PointHandle,'-depth',0) == thePoint
        colour = points{thisPoint}.Colour;
    end
end
api = iptgetapi(thePoint);
api.setColor('w');
set(handles.deletePointButton, 'Enable', 'on');
setappdata(handles.labelMaker, 'selectedPoint', thePoint);
setappdata(handles.labelMaker, 'selectedOrigColour', colour);


function deselectPoint(handles)

thePoint = getappdata(handles.labelMaker, 'selectedPoint');
colour = getappdata(handles.labelMaker, 'selectedOrigColour');
if isempty(thePoint)
    return;
end
api = iptgetapi(thePoint);
api.setColor(colour);
setappdata(handles.labelMaker, 'selectedPoint', []);
setappdata(handles.labelMaker, 'selectedOrigColour', []);
set(handles.deletePointButton, 'Enable', 'off');


function deletePoint(handles)

thePoint = getappdata(handles.labelMaker, 'selectedPoint');
thePointHandle = findobj(thePoint,'-depth',0);
locked = getappdata(handles.labelMaker, 'deleteLock');
if isempty(thePoint) || locked == 1
    return;
end

points = getappdata(handles.labelMaker, 'points');
modifier = 0;
if iscell(points)
    numPoints = length(points);
    newPoints = [];
    for thisPoint = 1:numPoints
        if thePointHandle == findobj(points{thisPoint}.PointHandle,'-depth',0)
            points{thisPoint} = [];
            break;
        end
    end
    if thisPoint == 1
        for thisPoint = 2:numPoints
            newPoints{thisPoint-1} = points{thisPoint};
        end
    else
        for thisPoint = 1:numPoints-1
            if isempty(points{thisPoint})
                modifier = 1;
            end
            newPoints{thisPoint} = points{thisPoint+modifier};
        end
        
    end
else
    newPoints = [];
end

api = iptgetapi(thePoint);
api.delete();

setappdata(handles.labelMaker, 'points', newPoints);
setappdata(handles.labelMaker, 'selectedPoint', []);
setappdata(handles.labelMaker, 'selectedOrigColour', []);
setappdata(handles.labelMaker, 'modified', 1);
set(handles.deletePointButton, 'Enable', 'off');



function redrawPoints(handles)

showLabels = getappdata(handles.labelMaker, 'showLabelText');
flattenZ = getappdata(handles.labelMaker, 'flattenZ');
flattenT = getappdata(handles.labelMaker, 'flattenT');
numZ = getappdata(handles.labelMaker, 'numZ');
numT = getappdata(handles.labelMaker, 'numT');
points = getappdata(handles.labelMaker, 'points');
if isempty(points)
    return;
end
if flattenZ == 1
    thisZ = 1:numZ;
else
    thisZ = round(get(handles.zSlider, 'Value'));
end
if flattenT == 1
    thisT = 1:numT;
else
    thisT = round(get(handles.tSlider, 'Value'));
end
numPoints = length(points);
for thisPoint = 1:numPoints
    thisPointX = points{thisPoint}.Position(1);
    thisPointY = points{thisPoint}.Position(2);
    thisPointZ = points{thisPoint}.Position(3);
    thisPointT = points{thisPoint}.Position(4);
    colour = points{thisPoint}.Colour;
    
    if ismember(thisPointZ, thisZ)
        if ismember(thisPointT, thisT)
            thePoint = impoint(gca, thisPointX, thisPointY);
            thePointHandle = findobj(thePoint,'-depth',0);
            api = iptgetapi(thePoint);
            fcn = makeConstrainToRectFcn('impoint', [thisPointX thisPointX], [thisPointY thisPointY]);
            api.setPositionConstraintFcn(fcn);
            api.setColor(colour);
            iptaddcallback(thePointHandle, 'ButtonDownFcn', {@point_ButtonDownFcn, handles});
            points{thisPoint}.PointHandle = thePoint;
            if showLabels == 1
                api.setString(points{thisPoint}.label);
            end
        end
    end
end
setappdata(handles.labelMaker, 'points', points);


% --------------------------------------------------------------------
function showLabelTextItem_Callback(hObject, eventdata, handles)
% hObject    handle to showLabelTextItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

showLabels = getappdata(handles.labelMaker, 'showLabelText');

if showLabels == 0
    setappdata(handles.labelMaker, 'showLabelText', 1);
    set(hObject, 'Checked', 'on');
else
    setappdata(handles.labelMaker, 'showLabelText', 0);
    set(hObject, 'Checked', 'off');
end
refreshDisplay(handles);


% --------------------------------------------------------------------
function openPointsItem_Callback(hObject, eventdata, handles)
% hObject    handle to openPointsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gateway

modified = getappdata(handles.labelMaker, 'modified');
if modified == 1
    answer = questdlg([{'The current set of points has been modified.'} {'Discard changes and open a new points file?'}], 'Discard Changes?', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')
        return;
    end
end

[fileName filePath] = uigetfile('*.mat', 'Open labels.');
if fileName == 0
    return;
end
vars = load([filePath fileName]);
theImage = gateway.getImage(vars.imageId);
setappdata(handles.labelMaker, 'points', vars.points);
setappdata(handles.labelMaker, 'projectId', vars.projectId);
setappdata(handles.labelMaker, 'datasetId', vars.datasetId);
setappdata(handles.labelMaker, 'imageId', vars.imageId);
setappdata(handles.labelMaker, 'theImage', theImage);
setappdata(handles.labelMaker, 'labelText', vars.labelText)
setappdata(handles.labelMaker, 'labelColour', vars.labelColour)
setappdata(handles.labelMaker, 'filePath', filePath)
setappdata(handles.labelMaker, 'fileName', fileName)
set(handles.labelSelect, 'String', vars.labelText);
set(handles.labelSelect, 'Value', 1);
getMetadata(handles);
refreshDisplay(handles);



% --------------------------------------------------------------------
function openLabelDefsItem_Callback(hObject, eventdata, handles)
% hObject    handle to openLabelDefsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

labelText = getappdata(handles.labelMaker, 'labelText');
if ~isempty(labelText)
    answer = questdlg([{'Opening a previous label file will discard the'} {'current labels and points made. Continue?'}], 'Discard labels and points?', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')
        return;
    end
end
[labelsName labelsPath] = uigetfile('*.mat', 'Load label definitions');
if labelsName == 0
    return;
end
vars = load([labelsPath labelsName]);
if ~isfield(vars, 'labelDefFile')
    warndlg('This does not appear to be a valid label definition file', 'File not valid');
    return;
end

setappdata(handles.labelMaker, 'labelText', vars.labelText);
setappdata(handles.labelMaker, 'labelColour', vars.labelColour);
setappdata(handles.labelMaker, 'labelsPath', labelsPath);
setappdata(handles.labelMaker, 'labelsName', labelsName);
setappdata(handles.labelMaker, 'points', []);
set(handles.labelSelect, 'Value', 1);
set(handles.labelSelect, 'String', vars.labelText);
refreshDisplay(handles);




% --------------------------------------------------------------------
function saveLabelDefsItem_Callback(hObject, eventdata, handles)
% hObject    handle to saveLabelDefsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

labelsPath = getappdata(handles.labelMaker, 'labelsPath');
labelsName = getappdata(handles.labelMaker, 'labelsName');
labelText = getappdata(handles.labelMaker, 'labelText');
labelColour = getappdata(handles.labelMaker, 'labelColour');
labelDefFile = 'labelDefFile';

if isempty(labelText)
    warndlg('There are no labels to save', 'No labels');
    return;
end
if isempty(labelsName)
    [labelsName labelsPath] = uiputfile('*.mat', 'Save label definitions');
    if labelsName == 0
        return;
    end
end

save([labelsPath labelsName], 'labelText', 'labelColour', 'labelDefFile')
setappdata(handles.labelMaker, 'labelsPath', labelsPath);
setappdata(handles.labelMaker, 'labelsName', labelsName);



% --------------------------------------------------------------------
function saveLabelDefsAsItem_Callback(hObject, eventdata, handles)
% hObject    handle to saveLabelDefsAsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

labelsPath = getappdata(handles.labelMaker, 'labelsPath');
labelsName = getappdata(handles.labelMaker, 'labelsName');
labelText = getappdata(handles.labelMaker, 'labelText');
labelColour = getappdata(handles.labelMaker, 'labelColour');

if isempty(labelText)
    warndlg('There are no labels to save', 'No labels');
    return;
end

[labelsName labelsPath] = uiputfile('*.mat', 'Save label definitions');
if labelsName == 0
    return;
end

save([labelsPath labelsName], 'labelText', 'labelColour')
setappdata(handles.labelMaker, 'labelsPath', labelsPath);
setappdata(handles.labelMaker, 'labelsName', labelsName);



function getMetadata(handles)

global gateway
global session

theImage = getappdata(handles.labelMaker, 'theImage');
if isempty(theImage)
    return;
end
imageId = theImage.getId.getValue;
pixels = gateway.getPixelsFromImage(imageId);
pixels = pixels.get(0);
pixelsId = pixels.getId.getValue;

numC = pixels.getSizeC.getValue;
numT = pixels.getSizeT.getValue;
numZ = pixels.getSizeZ.getValue;
sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
renderingSettings = session.getRenderingSettingsService.getRenderingSettings(pixelsId);
defaultT = renderingSettings.getDefaultT.getValue + 1;
defaultZ = renderingSettings.getDefaultZ.getValue + 1;
imageName = char(theImage.getName.getValue.getBytes');

setappdata(handles.labelMaker, 'imageId', imageId);
setappdata(handles.labelMaker, 'imageName', imageName);
setappdata(handles.labelMaker, 'pixels', pixels)
setappdata(handles.labelMaker, 'pixelsId', pixelsId)
setappdata(handles.labelMaker, 'numC', numC);
setappdata(handles.labelMaker, 'numT', numT);
setappdata(handles.labelMaker, 'numZ', numZ);
setappdata(handles.labelMaker, 'defaultT', defaultT);
setappdata(handles.labelMaker, 'defaultZ', defaultZ);
setappdata(handles.labelMaker, 'zoomLevel', 1);
setappdata(handles.labelMaker, 'zoomROIMinMax', []);
setappdata(handles.labelMaker, 'sizeXY', [sizeX sizeY]);


set(handles.imageNameLabel, 'String', imageName);
setTSlider(handles);
setZSlider(handles);
set(handles.tSlider, 'Value', defaultT);
set(handles.tLabel, 'String', ['T = ' num2str(defaultT)]);
set(handles.zSlider, 'Value', defaultZ);
set(handles.zLabel, 'String', ['Z = ' num2str(defaultZ)]);
getPlane(handles, defaultZ-1, defaultT-1);


% --------------------------------------------------------------------
function flattenZItem_Callback(hObject, eventdata, handles)
% hObject    handle to flattenZItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

flattenZ = getappdata(handles.labelMaker, 'flattenZ');

if flattenZ == 0
    setappdata(handles.labelMaker, 'flattenZ', 1);
    set(hObject, 'Checked', 'on');
else
    setappdata(handles.labelMaker, 'flattenZ', 0);
    set(hObject, 'Checked', 'off');
end
refreshDisplay(handles);


% --------------------------------------------------------------------
function flattenTItem_Callback(hObject, eventdata, handles)
% hObject    handle to flattenTItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

flattenT = getappdata(handles.labelMaker, 'flattenT');

if flattenT == 0
    setappdata(handles.labelMaker, 'flattenT', 1);
    set(hObject, 'Checked', 'on');
else
    setappdata(handles.labelMaker, 'flattenT', 0);
    set(hObject, 'Checked', 'off');
end
refreshDisplay(handles);


% --------------------------------------------------------------------
function analysisMenu_Callback(hObject, eventdata, handles)
% hObject    handle to analysisMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function analysePointsItem_Callback(hObject, eventdata, handles)
% hObject    handle to analysePointsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

points = getappdata(handles.labelMaker, 'points');
if isempty(points)
    warndlg('No points to analyse.', 'No points');
    return;
end
imageName = getappdata(handles.labelMaker, 'imageName');
summaryByImage = pointsSummaryByImage(points, imageName);
summaryByT = pointsSummaryByT(points, imageName, handles);
summaryByZ = pointsSummaryByZ(points, imageName, handles);
[fileName filePath] = uiputfile('*.xls', 'Save data');
if fileName == 0
    return;
end
try
    xlswrite([filePath fileName], summaryByImage, 'Summary by Image');
catch
    [fileName remain] = strtok(fileName, '.');
    delete([filePath fileName]);
    manualCSV(summaryByImage, filePath, [fileName '_SummaryByImage']);
end
try
    xlswrite([filePath fileName], summaryByT, 'Summary by T');
catch
    manualCSV(summaryByImage, filePath, [fileName '_summaryByT']);
end
try
    xlswrite([filePath fileName], summaryByZ, 'Summary by Z');
catch
    manualCSV(summaryByImage, filePath, [fileName '_summaryByZ']);
end





% --------------------------------------------------------------------
function batchAnalysisItem_Callback(hObject, eventdata, handles)
% hObject    handle to batchAnalysisItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gateway;

warning('off', 'MATLAB:xlswrite:AddSheet');
setappdata(handles.labelMaker, 'conditions', []);
setappdata(handles.labelMaker, 'conditionsPaths', []);
setappdata(handles.labelMaker, 'conditionsFiles', []);

batchChooser(handles);

conditions = getappdata(handles.labelMaker, 'conditions');
conditionsPaths = getappdata(handles.labelMaker, 'conditionsPaths');
conditionsFiles = getappdata(handles.labelMaker, 'conditionsFiles');
analyseIndividualFiles = getappdata(handles.labelMaker, 'analyseIndividualFiles');
numConditions = length(conditions);
numSteps = 1;
for thisCondition = 1:numConditions
    numFilesThisCondition = length(conditionsFiles{thisCondition});
    for thisFile = 1:numFilesThisCondition
        numSteps = numSteps + 1;
    end
end


if isempty(conditions)
    return;
end
[fileName filePath] = uiputfile('*.xls', 'Save batch data');
if fileName == 0
    return;
end
waitbarHandle = waitbar(0,'Analysing...');
thisStep = 1;
for thisCondition = 1:numConditions
    numFilesThisCondition = length(conditionsFiles{thisCondition});
    for thisFile = 1:numFilesThisCondition
        waitbar(thisStep/(numSteps+1));
        thisStep = thisStep + 1;
        [points{thisCondition}{thisFile} imageId{thisCondition}{thisFile}] = getPointsAndImageId([conditionsPaths{thisCondition} conditionsFiles{thisCondition}{thisFile}]);
        if analyseIndividualFiles == 1
            imageObj = gateway.getImage(imageId{thisCondition}{thisFile});
            imageNameFull = char(imageObj.getName.getValue.getBytes');
            imageNameScanned = textscan(imageNameFull, '%s', 'Delimiter', '/');
            imageNameNoPaths = imageNameScanned{1}{end};
            [imageName remain] = strtok(imageNameNoPaths, '.');
            imageNameXls = [imageName '.xls'];
            summaryByImage = pointsSummaryByImage(points{thisCondition}{thisFile}, imageName);
            summaryByT = pointsSummaryByT(points{thisCondition}{thisFile}, imageName, handles);
            summaryByZ = pointsSummaryByZ(points{thisCondition}{thisFile}, imageName, handles);
            try
                xlswrite([filePath imageNameXls], summaryByImage, 'Summary by Image');
            catch
                [fileName remain] = strtok(fileName, '.');
                delete([filePath fileName]);
                manualCSV(summaryByImage, filePath, [imageName '_SummaryByImage']);
            end
            try
                xlswrite([filePath imageNameXls], summaryByT, 'Summary by T');
            catch
                manualCSV(summaryByImage, filePath, [imageName '_summaryByT']);
            end
            try
                xlswrite([filePath imageNameXls], summaryByZ, 'Summary by Z');
            catch
                manualCSV(summaryByImage, filePath, [imageName '_summaryByZ']);
            end
        end
    end
end

batchSummary = batchPointsSummary(points, handles);
batchSummaryByT = batchPointsSummaryByT(points, handles);
batchSummaryByZ = batchPointsSummaryByZ(points, handles);
waitbar(1);
try
    xlswrite([filePath fileName], batchSummary, 'Batch Summary');
catch
    [fileName remain] = strtok(fileName, '.');
    manualCSV(summaryByImage, filePath, [fileName 'batchSummary']);
end
try
    xlswrite([filePath fileName], batchSummaryByT, 'Batch Summary By T');
catch
    manualCSV(summaryByImage, filePath, [fileName 'batchSummaryByT']);
end
try
    xlswrite([filePath fileName], batchSummaryByZ, 'Batch Summary By Z');
catch
    manualCSV(summaryByImage, filePath, [fileName 'batchSummaryByZ']);
end
close(waitbarHandle);
warndlg('Analysis complete', 'Complete');




function imageSummary = pointsSummaryByImage(points, imageName)

numPoints = length(points);

for thisPoint = 1:numPoints
    labels{thisPoint} = points{thisPoint}.label;
end
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
labelCounter(1:numLabels) = 0;
labelLine = [];
counterLine = [];
totalLine = [];
percentLine = [];
for thisLabel = 1:numLabels
    for thisPoint = 1:numPoints
        if strcmp(points{thisPoint}.label, uniqueLabels{thisLabel})
            labelCounter(thisLabel) = labelCounter(thisLabel) + 1;
        end
    end
    if thisLabel == 1
        titleLine = {imageName};
    else
        titleLine = [titleLine {''}];
    end
    labelLine = [labelLine {uniqueLabels{thisLabel}}];
    counterLine = [counterLine {num2str(labelCounter(thisLabel))}];
    totalLine = [totalLine labelCounter(thisLabel)];
end
for thisLabel = 1:numLabels
    percentLine = [percentLine {[num2str((totalLine(thisLabel)/(sum(totalLine))*100)), '%']}];
end

imageSummary = [titleLine; labelLine; counterLine; percentLine];



function summaryByT = pointsSummaryByT(points, imageName, handles)

numPoints = length(points);
numT = getappdata(handles.labelMaker, 'numT');

for thisPoint = 1:numPoints
    labels{thisPoint} = points{thisPoint}.label;
end
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
labelCounter(1:numLabels) = 0;
labelLine = [];
counterLine = [];
counterBlock = [];
tCounter(numT, numLabels) = 0;
for thisT = 1:numT
    for thisLabel = 1:numLabels
        for thisPoint = 1:numPoints
            currPoint = points{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
            if strcmp(currPoint.label, uniqueLabels{thisLabel})
                pointT = currPoint.Position(4);
                if thisT == pointT
                    tCounter(thisT, thisLabel) = tCounter(thisT, thisLabel) + 1;
                end
            end
        end
    end
end

for thisT = 1:numT
    if thisT == 1
        titleLine = {imageName};
        labelLine = {''};
    end
    counterLine = {['T:', num2str(thisT)]};
    
    for thisLabel = 1:numLabels
        if thisT == 1
            labelLine = [labelLine {uniqueLabels{thisLabel}}];
            titleLine = [titleLine {''}];
        end
        counterLine = [counterLine {num2str(tCounter(thisT, thisLabel))}];
    end
    counterBlock = [counterBlock; counterLine];
end

summaryByT = [titleLine; labelLine; counterBlock];



function summaryByZ = pointsSummaryByZ(points, imageName, handles)

numPoints = length(points);
numZ = getappdata(handles.labelMaker, 'numZ');

for thisPoint = 1:numPoints
    labels{thisPoint} = points{thisPoint}.label;
end
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
labelCounter(1:numLabels) = 0;
labelLine = [];
counterLine = [];
counterBlock = [];
zCounter(numZ, numLabels) = 0;
for thisZ = 1:numZ
    for thisLabel = 1:numLabels
        for thisPoint = 1:numPoints
            currPoint = points{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
            if strcmp(currPoint.label, uniqueLabels{thisLabel})
                pointZ = currPoint.Position(3);
                if thisZ == pointZ
                    zCounter(thisZ, thisLabel) = zCounter(thisZ, thisLabel) + 1;
                end
            end
        end
    end
end

for thisZ = 1:numZ
    if thisZ == 1
        titleLine = {imageName};
        labelLine = {''};
    end
    counterLine = {['Z:', num2str(thisZ)]};
    
    for thisLabel = 1:numLabels
        if thisZ == 1
            labelLine = [labelLine {uniqueLabels{thisLabel}}];
            titleLine = [titleLine {''}];
        end
        counterLine = [counterLine {num2str(zCounter(thisZ, thisLabel))}];
    end
    counterBlock = [counterBlock; counterLine];
end

summaryByZ = [titleLine; labelLine; counterBlock];



function [points imageId] = getPointsAndImageId(fileNamePath)

vars = load(fileNamePath);
points = vars.points;
imageId = vars.imageId;


function batchSummary = batchPointsSummary(points, handles)

conditions = getappdata(handles.labelMaker, 'conditions');
if isempty(conditions)
    return;
end
counter = 1;
numConditions = length(points);
for thisCondition = 1:numConditions
    numFiles = length(points{thisCondition});
    for thisFile = 1:numFiles
        numPoints = length(points{thisCondition}{thisFile});

        for thisPoint = 1:numPoints
            labels{counter} = points{thisCondition}{thisFile}{thisPoint}.label;
            counter = counter + 1;
        end
    end
end
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
labelCounter(numLabels, numConditions) = 0;
labelLine = [];
counterLine = [];
totalLine = [];
percentLine = [];
summaryBlock = [];

for thisLabel = 1:numLabels
    for thisCondition = 1:numConditions
        numFiles = length(points{thisCondition});
        for thisFile = 1:numFiles
            numPoints = length(points{thisCondition}{thisFile});
            for thisPoint = 1:numPoints
                if strcmp(points{thisCondition}{thisFile}{thisPoint}.label, uniqueLabels{thisLabel})
                    labelCounter(thisLabel, thisCondition) = labelCounter(thisLabel, thisCondition) + 1;
                end
            end
        end
    end
end

for thisLabel = 1:numLabels
    if thisLabel == 1
        labelLine = [{''} {uniqueLabels{thisLabel}}];
    else
        labelLine = [labelLine {uniqueLabels{thisLabel}}];
    end
end

for thisCondition = 1:numConditions
    for thisLabel = 1:numLabels
        if thisLabel == 1
            counterLine = {conditions{thisCondition}};
        end
        counterLine = [counterLine {num2str(labelCounter(thisLabel, thisCondition))}];
    end
    summaryBlock = [summaryBlock; counterLine];
end

batchSummary = [labelLine; summaryBlock;];



function batchSummaryByT = batchPointsSummaryByT(points, handles)

conditions = getappdata(handles.labelMaker, 'conditions');
if isempty(conditions)
    return;
end
counter = 1;
numConditions = length(points);
for thisCondition = 1:numConditions
    numFiles = length(points{thisCondition});
    for thisFile = 1:numFiles
        numPoints = length(points{thisCondition}{thisFile});
        for thisPoint = 1:numPoints
            labels{counter} = points{thisCondition}{thisFile}{thisPoint}.label;
            counter = counter + 1;
        end
    end
end
%Get the maximum time point from all points made.
maxT = 1;
for thisCondition = 1:numConditions
    numFiles = length(points{thisCondition});
    for thisFile = 1:numFiles
        numPoints = length(points{thisCondition}{thisFile});
        for thisPoint = 1:numPoints
            currPoint = points{thisCondition}{thisFile}{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
            pointT = currPoint.Position(4);
            if pointT > maxT
                maxT = pointT;
            end
        end
    end
end

%Gather the data before making the output cell.
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
counterBlock = [];
for thisCondition = 1:numConditions
    tConditionCounter{thisCondition}(maxT, numLabels) = 0;
end
for thisLabel = 1:numLabels
    for thisCondition = 1:numConditions
        tFileCounter(1:maxT, 1:numLabels) = 0;
        numFiles = length(points{thisCondition});
        for thisFile = 1:numFiles
            numPoints = length(points{thisCondition}{thisFile});
            tCounter(1:maxT, 1:numLabels) = 0;
            for thisPoint = 1:numPoints
                currPoint = points{thisCondition}{thisFile}{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
                for thisT = 1:maxT
                    if strcmp(currPoint.label, uniqueLabels{thisLabel})
                        pointT = currPoint.Position(4);
                        if thisT == pointT
                            tCounter(thisT, thisLabel) = tCounter(thisT, thisLabel) + 1;
                        end
                    end
                end
                
            end
            tFileCounter = tFileCounter + tCounter;
        end
        tConditionCounter{thisCondition} = tConditionCounter{thisCondition} + tFileCounter;
    end
end

emptyLine = [];
for thisLabel = 1:numLabels+1
    emptyLine = [emptyLine {''}];
end

batchSummaryByT = [];
for thisCondition = 1:numConditions
    counterBlock = [];
    labelLine = {conditions{thisCondition}};
    for thisLabel = 1:numLabels
        labelLine = [labelLine {uniqueLabels{thisLabel}}];
    end
    for thisT = 1:maxT
        counterLine = {['T:', num2str(thisT)]};
        for thisLabel = 1:numLabels
            counterLine = [counterLine {num2str(tConditionCounter{thisCondition}(thisT, thisLabel))}];
        end
        counterBlock = [counterBlock; counterLine];
    end
    batchSummaryByT = [batchSummaryByT; labelLine; counterBlock; emptyLine; emptyLine];
end



function batchSummaryByZ = batchPointsSummaryByZ(points, handles)

conditions = getappdata(handles.labelMaker, 'conditions');
if isempty(conditions)
    return;
end
counter = 1;
numConditions = length(points);
for thisCondition = 1:numConditions
    numFiles = length(points{thisCondition});
    for thisFile = 1:numFiles
        numPoints = length(points{thisCondition}{thisFile});
        for thisPoint = 1:numPoints
            labels{counter} = points{thisCondition}{thisFile}{thisPoint}.label;
            counter = counter + 1;
        end
    end
end
%Get the maximum Z section from all points made.
maxZ = 1;
for thisCondition = 1:numConditions
    numFiles = length(points{thisCondition});
    for thisFile = 1:numFiles
        numPoints = length(points{thisCondition}{thisFile});
        for thisPoint = 1:numPoints
            currPoint = points{thisCondition}{thisFile}{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
            pointZ = currPoint.Position(3);
            if pointZ > maxZ
                maxZ = pointZ;
            end
        end
    end
end

%Gather the data before making the output cell.
uniqueLabels = unique(labels);
numLabels = length(uniqueLabels);
counterBlock = [];
for thisCondition = 1:numConditions
    zConditionCounter{thisCondition}(maxZ, numLabels) = 0;
end
for thisLabel = 1:numLabels
    for thisCondition = 1:numConditions
        zFileCounter(1:maxZ, 1:numLabels) = 0;
        numFiles = length(points{thisCondition});
        for thisFile = 1:numFiles
            numPoints = length(points{thisCondition}{thisFile});
            zCounter(1:maxZ, 1:numLabels) = 0;
            for thisPoint = 1:numPoints
                currPoint = points{thisCondition}{thisFile}{thisPoint}; % = [currentPoint(1) currentPoint(3) thisZ thisT];
                for thisZ = 1:maxZ
                    if strcmp(currPoint.label, uniqueLabels{thisLabel})
                        pointZ = currPoint.Position(3);
                        if thisZ == pointZ
                            zCounter(thisZ, thisLabel) = zCounter(thisZ, thisLabel) + 1;
                        end
                    end
                end
                
            end
            zFileCounter = zFileCounter + zCounter;
        end
        zConditionCounter{thisCondition} = zConditionCounter{thisCondition} + zFileCounter;
    end
end

emptyLine = [];
for thisLabel = 1:numLabels+1
    emptyLine = [emptyLine {''}];
end

batchSummaryByZ = [];
for thisCondition = 1:numConditions
    counterBlock = [];
    labelLine = {conditions{thisCondition}};
    for thisLabel = 1:numLabels
        labelLine = [labelLine {uniqueLabels{thisLabel}}];
    end
    for thisZ = 1:maxZ
        counterLine = {['Z:', num2str(thisZ)]};
        for thisLabel = 1:numLabels
            counterLine = [counterLine {num2str(zConditionCounter{thisCondition}(thisZ, thisLabel))}];
        end
        counterBlock = [counterBlock; counterLine];
    end
    batchSummaryByZ = [batchSummaryByZ; labelLine; counterBlock; emptyLine; emptyLine];
end


% --- Executes on button press in deletePointButton.
function deletePointButton_Callback(hObject, eventdata, handles)
% hObject    handle to deletePointButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


deletePoint(handles)
