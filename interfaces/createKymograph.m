function varargout = createKymograph(varargin)
% CREATEKYMOGRAPH M-file for createkymograph.fig
%      CREATEKYMOGRAPH, by itself, creates a new CREATEKYMOGRAPH or raises the existing
%      singleton*.
%
%      H = CREATEKYMOGRAPH returns the handle to a new CREATEKYMOGRAPH or the handle to
%      the existing singleton*.
%
%      CREATEKYMOGRAPH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATEKYMOGRAPH.M with the given input arguments.
%
%      CREATEKYMOGRAPH('Property','Value',...) creates a new CREATEKYMOGRAPH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createKymograph_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createKymograph_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createkymograph

% Last Modified by GUIDE v2.5 05-Jun-2012 16:39:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createKymograph_OpeningFcn, ...
                   'gui_OutputFcn',  @createKymograph_OutputFcn, ...
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


% --- Executes just before createkymograph is made visible.
function createKymograph_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createkymograph (see VARARGIN)

global gateway;
global session;
renderSettingsService = session.getRenderingSettingsService;
%Set up the play and pause buttons
playIcon = imread('play24.png', 'png');
pauseIcon = imread('pause24.png', 'png');
pointers = load('pointers.mat');
set(handles.playButton,'CDATA',playIcon);
set(handles.pauseButton,'CDATA',pauseIcon);
diamondPointer = pointers.diamondPointer;
squarePointer = pointers.squarePointer;

% Choose default command line output for createkymograph
set(handles.CreateKymograph, 'windowbuttonmotionfcn', {@windowButtonMotion, handles});
set(handles.CreateKymograph, 'WindowButtonUpFcn', {@imageAnchor_ButtonUpFcn, handles});
set(handles.CreateKymograph, 'keypressfcn', {@currentWindowKeypress, handles});
handles.output = hObject;
handles.imageObj = varargin{1};
%imageId = handles.imageObj.getId.getValue;
%handles.pixels = gateway.getPixelsFromImage(imageId);
% if strcmp(class(handles.pixels), 'java.util.ArrayList');
%     handles.pixels = handles.pixels.get(0);
% end
% handles.pixelsId = handles.pixels.getId.getValue;
% handles.numC = handles.pixels.getSizeC.getValue;
%handles.fullImage = varargin{2};
% imageName = native2unicode(handles.imageObj.getName.getValue.getBytes');
% handles.imageName = imageName;
% set(handles.imageNameLabel, 'String', imageName);
% numT = handles.pixels.getSizeT.getValue;
% sizeX = handles.pixels.getSizeX.getValue;
% sizeY = handles.pixels.getSizeY.getValue;
% handles.numZ = handles.pixels.getSizeZ.getValue;
% settingsThisPixels = renderSettingsService.getRenderingSettings(handles.pixelsId);
% defaultZ = settingsThisPixels.getDefaultZ.getValue;

% anchorPos{numT} = [];
% rectPos{numT} = [];
% alignPos{numT} = [];
setappdata(handles.CreateKymograph, 'setAnchor', 0);
setappdata(handles.CreateKymograph, 'setAlignment', 0);
setappdata(handles.CreateKymograph, 'recordAnchor', 0);
setappdata(handles.CreateKymograph, 'recordAlignment', 0);
setappdata(handles.CreateKymograph, 'drawRect', 0);
setappdata(handles.CreateKymograph, 'firstAnchor', 1);
setappdata(handles.CreateKymograph, 'firstAlign', 1);
% setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
% setappdata(handles.CreateKymograph, 'rectPos', rectPos);
% setappdata(handles.CreateKymograph, 'alignPos', alignPos);
setappdata(handles.CreateKymograph, 'includeROI', []);
setappdata(handles.CreateKymograph, 'hideAnchor', 0);
setappdata(handles.CreateKymograph, 'recording', 0);
setappdata(handles.CreateKymograph, 'stopRecording', 0);
setappdata(handles.CreateKymograph, 'recordMode', 'playbackMode');
setappdata(handles.CreateKymograph, 'playing', 0);
setappdata(handles.CreateKymograph, 'rotationView', 0);
setappdata(handles.CreateKymograph, 'movingAnchor', 0);
setappdata(handles.CreateKymograph, 'movingAlign', 0);
setappdata(handles.CreateKymograph, 'hideROI', 0);
% setappdata(handles.CreateKymograph, 'numT', numT);
% setappdata(handles.CreateKymograph, 'numZ', handles.numZ);
% setappdata(handles.CreateKymograph, 'defaultZ', defaultZ);
setappdata(handles.CreateKymograph, 'projectionType', 'max');
setappdata(handles.CreateKymograph, 'diamondPointer', diamondPointer);
setappdata(handles.CreateKymograph, 'squarePointer', squarePointer);
setappdata(handles.CreateKymograph, 'sizeXY', [512 512]);
setappdata(handles.CreateKymograph, 'zoomClick', 0);
setappdata(handles.CreateKymograph, 'zoomLevel', 1);
setappdata(handles.CreateKymograph, 'projectId', []);
setappdata(handles.CreateKymograph, 'datasetId', []);
setappdata(handles.CreateKymograph, 'clearAnswer', []);
%setappdata(handles.CreateKymograph, 'imageSize', [sizeX sizeY]);
handles.parentWindowName = 'createKymograph';

enableDisableControls(handles, 'off');


% setTSlider(handles);
% setZSlider(handles);
% set(handles.stopZText, 'String', num2str(handles.numZ));
% 
% getPlane(handles, defaultZ, 0)
% refreshDisplay(handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createkymograph wait for user response (see UIRESUME)
uiwait(handles.CreateKymograph);


% --- Outputs from this function are returned to the command line.
function varargout = createKymograph_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];



% --- Executes on button press in rectButton.
function rectButton_Callback(hObject, eventdata, handles)
% hObject    handle to rectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.CreateKymograph, 'drawRect', 1);
redrawImage(handles);
thisT = round(get(handles.tSlider, 'Value'));
numT = getappdata(handles.CreateKymograph, 'numT');
anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
rectPos = getappdata(handles.CreateKymograph, 'rectPos');
for t = 1:numT
    %Reset any previously set ROI or anchor point to null;
    anchorPos{t} = [];
    rectPos{t} = [];
end

fullImageSize = size(getappdata(handles.CreateKymograph, 'renderedImage'));
maxX = fullImageSize(2);
maxY = fullImageSize(1);
rectPos{thisT} = round(getrect(handles.imageAxes));
zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
if zoomLevel > 1
    zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
    rectPos{thisT}(1) = rectPos{thisT}(1) + zoomMinMax(1);
    rectPos{thisT}(2) = rectPos{thisT}(2) + zoomMinMax(2);
end

if rectPos{thisT}(1) > 0 && rectPos{thisT}(1) <= maxX && rectPos{thisT}(2) > 0 && rectPos{thisT}(2) <= maxY
    for t = 1:numT
        rectPos{t} = rectPos{thisT};
    end
    try
        drawRectPos = rectPos;
        if zoomLevel > 1
            zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
            drawRectPos{thisT}(1) = rectPos{thisT}(1) - zoomMinMax(1);
            drawRectPos{thisT}(2) = rectPos{thisT}(2) - zoomMinMax(2);
        end
        rectangle('Position', drawRectPos{thisT}, 'edgecolor', 'white');
    catch
    end
    set(handles.setAnchorButton, 'Enable', 'on');
    set(handles.startTText, 'String', num2str(thisT));
    set(handles.startTText, 'Enable', 'on');
    set(handles.endTText, 'String', num2str(numT));
    set(handles.endTText, 'Enable', 'on');
    set(handles.createChymographButton, 'Enable', 'on');
    setappdata(handles.CreateKymograph, 'rectPos', rectPos);
    setappdata(handles.CreateKymograph, 'firstRect', thisT);
    setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
    setappdata(handles.CreateKymograph, 'includeROI', thisT:numT);
    setappdata(handles.CreateKymograph, 'firstAnchor', 1);
    guidata(hObject, handles);
