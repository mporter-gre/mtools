function varargout = createChymograph(varargin)
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
%      applied to the GUI before createChymograph_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createChymograph_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createkymograph

% Last Modified by GUIDE v2.5 14-Jan-2010 17:56:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createChymograph_OpeningFcn, ...
                   'gui_OutputFcn',  @createChymograph_OutputFcn, ...
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
function createChymograph_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createkymograph (see VARARGIN)

global gateway;
%Set up the play and pause buttons
playIcon = imread('play24.png', 'png');
pauseIcon = imread('pause24.png', 'png');
set(handles.playButton,'CDATA',playIcon);
set(handles.pauseButton,'CDATA',pauseIcon);

% Choose default command line output for createkymograph
set(handles.CreateKymograph, 'windowbuttonmotionfcn', {@windowButtonMotion, handles});
set(handles.CreateKymograph, 'WindowButtonUpFcn', {@imageAnchor_ButtonUpFcn, handles});
set(handles.CreateKymograph, 'keypressfcn', {@currentWindowKeypress, handles});
handles.output = hObject;
handles.imageObj = varargin{1};
imageId = handles.imageObj.getId.getValue;
handles.pixels = gateway.getPixelsFromImage(imageId);
if strcmp(class(handles.pixels), 'java.util.ArrayList');
    handles.pixels = handles.pixels.get(0);