end
setappdata(handles.CreateKymograph, 'drawRect', 0);




% --- Executes on button press in setAnchorButton.
function setAnchorButton_Callback(hObject, eventdata, handles)
% hObject    handle to setAnchorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.CreateKymograph, 'setAnchor', 1);
setappdata(handles.CreateKymograph, 'setAlignment', 0);



% --- Executes on button press in recordAnchorButton.
function recordAnchorButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordAnchorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

recordCentreMode(handles, 'CreateKymograph');
recordMode = getappdata(handles.CreateKymograph, 'recordMode');
figure(handles.CreateKymograph);
setappdata(handles.CreateKymograph, 'recordAnchor', 1);
setappdata(handles.CreateKymograph, 'recording', 1);
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
frameDelay = str2double(get(handles.delayText, 'String'));
thisZ = round(get(handles.zSlider, 'Value'));
set(handles.alertText, 'Visible', 'on');
set(handles.tSlider, 'Value', includeROI(1));
set(handles.tLabel, 'String', ['T = ' num2str(includeROI(1))]);
setappdata(handles.CreateKymograph, 'rotationView', 0);
setappdata(handles.CreateKymograph, 'setAnchor', 1);
getPlane(handles, thisZ-1, includeROI(1)-1)
refreshDisplay(handles)
setappdata(handles.CreateKymograph, 'stopRecording', 0);
rectPos = getappdata(handles.CreateKymograph, 'rectPos');
anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');

if strcmp(recordMode, 'clickMode')
    alertStr = [{'Click to move to'} {'next timepoint'} {'"Esc" to abort'}];
    set(handles.alertText, 'String', alertStr);
    set(handles.alertText, 'Enable', 'on');
else
    for i = 5:-1:0
        pause(1);
        alertStr = get(handles.alertText, 'String');
        alertStr{2}(end) = num2str(i);
        set(handles.alertText, 'String', alertStr);
    end
end
%Make sure the window is activated
%mouseClick;
for thisT = includeROI
    stopRecording = getappdata(handles.CreateKymograph, 'stopRecording');
    if stopRecording == 1
        set(handles.alertText, 'Visible', 'off');
        redrawAnchor(handles);
        setappdata(handles.CreateKymograph, 'trapPointer', 0);
        break;
    end
    getPlane(handles, thisZ-1, thisT-1)
    zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
    if zoomLevel > 1
        zoomImage(handles);
    end
    refreshDisplay(handles);
    if strcmp(recordMode, 'clickMode')
        uiwait;
    else
        pause(frameDelay);
    end
    set(handles.tSlider, 'Value', thisT);
    set(handles.tLabel, 'String', ['T = ' num2str(thisT)]);
    currentPoint = round(getappdata(handles.CreateKymograph, 'currentPoint'));
    offset = [currentPoint(1)-anchorPos{thisT}(1) currentPoint(3)-anchorPos{thisT}(2)];
    rectPos{thisT} = [rectPos{thisT}(1)+offset(1) rectPos{thisT}(2)+offset(2) rectPos{thisT}(3) rectPos{thisT}(4)];
    anchorPos{thisT} = [currentPoint(1), currentPoint(3)];
    
    if zoomLevel > 1
        zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
        rectPos{thisT}(1) = rectPos{thisT}(1) + zoomMinMax(1);
        rectPos{thisT}(2) = rectPos{thisT}(2) + zoomMinMax(2);
        anchorPos{thisT}(1) = anchorPos{thisT}(1) + zoomMinMax(1);
        anchorPos{thisT}(2) = anchorPos{thisT}(2) + zoomMinMax(2);
    end
    setappdata(handles.CreateKymograph, 'rectPos', rectPos);
    redrawRect(handles);
    setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
    drawnow;
end

refreshDisplay(handles);
alertStr = get(handles.alertText, 'String');
alertStr{2}(end) = num2str(5);
set(handles.alertText, 'String', alertStr);
set(handles.alertText, 'Visible', 'off');
setappdata(handles.CreateKymograph, 'recordAnchor', 0);
setappdata(handles.CreateKymograph, 'recording', 0);
setappdata(handles.CreateKymograph, 'setAnchor', 0);
    
    
    



function delayText_Callback(hObject, eventdata, handles)
% hObject    handle to delayText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delayText as text
%        str2double(get(hObject,'String')) returns contents of delayText as a double


% --- Executes during object creation, after setting all properties.
function delayText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delayText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function tSlider_Callback(hObject, eventdata, handles)
% hObject    handle to tSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

z = round(get(handles.zSlider, 'Value'));
t = round(get(hObject, 'Value'));
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
rotationView = getappdata(handles.CreateKymograph, 'rotationView');
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
set(handles.tLabel, 'String', ['T = ' num2str(t)]);
getPlane(handles, z-1, t-1);
if zoomLevel > 1
    zoomImage(handles);
end
if ismember(t, includeROI) && rotationView == 1 && ~isempty(alignPos{t})
    rotateImage(handles)
    displayImage = getappdata(handles.CreateKymograph, 'rotatedImage');
else
    displayImage = getappdata(handles.CreateKymograph, 'renderedImage');