end
handles.pixelsId = handles.pixels.getId.getValue;
handles.numC = handles.pixels.getSizeC.getValue;
%handles.fullImage = varargin{2};
imageName = native2unicode(handles.imageObj.getName.getValue.getBytes');
set(handles.imageNameLabel, 'String', imageName);
numT = handles.pixels.getSizeT.getValue;
handles.numZ = handles.pixels.getSizeZ.getValue;

anchorPos{numT} = [];
rectPos{numT} = [];
alignPos{numT} = [];
setappdata(handles.CreateKymograph, 'setAnchor', 0);
setappdata(handles.CreateKymograph, 'setAlignment', 0);
setappdata(handles.CreateKymograph, 'firstAnchor', 1);
setappdata(handles.CreateKymograph, 'firstAlign', 1);
setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
setappdata(handles.CreateKymograph, 'rectPos', rectPos);
setappdata(handles.CreateKymograph, 'alignPos', alignPos);
setappdata(handles.CreateKymograph, 'includeROI', []);
setappdata(handles.CreateKymograph, 'hideAnchor', 0);
setappdata(handles.CreateKymograph, 'stopRecording', 0);
setappdata(handles.CreateKymograph, 'rotationView', 0);
setappdata(handles.CreateKymograph, 'movingAnchor', 0);
setappdata(handles.CreateKymograph, 'movingAlign', 0);
setappdata(handles.CreateKymograph, 'numT', numT);
setappdata(handles.CreateKymograph, 'numZ', handles.numZ);

setTSlider(handles);
setZSlider(handles);
set(handles.stopZText, 'String', num2str(handles.numZ));

getPlane(handles, 0, 0)
refreshDisplay(handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createkymograph wait for user response (see UIRESUME)
% uiwait(handles.CreateKymograph);


% --- Outputs from this function are returned to the command line.
function varargout = createChymograph_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in rectButton.
function rectButton_Callback(hObject, eventdata, handles)
% hObject    handle to rectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

renderedImage = getappdata(handles.CreateKymograph, 'renderedImage');
axes(handles.imageAxes);
handles.imageHandle = imshow(renderedImage);
set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
thisT = round(get(handles.tSlider, 'Value'));
numT = getappdata(handles.CreateKymograph, 'numT');
anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
rectPos = getappdata(handles.CreateKymograph, 'rectPos');
for t = 1:numT
    %Reset any previously set ROI or anchor point to null;
    anchorPos{t} = [];
    rectPos{t} = [];
end

maxX = get(handles.imageAxes, 'XLim');
maxY = get(handles.imageAxes, 'YLim');
rectPos{thisT} = getrect(handles.imageAxes);

if rectPos{thisT}(1) > 0 && rectPos{thisT}(1) <= maxX(2) && rectPos{thisT}(2) > 0 && rectPos{thisT}(2) <= maxY(2)
    for t = 1:numT
        rectPos{t} = rectPos{thisT};
    end
    rect = rectangle('Position', rectPos{thisT}, 'edgecolor', 'white');
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




% --- Executes on button press in setAnchorButton.
function setAnchorButton_Callback(hObject, eventdata, handles)
% hObject    handle to setAnchorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(gcf,'Pointer','fleur')
setAnchor = 1;
setappdata(handles.CreateKymograph, 'setAnchor', setAnchor);
setappdata(handles.CreateKymograph, 'setAlignment', 0);



% --- Executes on button press in recordAnchorButton.
function recordAnchorButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordAnchorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure(handles.CreateKymograph);
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
frameDelay = str2double(get(handles.delayText, 'String'));
thisZ = round(get(handles.zSlider, 'Value'));
set(handles.alertText, 'Visible', 'on');
set(handles.tSlider, 'Value', includeROI(1));
set(handles.tLabel, 'String', ['T = ' num2str(includeROI(1))]);
setappdata(handles.CreateKymograph, 'rotationView', 0);
getPlane(handles, thisZ-1, includeROI(1)-1)
redrawImage(handles);
redrawRect(handles);
redrawAnchor(handles);
redrawAlign(handles);
setappdata(handles.CreateKymograph, 'stopRecording', 0);
rectPos = getappdata(handles.CreateKymograph, 'rectPos');
anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
setappdata(handles.CreateKymograph, 'trapPointer', 1);
for i = 5:-1:0
    pause(1);
    alertStr = get(handles.alertText, 'String');
    alertStr{2}(end) = num2str(i);
    set(handles.alertText, 'String', alertStr);
end
%Make sure the window is activated
mouseClick;
for thisT = includeROI
    stopRecording = getappdata(handles.CreateKymograph, 'stopRecording');
    if stopRecording == 1
        set(handles.alertText, 'Visible', 'off');
        redrawAnchor(handles);
        setappdata(handles.CreateKymograph, 'trapPointer', 0);
        break;
    end
    getPlane(handles, thisZ-1, thisT-1)
    redrawImage(handles);
    redrawRect(handles);
    redrawAlign(handles);
    pause(frameDelay);
    set(handles.tSlider, 'Value', thisT);
    set(handles.tLabel, 'String', ['T = ' num2str(thisT)]);
    currentPoint = getappdata(handles.CreateKymograph, 'currentPoint');
    offset = [currentPoint(1)-anchorPos{thisT}(1) currentPoint(3)-anchorPos{thisT}(2)];
    rectPos{thisT} = [rectPos{thisT}(1)+offset(1) rectPos{thisT}(2)+offset(2) rectPos{thisT}(3) rectPos{thisT}(4)];
    anchorPos{thisT} = [currentPoint(1), currentPoint(3)];
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
setappdata(handles.CreateKymograph, 'trapPointer', 0);
    
    
    



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
set(handles.tLabel, 'String', ['T = ' num2str(t)]);
getPlane(handles, z-1, t-1);
if ismember(t, includeROI) && rotationView == 1 && ~isempty(alignPos{t})
    rotateImage(handles)
    displayImage = getappdata(handles.CreateKymograph, 'rotatedImage');
else
    displayImage = getappdata(handles.CreateKymograph, 'renderedImage');
end
axes(handles.imageAxes);
handles.imageHandle = imshow(displayImage);
set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
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
numZ = handles.numZ;
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

pixelsId = handles.pixelsId;
numC = handles.numC;
for thisC = 1:numC
    plane(:,:,thisC) = getPlaneFromPixelsId(pixelsId, z, thisC-1, t);
end
renderedImage = createRenderedImage(plane, handles.pixels);
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

numZ = handles.numZ;
if numZ > 1
    sliderSmallStep = 1/numZ;
    set(handles.zSlider, 'Max', numZ);
    set(handles.zSlider, 'Min', 1);
    set(handles.zSlider, 'Value', 1);
    set(handles.zSlider, 'SliderStep', [sliderSmallStep, sliderSmallStep*4]);
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
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
rotationView = getappdata(handles.CreateKymograph, 'rotationView');
set(handles.zLabel, 'String', ['Z = ' num2str(z)]);
axes(handles.imageAxes);
getPlane(handles, z-1, t-1);
if ~isempty(alignPos{t}) && rotationView == 1
    rotateImage(handles)
    displayImage = getappdata(handles.CreateKymograph, 'rotatedImage');
else
    displayImage = getappdata(handles.CreateKymograph, 'renderedImage');
end
axes(handles.imageAxes);
handles.imageHandle = imshow(displayImage);
set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
redrawRect(handles);
redrawAnchor(handles);
redrawAlign(handles);
guidata(hObject, handles);




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

thisT = round(get(handles.tSlider, 'Value'));
numT = getappdata(handles.CreateKymograph, 'numT');
firstAnchor = getappdata(handles.CreateKymograph, 'firstAnchor');

if setAnchor == 1 && ismember(thisT, includeROI)
    currentPoint = get(handles.imageAxes, 'CurrentPoint');
    if firstAnchor == 0
        redrawImage(handles);
    end
    if hideAnchor ~= 1
        anchor = impoint(gca,currentPoint(1), currentPoint(3));
        api = iptgetapi(anchor);
        %Stop the user manually moving the point beyond the image axes.
        fcn = makeConstrainToRectFcn('impoint', get(gca, 'XLim'), get(gca, 'YLim'));
        api.setPositionConstraintFcn(fcn);
        api.addNewPositionCallback(@(pos) anchorPositionUpdateFcn(pos, handles));
    end
    if firstAnchor == 1
        anchorPos{thisT} = [currentPoint(1), currentPoint(3)];
        setappdata(handles.CreateKymograph, 'firstAnchor', 0);
        for t = 1:numT
            anchorPos{t} = anchorPos{thisT};
        end
        set(handles.recordAnchorButton, 'Enable', 'on');
        set(handles.setAlignmentButton, 'Enable', 'on');
        set(handles.delayText, 'Enable', 'on');
        setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
    else
        %         if isempty(anchorPos{thisT})
        %             anchorPos{thisT} = [currentPoint(1), currentPoint(3)];
        %             setappdata(handles.CreateKymograph, 'rectPos', rectPos);
        %             refreshDisplay(handles);
        % %             redrawRect(handles);
        % %             redrawAlign(handles);
        %         else
        offset = [currentPoint(1)-anchorPos{thisT}(1) currentPoint(3)-anchorPos{thisT}(2)];
        rectPos{thisT} = [rectPos{thisT}(1)+offset(1) rectPos{thisT}(2)+offset(2) rectPos{thisT}(3) rectPos{thisT}(4)];
        anchorPos{thisT} = [currentPoint(1), currentPoint(3)];
        setappdata(handles.CreateKymograph, 'rectPos', rectPos);
        setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
        alignUpdateOnAnchorMove(offset, handles);
        refreshDisplay(handles);
        %             redrawRect(handles);
        %             redrawAlign(handles);
        %         end
    end
    
    setappdata(handles.CreateKymograph, 'setAnchor', 0);
end

if setAlignment == 1 && ismember(thisT, includeROI)
    firstAlign = getappdata(handles.CreateKymograph, 'firstAlign');
    currentPoint = get(handles.imageAxes, 'CurrentPoint');
    if firstAlign == 1
        for t = 1:numT
            alignPos{t} = [currentPoint(1), currentPoint(3)];
        end
        setappdata(handles.CreateKymograph, 'fristAlign', 0);
    else
        alignPos{thisT} = [currentPoint(1), currentPoint(3)];
    end
    setappdata(handles.CreateKymograph, 'alignPos', alignPos);
    setappdata(handles.CreateKymograph, 'setAlignment', 0);
    set(handles.recordAlignmentButton, 'Enable', 'on');
    rotateImage(handles);
    refreshDisplay(handles);
%     redrawImage(handles);
%     redrawRect(handles);
%     redrawAnchor(handles);
%     redrawAlign(handles);
end
% if rotate == 1
%     currentPoint = get(handles.imageAxes, 'CurrentPoint');
%     rotatePos{thisT} = [currentPoint(1) currentPoint(3)];
%     setappdata(handles.CreateKymograph, 'rotatePos', rotatePos);
%     rotateImage(handles);
%     setappdata(handles.CreateKymograph, 'rotate', 0);
% end

set(gcf,'Pointer','arrow');

    

function redrawRect(handles)

rectPos = getappdata(handles.CreateKymograph, 'rectPos');
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
thisT = round(get(handles.tSlider, 'Value'));
if ismember(thisT, includeROI)
    rect = rectangle('Position', rectPos{thisT}, 'edgecolor', 'white');
end

    

function redrawAnchor(handles)

thisT = round(get(handles.tSlider, 'Value'));
anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
if ismember(thisT, includeROI) && ~isempty(anchorPos{thisT})
    anchor{thisT} = impoint(gca,anchorPos{thisT}(1), anchorPos{thisT}(2));
    api = iptgetapi(anchor{thisT});
    %Stop the user manually moving the point out of the axes.
    positionConstrainFcn = makeConstrainToRectFcn('impoint', get(gca, 'XLim'), get(gca, 'YLim'));
    api.addNewPositionCallback(@(pos) anchorPositionUpdateFcn(pos, handles));
    api.setPositionConstraintFcn(positionConstrainFcn);
end


function anchorPositionUpdateFcn(pos, handles)

setappdata(handles.CreateKymograph, 'movingAnchor', 1);
anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
rectPos = getappdata(handles.CreateKymograph, 'rectPos');
thisT = round(get(handles.tSlider, 'Value'));
oldAnchorPos = anchorPos{thisT};
anchorPos{thisT}(1) = pos(1);
anchorPos{thisT}(2) = pos(2);
offset = [pos(1)-oldAnchorPos(1) pos(2)-oldAnchorPos(2)];
rectPos{thisT} = [rectPos{thisT}(1)+offset(1) rectPos{thisT}(2)+offset(2) rectPos{thisT}(3) rectPos{thisT}(4)];
alignUpdateOnAnchorMove(offset, handles);

setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
setappdata(handles.CreateKymograph, 'rectPos', rectPos);

% redrawImage(handles);
% redrawRect(handles);


function alignPositionUpdateFcn(pos, handles)

alignPos = getappdata(handles.CreateKymograph, 'alignPos');
thisT = round(get(handles.tSlider, 'Value'));
alignPos{thisT}(1) = pos(1);
alignPos{thisT}(2) = pos(2);
setappdata(handles.CreateKymograph, 'alignPos', alignPos);
setappdata(handles.CreateKymograph, 'movingAlign', 1);



function alignUpdateOnAnchorMove(offset, handles)

alignPos = getappdata(handles.CreateKymograph, 'alignPos');
thisT = round(get(handles.tSlider, 'Value'));

if ~isempty(alignPos{thisT})
    alignPos{thisT} = [alignPos{thisT}(1)+offset(1) alignPos{thisT}(2)+offset(2)];
    xlim = get(gca, 'XLim');
    ylim = get(gca, 'XLim');
    if alignPos{thisT}(1) < 1
        alignPos{thisT}(1) = 1;
    elseif alignPos{thisT}(1) > xlim(2)
        alignPos{thisT}(1) = xlim(2);
    end
    if alignPos{thisT}(2) < 1
        alignPos{thisT}(2) = 1;
    elseif alignPos{thisT}(2) > ylim(2)
        alignPos{thisT}(2) = ylim(2);
    end
    setappdata(handles.CreateKymograph, 'alignPos', alignPos);
end


function redrawImage(handles)

includeROI = getappdata(handles.CreateKymograph, 'includeROI');
rotationView = getappdata(handles.CreateKymograph, 'rotationView');
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
thisT = round(get(handles.tSlider, 'Value'));
if ismember(thisT, includeROI) && rotationView == 1 && ~isempty(alignPos{thisT})
    displayImage = getappdata(handles.CreateKymograph, 'rotatedImage');
else
    displayImage = getappdata(handles.CreateKymograph, 'renderedImage');
end
handles.imageHandle = imshow(displayImage);
set(handles.imageHandle, 'ButtonDownFcn', {@imageAnchor_ButtonDownFcn, handles});
setappdata(handles.CreateKymograph, 'thisImageHandle', handles.imageHandle);



function windowButtonMotion(hObject, eventdata, handles)

currentPoint = get(handles.imageAxes, 'CurrentPoint');
setappdata(handles.CreateKymograph, 'currentPoint', currentPoint);



%trapPointer = getappdata(handles.CreateKymograph, 'trapPointer');

% if trapPointer == 1
%     windowPosition = get(handles.CreateKymograph, 'Position');
%     axesPosition = get(handles.imageAxes, 'Position');
%     minX = axesPosition(1);
%     minY = axesPosition(2);
%     maxX = minX + axesPosition(3);
%     maxY = minY + axesPosition(4);
%     if currentPoint(3) > maxY
%         set(0, 'PointerLocation', [(currentPoint(1) + windowPosition(1)-1) (maxY + windowPosition(2)-1)]);
%     end
%     if currentPoint(1) > maxX
%         set(0, 'PointerLocation', [(maxX + windowPosition(1)-1) (currentPoint(3) + windowPosition(2)-1)]);
%     end
%     if currentPoint(1) < minX
%         set(0, 'PointerLocation', [(minX + windowPosition(1)-1) (currentPoint(3) + windowPosition(2)-1)]);
%     end
%     if currentPoint(3) < minY
%         set(0, 'PointerLocation', [(currentPoint(1) + windowPosition(1)-1) (minY + windowPosition(2)-1)]);
%     end
% end




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
% redrawImage(handles);
% redrawRect(handles);
% redrawAnchor(handles);
% redrawAlign(handles);


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
% redrawImage(handles);
% redrawRect(handles);
% redrawAnchor(handles);
% redrawAlign(handles);


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
    set(handles.tSlider, 'Value', thisT);
    set(handles.tLabel, 'String', ['T = ' num2str(thisT)]);
    thisZ = round(get(handles.zSlider, 'Value'));
    getPlane(handles, thisZ-1, thisT-1)
    if ismember(thisT, includeROI) && rotationView == 1
        rotateImage(handles);
    end
    refreshDisplay(handles);
%     redrawImage(handles);
%     redrawRect(handles);
%     redrawAnchor(handles);
%     redrawAlign(handles);
    drawnow expose;
    pause(frameDelay);
end



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
end
if strcmp(currentKey, 'f5')
    refreshDisplay(handles);
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


renderedImage = getappdata(handles.CreateKymograph, 'renderedImage');
imageSize = size(renderedImage(:,:,1));
thisT = round(get(handles.tSlider, 'Value'));
anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
% currentPoint = getappdata(handles.CreateKymograph, 'currentPoint')
if ~isempty(alignPos{thisT})
    horiz = get(handles.horizontalRadio, 'Value');
    point = anchorPos{thisT};
    imageCentre = round(imageSize./2);
    anglePoint = alignPos{thisT};
    grad = (point(1)-anglePoint(1))/(point(2)-anglePoint(2));
%     if horiz == 1
%         if point(2) < anglePoint(2)
%             rotAngle = -90+sqrt(atand(grad)^2)
%         else
%             rotAngle = 90-sqrt(atand(grad)^2)
%         end
%     else
%         if point(1) < anglePoint(1)
%             rotAngle = -sqrt(atand(grad)^2);
%         else
%             rotAngle = sqrt(atand(grad)^2);
%         end
%         %rotAngle = sqrt(atand(grad)^2);
%     end
    Y = imageSize(1) - point(1);
    X = imageSize(2) - point(2);
    YPad = Y - point(1);
    XPad = X - point(2);
    pad = abs([XPad YPad]);
    offset = [XPad-imageCentre(2) YPad-imageCentre(1)];
    offsetSign = sign(offset);
    offset = abs(offset);
    if offsetSign(1) == 1 && offsetSign(2)== 1
        paddedImage = padarray(renderedImage, offset, 'pre');
    elseif offsetSign(1) == 1 && offsetSign(2)== -1
        paddedImage = padarray(renderedImage, [offset(1) 0], 'pre');
        paddedImage = padarray(paddedImage, [0, offset(2)], 'post');
    elseif offsetSign(1) == -1 && offsetSign(2)== 1
        paddedImage = padarray(renderedImage, [offset(1) 0], 'post');
        paddedImage = padarray(paddedImage, [0, offset(2)], 'pre');
    elseif offsetSign(1) == -1 && offsetSign(2)== -1
        paddedImage = padarray(renderedImage, pad, 'post');
    elseif offsetSign(1) == 1 && offsetSign(2)== 0
        paddedImage = padarray(renderedImage, [offset(1) 0], 'pre');
    elseif offsetSign(1) == 0 && offsetSign(2)== 1
        paddedImage = padarray(renderedImage, [0 offset(2)], 'pre');
    elseif offsetSign(1) == -1 && offsetSign(2)== 0
        paddedImage = padarray(renderedImage, [offset(1) 0], 'post');
    elseif offsetSign(1) == 0 && offsetSign(2)== -1
        paddedImage = padarray(renderedImage, [0 offset(2)], 'post');
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
        %     elseif rotateOffsetSign(1) == 1 && rotateOffsetSign(2)== 0
        %         rotatedPaddedImage = renderedImage;
        %     elseif rotateOffsetSign(1) == 0 && rotateOffsetSign(2)== 1
        %         rotatedPaddedImage = imrotate(paddedImage, -rotAngle, 'crop');
        %     elseif rotateOffsetSign(1) == -1 && rotateOffsetSign(2)== 0
        %         rotatedPaddedImage = renderedImage;
        %     elseif rotateOffsetSign(1) == 0 && rotateOffsetSign(2)== -1
        %         rotatedPaddedImage = imrotate(paddedImage, -rotAngle, 'crop');
        %     elseif rotateOffsetSign(1) == 0 && rotateOffsetSign(2) == 0
        %         rotatedPaddedImage = renderedImage;
        %     end
    else
        if rotateOffsetSign(1) == 1 && rotateOffsetSign(2)== 1
            rotAngle = -sqrt(atand(grad)^2);
        elseif rotateOffsetSign(1) == 1 && rotateOffsetSign(2)== -1
            rotAngle = -90+sqrt(atand(grad)^2);
        elseif rotateOffsetSign(1) == -1 && rotateOffsetSign(2)== 1
            rotAngle = sqrt(atand(grad)^2);
        elseif rotateOffsetSign(1) == -1 && rotateOffsetSign(2)== -1
            rotAngle = sqrt(atand(grad)^2);
        elseif grad == -Inf
            rotAngle = 0;
        end
        %     elseif rotateOffsetSign(1) == 1 && rotateOffsetSign(2)== 0
        %         rotatedPaddedImage = renderedImage;
        %     elseif rotateOffsetSign(1) == 0 && rotateOffsetSign(2)== 1
        %         rotatedPaddedImage = imrotate(paddedImage, -rotAngle, 'crop');
        %     elseif rotateOffsetSign(1) == -1 && rotateOffsetSign(2)== 0
        %         rotatedPaddedImage = renderedImage;
        %     elseif rotateOffsetSign(1) == 0 && rotateOffsetSign(2)== -1
        %         rotatedPaddedImage = imrotate(paddedImage, -rotAngle, 'crop');
        %     elseif rotateOffsetSign(1) == 0 && rotateOffsetSign(2) == 0
        %         rotatedPaddedImage = renderedImage;
        %     end
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

set(gcf,'Pointer','fleur')
setappdata(handles.CreateKymograph, 'setAlignment', 1);
setappdata(handles.CreateKymograph, 'setAnchor', 0);



% --- Executes on button press in recordAlignmentButton.
function recordAlignmentButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordAlignmentButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure(handles.CreateKymograph);
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
frameDelay = str2double(get(handles.delayText, 'String'));
thisZ = round(get(handles.zSlider, 'Value'));
set(handles.alertText, 'Visible', 'on');
set(handles.tSlider, 'Value', includeROI(1));
set(handles.tLabel, 'String', ['T = ' num2str(includeROI(1))]);
setappdata(handles.CreateKymograph, 'rotationView', 0);
getPlane(handles, thisZ-1, includeROI(1)-1)
redrawImage(handles);
redrawRect(handles);
redrawAnchor(handles);
redrawAlign(handles);
setappdata(handles.CreateKymograph, 'stopRecording', 0);
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
% rectPos = getappdata(handles.CreateKymograph, 'rectPos');
% anchorPos = getappdata(handles.CreateKymograph, 'anchorPos');
setappdata(handles.CreateKymograph, 'trapPointer', 1);
for i = 5:-1:0
    pause(1);
    alertStr = get(handles.alertText, 'String');
    alertStr{2}(end) = num2str(i);
    set(handles.alertText, 'String', alertStr);
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
    redrawImage(handles);
    redrawRect(handles);
    redrawAnchor(handles);
    pause(frameDelay);
    set(handles.tSlider, 'Value', thisT);
    set(handles.tLabel, 'String', ['T = ' num2str(thisT)]);
    currentPoint = getappdata(handles.CreateKymograph, 'currentPoint');
    alignPos{thisT} = [currentPoint(1), currentPoint(3)];
    setappdata(handles.CreateKymograph, 'alignPos', alignPos);
%     redrawRect(handles);
%     setappdata(handles.CreateKymograph, 'anchorPos', anchorPos);
    drawnow;
end
refreshDisplay(handles);
alertStr = get(handles.alertText, 'String');
alertStr{2}(end) = num2str(5);
set(handles.alertText, 'String', alertStr);
set(handles.alertText, 'Visible', 'off');
setappdata(handles.CreateKymograph, 'trapPointer', 0);


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
    rotationView = 1;
    setappdata(handles.CreateKymograph, 'rotationView', rotationView);
    set(hObject,'Checked','on');
else
    rotationView = 0;
    setappdata(handles.CreateKymograph, 'rotationView', rotationView);
    set(hObject,'Checked','off');
end

refreshDisplay(handles);
% redrawImage(handles);
% redrawRect(handles);
% redrawAnchor(handles);
% redrawAlign(handles)


function redrawAlign(handles)

includeROI = getappdata(handles.CreateKymograph, 'includeROI');
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
rotationView = getappdata(handles.CreateKymograph, 'rotationView');
thisT = round(get(handles.tSlider, 'Value'));

if ismember(thisT, includeROI) && rotationView == 0 && ~isempty(alignPos{thisT})
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

answer = questdlg('Clear the ROI and all the anchor and alignment points?', 'Clear All?','Yes','No','No');

switch answer
    case 'Yes'
        numT = getappdata(handles.CreateKymograph, 'numT');
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
        set(handles.setAnchorButton, 'Enable', 'off');
        set(handles.recordAnchorButton, 'Enable', 'off');
        set(handles.setAlignmentButton, 'Enable', 'off');
        set(handles.recordAlignmentButton, 'Enable', 'off');
        set(handles.startTText, 'String', []);
        set(handles.startTText, 'Enable', 'off');
        set(handles.endTText, 'String', []);
        set(handles.endTText, 'Enable', 'off');
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

answer = questdlg([{'Close this image to open another?'},{'All data will be lost!'}], 'Quit?','Yes','No','Yes');
switch answer,
    case 'Yes',
        loginImageSelector;
        close(handles.CreateKymograph);
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

drawnow;


numC = handles.numC;
includeROI = getappdata(handles.CreateKymograph, 'includeROI');
numIncluded = length(includeROI);
zSections = str2double(get(handles.startZText, 'String')) : str2double(get(handles.stopZText, 'String'));
rectPos = getappdata(handles.CreateKymograph, 'rectPos');
alignPos = getappdata(handles.CreateKymograph, 'alignPos');
topDown = get(handles.topDownRadio, 'Value');
X = uint32(rectPos{1}(1));
Y = uint32(rectPos{1}(2));
width = uint32(rectPos{1}(3));
height = uint32(rectPos{1}(4));

for t = 1:length(includeROI)
    patch{t} = zeros([int32(rectPos{1}(4)) int32(rectPos{1}(3)) int32(3)]);
end

counter = 1;
for thisT = includeROI
    for thisC = 1:numC
        for thisZ = zSections
            planesThisC(:,:,thisZ) = getPlaneFromPixelsId(handles.pixelsId, thisZ-1, thisC-1, thisT-1);
        end
        projectionThisC(:,:,thisC) = max(planesThisC, [], 3);
    end
    projection(:,:,thisT) = max(planesThisC, [], 3);
    renderedProjection = createRenderedImage(projectionThisC, handles.pixels);
    set(handles.tSlider, 'Value', thisT);
    setappdata(handles.CreateKymograph, 'renderedImage', renderedProjection);
    if ~isempty(alignPos{thisT})
       rotateImage(handles);
       baseImage = getappdata(handles.CreateKymograph, 'rotatedImage');
    else
        baseImage = getappdata(handles.CreateKymograph, 'renderedImage');
    end
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


% --- Executes on selection change in roiSelect.
function roiSelect_Callback(hObject, eventdata, handles)
% hObject    handle to roiSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns roiSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roiSelect


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