end
axes(handles.imageAxes);
handles.imageHandle = imshow(displayImage);
set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
refreshDisplay(handles);
redrawRect(handles);
redrawAnchor(handles);
redrawAlign(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function tSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function startZText_Callback(hObject, eventdata, handles)
% hObject    handle to startZText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startZText as text
%        str2double(get(hObject,'String')) returns contents of startZText as a double

startZ = str2double(get(hObject, 'String'));
endZ = str2double(get(handles.stopZText, 'String'));
if isnan(startZ) || startZ < 1 || startZ > endZ
    set(hObject, 'String', '1');
end


% --- Executes during object creation, after setting all properties.
function startZText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startZText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopZText_Callback(hObject, eventdata, handles)
% hObject    handle to stopZText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopZText as text
%        str2double(get(hObject,'String')) returns contents of stopZText as a double

stopZ = str2double(get(hObject, 'String'));
startZ = str2double(get(handles.startZText, 'String'));
numZ = getappdata(handles.CreateKymograph, 'numZ');
if isnan(stopZ) || stopZ > numZ || stopZ < startZ
    set(hObject, 'String', numZ);
end



% --- Executes during object creation, after setting all properties.
function stopZText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopZText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function getPlane(handles, z, t)

pixelsId = getappdata(handles.CreateKymograph, 'pixelsId');
pixels = getappdata(handles.CreateKymograph, 'pixels');
numC = getappdata(handles.CreateKymograph, 'numC');
for thisC = 1:numC
    plane(:,:,thisC) = getPlaneFromPixelsId(pixelsId, z, thisC-1, t);
end
renderedImage = createRenderedImage(plane, pixels);
setappdata(handles.CreateKymograph, 'renderedImage', renderedImage);




function setTSlider(handles)

numT = getappdata(handles.CreateKymograph, 'numT');
sliderSmallStep = 1/numT;
set(handles.tSlider, 'Max', numT);
set(handles.tSlider, 'Min', 1);
set(handles.tSlider, 'Value', 1);
set(handles.tSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
set(handles.tLabel, 'String', 'T = 1');


function setZSlider(handles)

defaultZ = getappdata(handles.CreateKymograph, 'defaultZ')+1;
numZ = getappdata(handles.CreateKymograph, 'numZ');

if numZ > 1
    sliderSmallStep = 1/numZ;
    set(handles.zSlider, 'Max', numZ);
    set(handles.zSlider, 'Min', 1);
    set(handles.zSlider, 'Value', defaultZ);
    set(handles.zSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
    set(handles.zLabel, 'String', ['Z = ' num2str(defaultZ)]);
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
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
rotationView = getappdata(handles.CreateKymograph, 'rotationView');
set(handles.zLabel, 'String', ['Z = ' num2str(z)]);
axes(handles.imageAxes);
getPlane(handles, z-1, t-1);
zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
if zoomLevel > 1
    zoomImage(handles);
end
if ~isempty(alignPos{t}) && rotationView == 1
    rotateImage(handles)
end
%     displayImage = getappdata(handles.CreateKymograph, 'rotatedImage');
% else
%     displayImage = getappdata(handles.CreateKymograph, 'renderedImage');
% end
% axes(handles.imageAxes);
% handles.imageHandle = imshow(displayImage);
% set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
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

setAnchor = getappdata(handles.CreateKymograph, 'setAnchor');
anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
rectPos = getappdata(handles.CreateKymograph, 'rectPos');
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
hideAnchor = getappdata(handles.CreateKymograph, 'hideAnchor');
setAlignment = getappdata(handles.CreateKymograph, 'setAlignment');
zoomClick = getappdata(handles.CreateKymograph, 'zoomClick');
recordMode = getappdata(handles.CreateKymograph, 'recordMode');
recording = getappdata(handles.CreateKymograph, 'recording');
thisT = round(get(handles.tSlider, 'Value'));
numT = getappdata(handles.CreateKymograph, 'numT');
firstAnchor = getappdata(handles.CreateKymograph, 'firstAnchor');

if zoomClick == 1
    zoomImage(handles);
    setappdata(handles.CreateKymograph, 'zoomClick', 0);
    rotateImage(handles);
    refreshDisplay(handles);
    return;
end

zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
if zoomLevel > 1
    zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
    posModifierX = zoomMinMax(1);
    posModifierY = zoomMinMax(2);
else
    posModifierX = 0;
    posModifierY = 0;
end

if setAnchor == 1 && ismember(thisT, includeROI)
    currentPoint = round(get(handles.imageAxes, 'CurrentPoint'));
    if firstAnchor == 0
        redrawImage(handles);
    end
    if hideAnchor ~= 1
        anchor = impoint(gca,currentPoint(1)+posModifierX, currentPoint(3)+posModifierY);
        api = iptgetapi(anchor);
        %Stop the user manually moving the point beyond the image axes.
        fcn = makeConstrainToRectFcn('impoint', get(gca, 'XLim'), get(gca, 'YLim'));
        api.setPositionConstraintFcn(fcn);
        api.addNewPositionCallback(@(pos) anchorPositionUpdateFcn(pos, handles));
    end
    if firstAnchor == 1
        anchorPos{thisT} = [currentPoint(1)+posModifierX, currentPoint(3)+posModifierY];
        %anchorPos{thisT}
        setappdata(handles.CreateKymograph, 'firstAnchor', 0);
        for t = 1:numT
            anchorPos{t} = anchorPos{thisT};
        end
        set(handles.recordAnchorButton, 'Enable', 'on');
        set(handles.setAlignmentButton, 'Enable', 'on');
        set(handles.delayText, 'Enable', 'on');
        setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
    else
        offset = [currentPoint(1)-anchorPos{thisT}(1)+posModifierX currentPoint(3)-anchorPos{thisT}(2)+posModifierY];
        rectPos{thisT} = [rectPos{thisT}(1)+offset(1) rectPos{thisT}(2)+offset(2) rectPos{thisT}(3) rectPos{thisT}(4)];
        anchorPos{thisT} = [currentPoint(1)+posModifierX, currentPoint(3)+posModifierY];
        setappdata(handles.CreateKymograph, 'rectPos', rectPos);
        setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
        alignUpdateOnAnchorMove(offset, handles);
        refreshDisplay(handles);
    end
    
    if strcmp(recordMode, 'clickMode') && recording == 1
        uiresume
    end
    if recording == 0
        setappdata(handles.CreateKymograph, 'setAnchor', 0);
    end
end

if setAlignment == 1 && ismember(thisT, includeROI)
    firstAlign = getappdata(handles.CreateKymograph, 'firstAlign');
    currentPoint = round(get(handles.imageAxes, 'CurrentPoint'));
    if firstAlign == 1
        for t = 1:numT
            alignPos{t} = [currentPoint(1)+posModifierX, currentPoint(3)+posModifierY];
        end
        setappdata(handles.CreateKymograph, 'fristAlign', 0);
    else
        alignPos{thisT} = [currentPoint(1)+posModifierX, currentPoint(3)+posModifierY];
    end
    setappdata(handles.CreateKymograph, 'alignPos', alignPos);
    set(handles.recordAlignmentButton, 'Enable', 'on');
    rotateImage(handles);
    refreshDisplay(handles);
    if strcmp(recordMode, 'clickMode') && recording == 1
        uiresume
    end
    if recording == 0
        setappdata(handles.CreateKymograph, 'setAlignment', 0);
    end
end
%set(gcf,'Pointer','arrow');

    

function redrawRect(handles)

hideROI = getappdata(handles.CreateKymograph, 'hideROI');
if hideROI == 1
    return;
end

includeROI = getappdata(handles.CreateKymograph, 'includeROI');
thisT = round(get(handles.tSlider, 'Value'));
if ismember(thisT, includeROI)
    rectPos = getappdata(handles.CreateKymograph, 'rectPos');
    zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
    if zoomLevel > 1
        zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
        rectPos{thisT}(1) = rectPos{thisT}(1) - zoomMinMax(1);
        rectPos{thisT}(2) = rectPos{thisT}(2) - zoomMinMax(2);
    end
    rectangle('Position', rectPos{thisT}, 'edgecolor', 'white');
end

   


function redrawAnchor(handles)

thisT = round(get(handles.tSlider, 'Value'));
anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
rotationView = getappdata(handles.CreateKymograph, 'rotationView');
recording = getappdata(handles.CreateKymograph, 'recording');
if recording == 1
    return;
end
if ismember(thisT, includeROI) && ~isempty(anchorPos{thisT}) && rotationView == 0
    zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
    if zoomLevel > 1
        zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
        anchorPos{thisT}(1) = anchorPos{thisT}(1) - zoomMinMax(1);
        anchorPos{thisT}(2) = anchorPos{thisT}(2) - zoomMinMax(2);
    end
    anchor{thisT} = impoint(gca,anchorPos{thisT}(1), anchorPos{thisT}(2));
    api = iptgetapi(anchor{thisT});
    %Stop the user manually moving the point out of the axes.
    positionConstrainFcn = makeConstrainToRectFcn('impoint', get(gca, 'XLim'), get(gca, 'YLim'));
    api.addNewPositionCallback(@(pos) anchorPositionUpdateFcn(pos, handles));
    api.setPositionConstraintFcn(positionConstrainFcn);
end


function anchorPositionUpdateFcn(pos, handles)

pos = round(pos);
setappdata(handles.CreateKymograph, 'movingAnchor', 1);
anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
rectPos = getappdata(handles.CreateKymograph, 'rectPos');
thisT = round(get(handles.tSlider, 'Value'));
oldAnchorPos = anchorPos{thisT};
zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
if zoomLevel > 1
    zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
    pos(1) = pos(1) + zoomMinMax(1);
    pos(2) = pos(2) + zoomMinMax(2);
end
anchorPos{thisT}(1) = pos(1);
anchorPos{thisT}(2) = pos(2);
offset = [pos(1)-oldAnchorPos(1) pos(2)-oldAnchorPos(2)];
rectPos{thisT} = [rectPos{thisT}(1)+offset(1) rectPos{thisT}(2)+offset(2) rectPos{thisT}(3) rectPos{thisT}(4)];
alignUpdateOnAnchorMove(offset, handles);

setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
setappdata(handles.CreateKymograph, 'rectPos', rectPos);



function alignPositionUpdateFcn(pos, handles)

pos = round(pos);
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
thisT = round(get(handles.tSlider, 'Value'));
alignPos{thisT}(1) = pos(1);
alignPos{thisT}(2) = pos(2);
zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
if zoomLevel > 1
    zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
    alignPos{thisT}(1) = alignPos{thisT}(1) + zoomMinMax(1);
    alignPos{thisT}(2) = alignPos{thisT}(2) + zoomMinMax(2);
end

setappdata(handles.CreateKymograph, 'alignPos', alignPos);
setappdata(handles.CreateKymograph, 'movingAlign', 1);



function alignUpdateOnAnchorMove(offset, handles)

alignPos = getappdata(handles.CreateKymograph, 'alignPos');
imageSize = getappdata(handles.CreateKymograph, 'imageSize');
thisT = round(get(handles.tSlider, 'Value'));

if ~isempty(alignPos{thisT})
    alignPos{thisT} = [alignPos{thisT}(1)+offset(1) alignPos{thisT}(2)+offset(2)];
    xlim = get(gca, 'XLim');
    ylim = get(gca, 'XLim');
    if alignPos{thisT}(1) < 1
        alignPos{thisT}(1) = 1;
    elseif alignPos{thisT}(1) > imageSize(1)
        alignPos{thisT}(1) = imageSize(1);
    end
    if alignPos{thisT}(2) < 1
        alignPos{thisT}(2) = 1;
    elseif alignPos{thisT}(2) > imageSize(2)
        alignPos{thisT}(2) = imageSize(2);
    end
    setappdata(handles.CreateKymograph, 'alignPos', alignPos);
end


function redrawImage(handles)

includeROI = getappdata(handles.CreateKymograph, 'includeROI');
rotationView = getappdata(handles.CreateKymograph, 'rotationView');
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
thisT = round(get(handles.tSlider, 'Value'));
if ismember(thisT, includeROI) && rotationView == 1 && ~isempty(alignPos{thisT})
    displayImage = getappdata(handles.CreateKymograph, 'rotatedImage');
else
    if zoomLevel > 1
        displayImage = getappdata(handles.CreateKymograph, 'zoomImage');
    else
        displayImage = getappdata(handles.CreateKymograph, 'renderedImage');
    end
end
handles.imageHandle = imshow(displayImage);
set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
setappdata(handles.CreateKymograph, 'thisImageHandle', handles.imageHandle);



function windowButtonMotion(hObject, eventdata, handles)

currentPoint = get(handles.imageAxes, 'CurrentPoint');
setAnchor = getappdata(handles.CreateKymograph, 'setAnchor');
setAlignment = getappdata(handles.CreateKymograph, 'setAlignment');
recordAnchor = getappdata(handles.CreateKymograph, 'recordAnchor');
recordAlignment = getappdata(handles.CreateKymograph, 'recordAlignment');
drawRect = getappdata(handles.CreateKymograph, 'drawRect');
setappdata(handles.CreateKymograph, 'currentPoint', currentPoint);
axesPosition = get(handles.imageAxes, 'Position');
sizeXY = getappdata(handles.CreateKymograph, 'sizeXY');
xMod = axesPosition(3)/sizeXY(1);
yMod = axesPosition(4)/sizeXY(2);
if currentPoint(1) > 0 && currentPoint(1) <= (axesPosition(3) / xMod) && currentPoint(3) > 0 && currentPoint(3) <= (axesPosition(4) / yMod)
    overAxes = 1;
else
    overAxes = 0;
end
if  overAxes == 1 && getappdata(handles.CreateKymograph, 'zoomClick') == 1
    squarePointer = getappdata(handles.CreateKymograph, 'squarePointer');
    set(gcf,'Pointer','custom','PointerShapeCData',squarePointer,'PointerShapeHotSpot',[9 9])
elseif overAxes == 1 && (setAnchor == 1 || setAlignment == 1 || recordAnchor == 1 || recordAlignment == 1 || drawRect == 1)
    set(gcf, 'Pointer', 'crosshair');
else
    set(gcf, 'Pointer', 'arrow');
end




function startTText_Callback(hObject, eventdata, handles)
% hObject    handle to startTText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startTText as text
%        str2double(get(hObject,'String')) returns contents of startTText as a double

includeROI = getappdata(handles.CreateKymograph, 'includeROI');
startT = str2double(get(hObject, 'String'));
endT = str2double(get(handles.endTText, 'String'));
if isnan(startT) || startT < 1 || startT >= endT
    startT = 1;
    set(hObject, 'String', '1');
end
endT = max(includeROI);
setappdata(handles.CreateKymograph, 'includeROI', startT:endT);
refreshDisplay(handles);



% --- Executes during object creation, after setting all properties.
function startTText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startTText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endTText_Callback(hObject, eventdata, handles)
% hObject    handle to endTText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endTText as text
%        str2double(get(hObject,'String')) returns contents of endTText as a double

includeROI = getappdata(handles.CreateKymograph, 'includeROI');
numT = getappdata(handles.CreateKymograph, 'numT');
startT = min(includeROI);
endT = str2double(get(hObject, 'String'));
if isnan(endT) || endT > numT || endT <= startT
    endT = numT;
    set(hObject, 'String', num2str(endT));
end
setappdata(handles.CreateKymograph, 'includeROI', startT:endT);
refreshDisplay(handles);


% --- Executes during object creation, after setting all properties.
function endTText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endTText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if getappdata(handles.CreateKymograph, 'playing') == 1
    return;
end
numT = getappdata(handles.CreateKymograph, 'numT');
firstT = round(get(handles.tSlider, 'Value'));
frameDelay = str2double(get(handles.delayText, 'String'));
%alignPos = getappdata(handles.CreateKymograph, 'alignPos');
rotationView = getappdata(handles.CreateKymograph, 'rotationView');
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
if frameDelay < 0.01
    frameDelay = 0.01;
end
setappdata(handles.CreateKymograph, 'interruptPlay', 0);
for thisT = firstT:numT
    interruptPlay = getappdata(handles.CreateKymograph, 'interruptPlay');
    if interruptPlay == 1
        break;
    end
    setappdata(handles.CreateKymograph, 'playing', 1);
    set(handles.tSlider, 'Value', thisT);
    set(handles.tLabel, 'String', ['T = ' num2str(thisT)]);
    thisZ = round(get(handles.zSlider, 'Value'));
    getPlane(handles, thisZ-1, thisT-1)
    zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
    if zoomLevel > 1
        zoomImage(handles);
    end
    if ismember(thisT, includeROI) && rotationView == 1
        rotateImage(handles);
    end
    refreshDisplay(handles);
%     redrawImage(handles);
%     redrawRect(handles);
%     redrawAnchor(handles);
%     redrawAlign(handles);
    %drawnow expose;
    pause(frameDelay);
end
setappdata(handles.CreateKymograph, 'playing', 0);
setappdata(handles.CreateKymograph, 'interruptPlay', 0);



% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.CreateKymograph, 'interruptPlay', 1);


% --- Executes on button press in createChymographButton.
function createChymographButton_Callback(hObject, eventdata, handles)
% hObject    handle to createChymographButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

includeROI = getappdata(handles.CreateKymograph, 'includeROI');
zRange(1) = str2double(get(handles.startZText, 'String'));
zRange(2) = str2double(get(handles.stopZText, 'String'));
topDown = get(handles.topDownRadio, 'Value');
if topDown == 1
    orientation = 'top-down';
else
    orientation = 'left-right';
end
dlgString{1} = 'Use these settings to create the chymograph:';
dlgString{2} = ['     Frames ', num2str(includeROI(1)), ' to ', num2str(includeROI(end))];
dlgString{3} = ['     Project z-sections ', num2str(zRange(1)), ' to ', num2str(zRange(2))];
dlgString{4} = ['     Orientate figure ', orientation];
dlgString{5} = [];
dlgString{6} = 'Is this correct?';
answer = questdlg(dlgString, 'Create Chymograph', 'Yes', 'No', 'Yes');

switch answer
    case 'Yes'
        processChymograph(handles)
    case 'No';
        return;
end



function currentWindowKeypress(hObject, eventdata, handles)

currentKey = eventdata.Key;
if strcmp(currentKey, 'escape')
    setappdata(handles.CreateKymograph, 'stopRecording', 1);
elseif strcmp(currentKey, 'f5')
    refreshDisplay(handles);
elseif strcmp(currentKey, 'add')
    zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
    playing = getappdata(handles.CreateKymograph, 'playing');
    stopRecording = getappdata(handles.CreateKymograph, 'stopRecording');
    zoomLevel = zoomLevel + 1;
    if zoomLevel > 3 || playing == 1 || stopRecording == 0
        return;
    else
        setappdata(handles.CreateKymograph, 'zoomClick', 1)
        setappdata(handles.CreateKymograph, 'zoomLevel', zoomLevel);
    end
end



function mouseClick

robot = java.awt.Robot;
robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);



function imageAnchor_ButtonUpFcn(hObject, eventdata, handles)

movingAnchor = getappdata(handles.CreateKymograph, 'movingAnchor');
movingAlign = getappdata(handles.CreateKymograph, 'movingAlign');
if movingAnchor == 1 || movingAlign == 1
rotateImage(handles);
redrawRect(handles);
redrawAlign(handles);
setappdata(handles.CreateKymograph, 'movingAnchor', 0);
setappdata(handles.CreateKymograph, 'movingAlign', 0);
end


function rotateImage(handles)

zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
if zoomLevel > 1
    zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
    zoomModifierX = zoomMinMax(1);
    zoomModifierY = zoomMinMax(2);
    renderedImage = getappdata(handles.CreateKymograph, 'zoomImage');
    imageSize = size(renderedImage(:,:,1));
    anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
    alignPos = getappdata(handles.CreateKymograph, 'alignPos');
else
    zoomModifierX = 0;
    zoomModifierY = 0;
    renderedImage = getappdata(handles.CreateKymograph, 'renderedImage');
    imageSize = size(renderedImage(:,:,1));
    anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
    alignPos = getappdata(handles.CreateKymograph, 'alignPos');
end

thisT = round(get(handles.tSlider, 'Value'));

if ~isempty(alignPos{thisT})
    anchorPos{thisT}(1) = anchorPos{thisT}(1) - zoomModifierX;
    anchorPos{thisT}(2) = anchorPos{thisT}(2) - zoomModifierY;
    alignPos{thisT}(1) = alignPos{thisT}(1) - zoomModifierX;
    alignPos{thisT}(2) = alignPos{thisT}(2) - zoomModifierY;
    horiz = get(handles.horizontalRadio, 'Value');
    point = anchorPos{thisT};
    anglePoint = alignPos{thisT};
    grad = (point(1)-anglePoint(1))/(point(2)-anglePoint(2));
    pointFromCentre = [((imageSize(2)/2)-point(2)) ((imageSize(1)/2)-point(1))];
    offsetSign = sign(pointFromCentre);
    if offsetSign(1) == 1 && offsetSign(2)== 1
        pointToEdge = imageSize - point;
        pad = pointToEdge - point;
        paddedImage = padarray(renderedImage, [pad(2) pad(1)], 'pre');
    elseif offsetSign(1) == 1 && offsetSign(2)== -1
        pointToEdge = imageSize - point;
        padY = pointToEdge(2) - point(2);
        padX = point(1) - pointToEdge(1);
        paddedImage = padarray(renderedImage, [padY 0], 'pre');
        paddedImage = padarray(paddedImage, [0, padX], 'post');
    elseif offsetSign(1) == -1 && offsetSign(2)== 1
        pointToEdge = imageSize - point;
        padY = point(2) - pointToEdge(2);
        padX = pointToEdge(1) - point(1);
        paddedImage = padarray(renderedImage, [padY 0], 'post');
        paddedImage = padarray(paddedImage, [0, padX], 'pre');
    elseif offsetSign(1) == -1 && offsetSign(2)== -1
        pointToEdge = imageSize - point;
        pad = abs(pointToEdge - point);
        paddedImage = padarray(renderedImage, [pad(2) pad(1)], 'post');
    elseif offsetSign(1) == 1 && offsetSign(2)== 0
        pointToEdge = imageSize - point;
        pad = pointToEdge - point;
        paddedImage = padarray(renderedImage, [pad(2) 0], 'pre');
    elseif offsetSign(1) == 0 && offsetSign(2)== 1
        pointToEdge = imageSize - point;
        pad = pointToEdge - point;
        paddedImage = padarray(renderedImage, [0 pad(1)], 'pre');
    elseif offsetSign(1) == -1 && offsetSign(2)== 0
        pointToEdge = imageSize - point;
        padY = point(2) - pointToEdge(2);
        paddedImage = padarray(renderedImage, [padY 0], 'post');
    elseif offsetSign(1) == 0 && offsetSign(2)== -1
        pointToEdge = imageSize - point;
        padX = point(1) - pointToEdge(1);
        paddedImage = padarray(renderedImage, [0 padX], 'post');
    elseif offsetSign(1) == 0 && offsetSign(2) == 0
        paddedImage = renderedImage;
    end
    
    rotateOffsetSign = sign(point-anglePoint);
    if horiz == 1
        if rotateOffsetSign(1) == 1 && rotateOffsetSign(2)== 1
            rotAngle = 90-sqrt(atand(grad)^2);
        elseif rotateOffsetSign(1) == 1 && rotateOffsetSign(2)== -1
            rotAngle = -90+sqrt(atand(grad)^2);
        elseif rotateOffsetSign(1) == -1 && rotateOffsetSign(2)== 1
            rotAngle = -90+sqrt(atand(grad)^2);
        elseif rotateOffsetSign(1) == -1 && rotateOffsetSign(2)== -1
            rotAngle = 90-sqrt(atand(grad)^2);
        elseif grad == -Inf
            rotAngle = 0;
        end
    else
        if rotateOffsetSign(1) == 1 && rotateOffsetSign(2)== 1
            rotAngle = -sqrt(atand(grad)^2);
        elseif rotateOffsetSign(1) == 1 && rotateOffsetSign(2)== -1
            rotAngle = sqrt(atand(grad)^2);
        elseif rotateOffsetSign(1) == -1 && rotateOffsetSign(2)== 1
            rotAngle = sqrt(atand(grad)^2);
        elseif rotateOffsetSign(1) == -1 && rotateOffsetSign(2)== -1
            rotAngle = -sqrt(atand(grad)^2);
        elseif grad == -Inf
            rotAngle = 0;
        end
    end

    rotatedPaddedImage = imrotate(paddedImage, rotAngle, 'crop');
    paddedSize = size(rotatedPaddedImage(:,:,1));

    if offsetSign(1) == 1 && offsetSign(2)== 1
        rotatedImage = rotatedPaddedImage(paddedSize(1)-imageSize(1):end, paddedSize(2)-imageSize(2):end, :);
    elseif offsetSign(1) == 1 && offsetSign(2)== -1
        rotatedImage = rotatedPaddedImage(paddedSize(1)-imageSize(1):end, 1:imageSize(2), :);
    elseif offsetSign(1) == -1 && offsetSign(2)== 1
        rotatedImage = rotatedPaddedImage(1:imageSize(1), paddedSize(2)-imageSize(2):end,  :);
    elseif offsetSign(1) == -1 && offsetSign(2)== -1
        rotatedImage = rotatedPaddedImage(1:imageSize(1), 1:imageSize(2), :);
    elseif offsetSign(1) == 1 && offsetSign(2)== 0
        rotatedImage = rotatedPaddedImage(paddedSize(1)-imageSize(1):end, :, :);
    elseif offsetSign(1) == 0 && offsetSign(2)== 1
        rotatedImage = rotatedPaddedImage(:,paddedSize(2)-imageSize(2):end, :);
    elseif offsetSign(1) == -1 && offsetSign(2)== 0
        rotatedImage = rotatedPaddedImage(1:imageSize(1), :, :);
    elseif offsetSign(1) == 0 && offsetSign(2)== -1
        rotatedImage = rotatedPaddedImage(:,1:imageSize(2), :);
    elseif offsetSign(1) == 0 && offsetSign(2) == 0
        rotatedImage = rotatedPaddedImage;
    end
    setappdata(handles.CreateKymograph, 'rotatedImage', rotatedImage);
end



% --- Executes on button press in setAlignmentButton.
function setAlignmentButton_Callback(hObject, eventdata, handles)
% hObject    handle to setAlignmentButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.CreateKymograph, 'setAlignment', 1);
setappdata(handles.CreateKymograph, 'setAnchor', 0);



% --- Executes on button press in recordAlignmentButton.
function recordAlignmentButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordAlignmentButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

recordCentreMode(handles, 'CreateKymograph');
recordMode = getappdata(handles.CreateKymograph, 'recordMode');
figure(handles.CreateKymograph);
setappdata(handles.CreateKymograph, 'setAlignment', 1);
setappdata(handles.CreateKymograph, 'recordAlignment', 1);
setappdata(handles.CreateKymograph, 'recording', 1);
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
frameDelay = str2double(get(handles.delayText, 'String'));
thisZ = round(get(handles.zSlider, 'Value'));
set(handles.alertText, 'Visible', 'on');
set(handles.tSlider, 'Value', includeROI(1));
set(handles.tLabel, 'String', ['T = ' num2str(includeROI(1))]);
setappdata(handles.CreateKymograph, 'rotationView', 0);
getPlane(handles, thisZ-1, includeROI(1)-1)
refreshDisplay(handles);
setappdata(handles.CreateKymograph, 'stopRecording', 0);
alignPos = getappdata(handles.CreateKymograph, 'alignPos');

if strcmp(recordMode, 'clickMode')
    alertStr = [{'Click to move to'} {'next timepoint'} {'"Esc" to abort'}];
    set(handles.alertText, 'String', alertStr);
    set(handles.alertText, 'Enable', 'on');
else
    for i = 5:-1:0
        pause(1);
        alertStr = get(handles.alertText, 'String');
        alertStr{2}(end) = num2str(i);
        set(handles.alertText, 'String', alertStr);
    end
end
%Make sure the window is activated
mouseClick;
for thisT = includeROI
    stopRecording = getappdata(handles.CreateKymograph, 'stopRecording');
    if stopRecording == 1
        set(handles.alertText, 'Visible', 'off');
        redrawAlign(handles);
        setappdata(handles.CreateKymograph, 'trapPointer', 0);
        break;
    end
    getPlane(handles, thisZ-1, thisT-1)
    zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
    if zoomLevel > 1
        zoomImage(handles);
    end
    refreshDisplay(handles);
    if strcmp(recordMode, 'clickMode')
        uiwait;
    else
        pause(frameDelay);
    end
    set(handles.tSlider, 'Value', thisT);
    set(handles.tLabel, 'String', ['T = ' num2str(thisT)]);
    currentPoint = round(getappdata(handles.CreateKymograph, 'currentPoint'));
    alignPos{thisT} = [currentPoint(1), currentPoint(3)];
    zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
    if zoomLevel > 1
        zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
        alignPos{thisT}(1) = alignPos{thisT}(1) + zoomMinMax(1);
        alignPos{thisT}(2) = alignPos{thisT}(2) + zoomMinMax(2);
    end
    setappdata(handles.CreateKymograph, 'alignPos', alignPos);
    drawnow;
end
refreshDisplay(handles);
alertStr = get(handles.alertText, 'String');
alertStr{2}(end) = num2str(5);
set(handles.alertText, 'String', alertStr);
set(handles.alertText, 'Visible', 'off');
setappdata(handles.CreateKymograph, 'setAlignment', 0);
setappdata(handles.CreateKymograph, 'recordAlignment', 0);
setappdata(handles.CreateKymograph, 'recording', 0);



% --------------------------------------------------------------------
function viewMenu_Callback(hObject, eventdata, handles)
% hObject    handle to viewMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function rotationViewItem_Callback(hObject, eventdata, handles)
% hObject    handle to rotationViewItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotationView = getappdata(handles.CreateKymograph, 'rotationView');
if rotationView == 0
    setappdata(handles.CreateKymograph, 'rotationView', 1);
    set(hObject,'Checked','on');
else
    setappdata(handles.CreateKymograph, 'rotationView', 0);
    set(hObject,'Checked','off');
end

refreshDisplay(handles);


function redrawAlign(handles)

includeROI = getappdata(handles.CreateKymograph, 'includeROI');
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
rotationView = getappdata(handles.CreateKymograph, 'rotationView');
recording = getappdata(handles.CreateKymograph, 'recording');
thisT = round(get(handles.tSlider, 'Value'));

if recording == 1
    return;
end
if ismember(thisT, includeROI) && rotationView == 0 && ~isempty(alignPos{thisT})
    zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
    if zoomLevel > 1
        zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
        alignPos{thisT}(1) = alignPos{thisT}(1) - zoomMinMax(1);
        alignPos{thisT}(2) = alignPos{thisT}(2) - zoomMinMax(2);
    end
    alignMark = impoint(gca,alignPos{thisT}(1), alignPos{thisT}(2));
    api = iptgetapi(alignMark);
    api.setColor('g');
    fcn = makeConstrainToRectFcn('impoint', get(gca, 'XLim'), get(gca, 'YLim'));
    api.setPositionConstraintFcn(fcn);
    api.addNewPositionCallback(@(pos) alignPositionUpdateFcn(pos, handles));
end


function horizontalRadio_Callback(hObject, eventdata, handles)

rotateImage(handles);
refreshDisplay(handles);


function verticalRadio_Callback(hObject, eventdata, handles)

rotateImage(handles);
refreshDisplay(handles);


% --------------------------------------------------------------------
function fileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function clearMenu_Callback(hObject, eventdata, handles)
% hObject    handle to clearMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function clearAllItem_Callback(hObject, eventdata, handles)
% hObject    handle to clearAllItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = getappdata(handles.CreateKymograph, 'clearAnswer');

if ~strcmpi(answer, 'Yes')
    answer = questdlg('Clear the ROI and all the anchor and alignment points?', 'Clear All?','Yes','No','No');
end

switch answer
    case 'Yes'
        numT = getappdata(handles.CreateKymograph, 'numT');
        numZ = getappdata(handles.CreateKymograph, 'numZ');
        for t = 1:numT;
            rectPos{t} = [];
            anchorPos{t} = [];
            alignPos{t} = [];
        end
        setappdata(handles.CreateKymograph, 'setAnchor', 0);
        setappdata(handles.CreateKymograph, 'setAlignment', 0);
        setappdata(handles.CreateKymograph, 'firstAnchor', 1);
        setappdata(handles.CreateKymograph, 'firstAlign', 1);
        setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
        setappdata(handles.CreateKymograph, 'rectPos', rectPos);
        setappdata(handles.CreateKymograph, 'alignPos', alignPos);
        setappdata(handles.CreateKymograph, 'includeROI', []);
        setappdata(handles.CreateKymograph, 'movingAnchor', 0);
        setappdata(handles.CreateKymograph, 'movingAlign', 0);
        setappdata(handles.CreateKymograph, 'clearAnswer', []);
        set(handles.setAnchorButton, 'Enable', 'off');
        set(handles.recordAnchorButton, 'Enable', 'off');
        set(handles.setAlignmentButton, 'Enable', 'off');
        set(handles.recordAlignmentButton, 'Enable', 'off');
        set(handles.startTText, 'String', []);
        set(handles.startTText, 'Enable', 'off');
        set(handles.endTText, 'String', []);
        set(handles.endTText, 'Enable', 'off');
        set(handles.startZText, 'String', '1');
        set(handles.stopZText, 'String', numZ);
        refreshDisplay(handles);
    case 'No'
        return;
end

% --------------------------------------------------------------------
function clearAnchorsItem_Callback(hObject, eventdata, handles)
% hObject    handle to clearAnchorsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = questdlg('Clear all the anchor and alignment points?', 'Clear Points?','Yes','No','No');

switch answer
    case 'Yes'
        numT = getappdata(handles.CreateKymograph, 'numT');
        for t = 1:numT;
            anchorPos{t} = [];
            alignPos{t} = [];
        end
        setappdata(handles.CreateKymograph, 'setAnchor', 0);
        setappdata(handles.CreateKymograph, 'setAlignment', 0);
        setappdata(handles.CreateKymograph, 'firstAnchor', 1);
        setappdata(handles.CreateKymograph, 'firstAlign', 1);
        setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
        setappdata(handles.CreateKymograph, 'alignPos', alignPos);
        setappdata(handles.CreateKymograph, 'movingAnchor', 0);
        setappdata(handles.CreateKymograph, 'movingAlign', 0);
        set(handles.recordAnchorButton, 'Enable', 'off');
        set(handles.setAlignmentButton, 'Enable', 'off');
        set(handles.recordAlignmentButton, 'Enable', 'off');
        refreshDisplay(handles);
    case 'No'
        return;
end




% --------------------------------------------------------------------
function clearRotationPointsItem_Callback(hObject, eventdata, handles)
% hObject    handle to clearRotationPointsItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = questdlg('Clear all the alignment points?', 'Clear Points?','Yes','No','No');

switch answer
    case 'Yes'
        numT = getappdata(handles.CreateKymograph, 'numT');
        for t = 1:numT;
            alignPos{t} = [];
        end
        setappdata(handles.CreateKymograph, 'setAnchor', 0);
        setappdata(handles.CreateKymograph, 'setAlignment', 0);
        setappdata(handles.CreateKymograph, 'firstAlign', 1);
        setappdata(handles.CreateKymograph, 'alignPos', alignPos);
        setappdata(handles.CreateKymograph, 'movingAnchor', 0);
        setappdata(handles.CreateKymograph, 'movingAlign', 0);
        set(handles.recordAlignmentButton, 'Enable', 'off');
        refreshDisplay(handles);
    case 'No'
        return;
end



% --------------------------------------------------------------------
function openImageItem_Callback(hObject, eventdata, handles)
% hObject    handle to openImageItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datasetId = getappdata(handles.CreateKymograph, 'datasetId');
if ~isempty(datasetId)
    answer = questdlg([{'Close this image to open another?'},{'All data will be lost!'}], 'Quit?','Yes','No','Yes');
else
    answer = 'Yes';
end

switch answer,
    case 'Yes',
%         loginImageSelector;
        ImageSelector(handles, 'CreateKymograph');
        getImageParameters(handles);
        enableDisableControls(handles, 'on');
        setTSlider(handles);
        setZSlider(handles);
        set(handles.stopZText, 'String', num2str(getappdata(handles.CreateKymograph, 'numZ')));
        defaultZ = getappdata(handles.CreateKymograph, 'defaultZ');
        getPlane(handles, defaultZ, 0)
        setappdata(handles.CreateKymograph, 'clearAnswer', 'Yes');
        clearAllItem_Callback([], eventdata, handles);    
        refreshDisplay(handles);
        
        %close(handles.CreateKymograph);
    case 'No'
        return
end



% --------------------------------------------------------------------
function refreshItem_Callback(hObject, eventdata, handles)
% hObject    handle to refreshItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

refreshDisplay(handles);


function refreshDisplay(handles)

redrawImage(handles);
redrawRect(handles);
redrawAnchor(handles);
redrawAlign(handles);



function processChymograph(handles)

set(handles.CreateKymograph, 'Visible', 'off');
scrsz = get(0,'ScreenSize');
statusBox = figure('Name','Processing...','NumberTitle','off','MenuBar','none','Position',[(scrsz(3)/2)-150 (scrsz(4)/2)-80 300 80]);
creatingText = uicontrol(statusBox, 'Style', 'text', 'String', 'Creating kymograph', 'Position', [25 60 250 15]);
planeText = uicontrol(statusBox, 'Style', 'text', 'String', 'Plane...', 'Position', [25 35 250 15]);

setappdata(handles.CreateKymograph, 'zoomLevel', 1);

drawnow;


numC = getappdata(handles.CreateKymograph, 'numC');
pixelsId = getappdata(handles.CreateKymograph, 'pixelsId');
pixels = getappdata(handles.CreateKymograph, 'pixels');
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
numIncluded = length(includeROI);
zSections = str2double(get(handles.startZText, 'String')) : str2double(get(handles.stopZText, 'String'));
rectPos = getappdata(handles.CreateKymograph, 'rectPos');
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
projectionType = getappdata(handles.CreateKymograph, 'projectionType');
topDown = get(handles.topDownRadio, 'Value');
width = uint32(rectPos{1}(3));
height = uint32(rectPos{1}(4));

for t = 1:length(includeROI)
    patch{t} = zeros([int32(rectPos{1}(4)) int32(rectPos{1}(3)) int32(3)]);
end

counter = 1;
for thisT = includeROI
    for thisC = 1:numC
        for thisZ = zSections
            planesThisC(:,:,thisZ) = getPlaneFromPixelsId(pixelsId, thisZ-1, thisC-1, thisT-1);
        end
        if strcmp(projectionType, 'max')
            projectionThisC(:,:,thisC) = max(planesThisC, [], 3);
        else
            projectionThisC(:,:,thisC) = mean(planesThisC, 3);
        end
    end
    %projection(:,:,thisT) = max(planesThisC, [], 3);
    renderedProjection = createRenderedImage(projectionThisC, pixels);
    set(handles.tSlider, 'Value', thisT);
    setappdata(handles.CreateKymograph, 'renderedImage', renderedProjection);
    if ~isempty(alignPos{thisT})
       rotateImage(handles);
       baseImage = getappdata(handles.CreateKymograph, 'rotatedImage');
    else
        baseImage = getappdata(handles.CreateKymograph, 'renderedImage');
    end
    X = uint32(rectPos{thisT}(1));
    Y = uint32(rectPos{thisT}(2));
    patch{counter} = baseImage(Y:Y+height,X:X+width,:);
    if numIncluded < 300
        set(planeText, 'String', ['Plane ', num2str(counter), ' of ', num2str(numIncluded)]);
    else
        if mod(counter, 10) == 0
            set(planeText, 'String', ['Plane ', num2str(counter), ' of ', num2str(numIncluded)]);
        end
    end
    drawnow;
    counter = counter + 1;
end

kymograph = [];
for thisT = 1:counter-1;
    if topDown == 1
        kymograph = [kymograph; patch{thisT}];
    else
        kymograph = [kymograph patch{thisT}];
    end
end
close(statusBox);
set(handles.CreateKymograph, 'Visible', 'on');
figure; imshow(kymograph);

% 
% % --------------------------------------------------------------------
% function saveSettingsItem_Callback(hObject, eventdata, handles)
% % hObject    handle to saveSettingsItem (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% settings.theImage = handles.imageObj;
% settings.rectPos = getappdata(handles.CreateKymograph, 'rectPos');
% settings.anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
% settings.alignPos = getappdata(handles.CreateKymograph, 'alignPos');
% settings.includeROI = getappdata(handles.CreateKymograph, 'includeROI');
% settings.zSections = str2double(get(handles.startZText, 'String')) : str2double(get(handles.stopZText, 'String'));
% settings.horizontal = get(handles.horizontalRadio, 'Value');
% settings.topDown = get(handles.topDownRadio, 'Value');
% [fileName filePath] = uiputfile('*.kym', 'Save Kymograph Settings', [handles.imageName '.kym']);
% save([filePath fileName], 'settings');
% 
% 
% % --------------------------------------------------------------------
% function loadSettingsItem_Callback(hObject, eventdata, handles)
% % hObject    handle to loadSettingsItem (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% [fileName filePath] = uigetfile('*.kym', 'Save Kymograph Settings', [imageName '.kym']);
% settings = load([filePath fileName]);
% handles.imageObj = settings.theImage;
% 


% --------------------------------------------------------------------
function projectionMenu_Callback(hObject, eventdata, handles)
% hObject    handle to projectionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function maxIntensityItem_Callback(hObject, eventdata, handles)
% hObject    handle to maxIntensityItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

projectionType = getappdata(handles.CreateKymograph, 'projectionType');
if strcmp(projectionType, 'mean')
    setappdata(handles.CreateKymograph, 'projectionType', 'max');
    set(handles.meanIntensityItem,'Checked','off');
    set(hObject,'Checked','on');
end


% --------------------------------------------------------------------
function meanIntensityItem_Callback(hObject, eventdata, handles)
% hObject    handle to meanIntensityItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

projectionType = getappdata(handles.CreateKymograph, 'projectionType');
if strcmp(projectionType, 'max')
    setappdata(handles.CreateKymograph, 'projectionType', 'mean');
    set(handles.maxIntensityItem,'Checked','off');
    set(hObject,'Checked','on');
end


% --------------------------------------------------------------------
function hideROIItem_Callback(hObject, eventdata, handles)
% hObject    handle to hideROIItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hideROI = getappdata(handles.CreateKymograph, 'hideROI');
if hideROI == 0
    setappdata(handles.CreateKymograph, 'hideROI', 1);
    set(hObject, 'Checked', 'on');
else
    setappdata(handles.CreateKymograph, 'hideROI', 0);
    set(hObject, 'Checked', 'off');
end

redrawImage(handles)
redrawRect(handles)
redrawAnchor(handles)
redrawAlign(handles)


% --------------------------------------------------------------------
function zoomInItem_Callback(hObject, eventdata, handles)
% hObject    handle to zoomInItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
zoomLevel = zoomLevel + 1;
playing = getappdata(handles.CreateKymograph, 'playing');
recording = getappdata(handles.CreateKymograph, 'recording');
if zoomLevel > 3 || playing == 1 || recording == 1
    return;
else
    setappdata(handles.CreateKymograph, 'zoomClick', 1);
    setappdata(handles.CreateKymograph, 'zoomLevel', zoomLevel);
end


% --------------------------------------------------------------------
function zoomOutItem_Callback(hObject, eventdata, handles)
% hObject    handle to zoomOutItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

playing = getappdata(handles.CreateKymograph, 'playing');
recording = getappdata(handles.CreateKymograph, 'recording');
if playing == 1 || recording == 1
    return;
end
setappdata(handles.CreateKymograph, 'zoomLevel', 1);
setappdata(handles.CreateKymograph, 'zoomMinMax', []);
rotateImage(handles);
refreshDisplay(handles);


function zoomImage(handles)

zoomLevel = getappdata(handles.CreateKymograph, 'zoomLevel');
zoomMinMax = getappdata(handles.CreateKymograph, 'zoomMinMax');
playing = getappdata(handles.CreateKymograph, 'playing');
stopRecording = getappdata(handles.CreateKymograph, 'stopRecording');
renderedImage = getappdata(handles.CreateKymograph, 'renderedImage');
zoomClick = getappdata(handles.CreateKymograph, 'zoomClick');

if zoomClick == 1
    % if playing == 1
    %     currentPoint = getappdata(handles.CreateKymograph, 'zoomCentre');
    % else
    currentPoint = get(gca, 'CurrentPoint');
    %end
    if ~isempty(zoomMinMax) && (stopRecording == 0 || playing == 0)
        minZoomX = zoomMinMax(1);
        minZoomY = zoomMinMax(2);
    else
        minZoomX = 0;
        minZoomY = 0;
    end
    ROIx = currentPoint(1) + minZoomX;
    ROIy = currentPoint(3) + minZoomY;
    [imageHeight imageWidth imageRGB] = size(renderedImage);
    maxZoomX = round(ROIx + (imageWidth/(2*zoomLevel)));
    maxZoomY = round(ROIy + (imageHeight/(2*zoomLevel)));
    minZoomX = round(ROIx - (imageWidth/(2*zoomLevel)));
    minZoomY = round(ROIy - (imageHeight/(2*zoomLevel)));
    cx = currentPoint(1);
    cy = currentPoint(3);



    if maxZoomX > imageWidth
        xDiff = maxZoomX - imageWidth;
        cx = cx + xDiff;
        maxZoomX = imageWidth;
        minZoomX = round(maxZoomX-(imageWidth/(zoomLevel)));
    end
    if maxZoomY > imageHeight
        yDiff = maxZoomY - imageHeight;
        cy = cy + yDiff;
        maxZoomY = imageHeight;
        minZoomY = round(maxZoomY-(imageHeight/(zoomLevel)));
    end
    if minZoomX <= 0
        cx = cx + minZoomX;
        minZoomX = 1;
        maxZoomX = round(minZoomX+(imageWidth/(zoomLevel)));
    end
    if minZoomY <= 0
        cy = cy + minZoomY;
        minZoomY = 1;
        maxZoomY = round(minZoomY+(imageHeight/(zoomLevel)));
    end
else
    minZoomX = zoomMinMax(1);
    minZoomY = zoomMinMax(2);
    maxZoomX = zoomMinMax(3);
    maxZoomY = zoomMinMax(4);
end
    

zoomImage = renderedImage(minZoomY:maxZoomY, minZoomX:maxZoomX,:);
handles.imageHandle = imshow(zoomImage);
set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
setappdata(handles.CreateKymograph, 'zoomImage', zoomImage);
setappdata(handles.CreateKymograph, 'thisImageHandle', handles.imageHandle);
if zoomClick == 1
    setappdata(handles.CreateKymograph, 'zoomROICentre', [cx cy]);
    setappdata(handles.CreateKymograph, 'zoomCentre', currentPoint);
    setappdata(handles.CreateKymograph, 'zoomMinMax', [minZoomX minZoomY maxZoomX maxZoomY]);
end

function getImageParameters(handles)

global gateway;
global session;
renderSettingsService = session.getRenderingSettingsService;

imageId = getappdata(handles.CreateKymograph, 'imageId');
imageObj = getappdata(handles.CreateKymograph, 'newImageObj');
pixels = gateway.getPixelsFromImage(imageId);
if strcmp(class(pixels), 'java.util.ArrayList');
    pixels = pixels.get(0);
end
pixelsId = pixels.getId.getValue;
%handles.fullImage = varargin{2};
imageName = native2unicode(imageObj.getName.getValue.getBytes');
set(handles.imageNameLabel, 'String', imageName);
numT = pixels.getSizeT.getValue;
sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
numC = pixels.getSizeC.getValue;
numZ = pixels.getSizeZ.getValue;
settingsThisPixels = renderSettingsService.getRenderingSettings(pixelsId);
defaultZ = settingsThisPixels.getDefaultZ.getValue;

anchorPos{numT} = [];
rectPos{numT} = [];
alignPos{numT} = [];

setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
setappdata(handles.CreateKymograph, 'rectPos', rectPos);
setappdata(handles.CreateKymograph, 'alignPos', alignPos);
setappdata(handles.CreateKymograph, 'numT', numT);
setappdata(handles.CreateKymograph, 'numZ', numZ);
setappdata(handles.CreateKymograph, 'numC', numC);
setappdata(handles.CreateKymograph, 'defaultZ', defaultZ);
setappdata(handles.CreateKymograph, 'imageSize', [sizeX sizeY]);
setappdata(handles.CreateKymograph, 'pixels', pixels);
setappdata(handles.CreateKymograph, 'pixelsId', pixelsId);


function enableDisableControls(handles, onOff)

set(handles.zSlider, 'enable', onOff);
set(handles.tSlider, 'enable', onOff);
set(handles.rectButton, 'enable', onOff);
set(handles.playButton, 'enable', onOff);
set(handles.pauseButton, 'enable', onOff);
