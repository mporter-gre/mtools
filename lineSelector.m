function varargout = lineSelector(varargin)
%LINESELECTOR M-file for lineSelector.fig
%      LINESELECTOR, by itself, creates a new LINESELECTOR or raises the existing
%      singleton*.
%
%      H = LINESELECTOR returns the handle to a new LINESELECTOR or the handle to
%      the existing singleton*.
%
%      LINESELECTOR('Property','Value',...) creates a new LINESELECTOR using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to lineSelector_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      LINESELECTOR('CALLBACK') and LINESELECTOR('CALLBACK',hObject,...) call the
%      local function named CALLBACK in LINESELECTOR.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lineSelector

% Last Modified by GUIDE v2.5 28-Oct-2009 14:35:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lineSelector_OpeningFcn, ...
                   'gui_OutputFcn',  @lineSelector_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before lineSelector is made visible.
function lineSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

handles.roishapeIdx = varargin{1};
handles.pixels = varargin{2};

scrsz = get(0,'ScreenSize');
set(hObject, 'Position', [(scrsz(3)/2)-429 (scrsz(4)/2)-174 858 348]);
imageName = handles.roishapeIdx{1}.imageName;
set(handles.imageNameLabel, 'String', imageName);

handles.queueIndices.line = [];
handles.queueIndices.ref = [];
handles.oldZ = -1;
handles.oldT = -1;
%get the indices of lineROIs and refROIs
numROI = length(handles.roishapeIdx);
refROIIdx = [];
lineROIIdx = [];
refROINames = {};
for thisROI = 1:numROI
    thisROIName = lower(handles.roishapeIdx{thisROI}.ROIName);
    isRef = strfind(thisROIName, 'ref');
    if ~isempty(isRef)
        refROIIdx = [refROIIdx thisROI];
        refROINames = [refROINames; {handles.roishapeIdx{thisROI}.ROIName}];
    else
        lineROIIdx = [lineROIIdx thisROI];
    end
end
refROIIdx = [refROIIdx thisROI+1];
refROINames = [refROINames; {'Horizontal'}];

handles.refROIIdx = refROIIdx;
handles.lineROIIdx = lineROIIdx;
handles.refROINames = refROINames;
set(handles.linesList, 'String', 'Select a Ref line');
set(handles.refList, 'String', refROINames);

% Choose default command line output for lineSelector
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lineSelector wait for user response (see UIRESUME)
uiwait(handles.lineSelector);


% --- Outputs from this function are returned to the command line.
function varargout = lineSelector_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.queueIndices;
varargout{2} = get(handles.queueList, 'String');
close(hObject);


% --- Executes on selection change in linesList.
function linesList_Callback(hObject, eventdata, handles)
% hObject    handle to linesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns linesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from linesList

roishapeIdx = handles.roishapeIdx;
refROIIdx = handles.refROIIdx;
selectedRefROIIdx = refROIIdx(get(handles.refList, 'Value'));
% refListIdx = get(hObject, 'Value');
% thisRefROIIdx = listedRefROIIdx(refListIdx);
set(handles.addButton, 'Enable', 'on');
pixels = handles.pixels;
pixelsId = pixels.getId.getValue;
sizeC = pixels.getSizeC.getValue;
sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
fullT = pixels.getSizeT.getValue;
fullZ = pixels.getSizeZ.getValue;
roishapeIdx = handles.roishapeIdx;
numROI = length(roishapeIdx);
lineListsStrings = get(hObject, 'String');
selectedLineName = lineListsStrings{get(hObject, 'Value')};
for thisROI = 1:numROI
    if strcmpi(selectedLineName, roishapeIdx{thisROI}.ROIName)
        selectedLineIdx = thisROI;
        break;
    end
end
selectedLineTs = roishapeIdx{selectedLineIdx}.T;
selectedLineZ = roishapeIdx{selectedLineIdx}.Z(1);
handles.selectedLineTs = selectedLineTs;

%Get the ref line timepoint that relates to the first timepoint of this
%line.
if selectedRefROIIdx > numROI
    refAndLineTInCommon = selectedLineTs(1)+1;
else
    refAndLineTInCommon = find(roishapeIdx{selectedRefROIIdx}.T == selectedLineTs(1));
end

%Get and display the image
oldT = handles.oldT;
oldZ = handles.oldZ;
%Don't download more frames if you don't have to.
if selectedLineZ ~= oldZ || refAndLineTInCommon(1) ~= oldT
    fullImage = zeros(sizeY, sizeX, sizeC);
    for thisC = 1:sizeC
        fullImage(:,:,thisC) = getPlaneFromPixelsId(pixelsId, selectedLineZ, thisC-1, roishapeIdx{selectedLineIdx}.T(refAndLineTInCommon(1)));
    end
    handles.oldT = selectedLineTs(1);
    handles.oldZ = selectedLineZ;
    handles.displayImage = createRenderedImage(fullImage, pixels);
end
axes(handles.imageAxes)
handles.projectionHandle = imshow(handles.displayImage);
%use Line function to draw this ROI on the image
startX = roishapeIdx{selectedLineIdx}.startX(1);
startY = roishapeIdx{selectedLineIdx}.startY(1);
endX = roishapeIdx{selectedLineIdx}.endX(1);
endY = roishapeIdx{selectedLineIdx}.endY(1);
handles.lineROICoords = [startX endX startY endY];
line([startX endX], [startY endY], 'color', 'white');

%Get the selected ref line coords and draw that too.
if selectedRefROIIdx > numROI
    line([1 sizeX], [ceil(sizeY/2) ceil(sizeY/2)], 'color', 'red');
else
    startX = roishapeIdx{selectedRefROIIdx}.startX(refAndLineTInCommon(1));
    startY = roishapeIdx{selectedRefROIIdx}.startY(refAndLineTInCommon(1));
    endX = roishapeIdx{selectedRefROIIdx}.endX(refAndLineTInCommon(1));
    endY = roishapeIdx{selectedRefROIIdx}.endY(refAndLineTInCommon(1));
    line([startX endX], [startY endY], 'color', 'red');
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function linesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in refList.
function refList_Callback(hObject, eventdata, handles)
% hObject    handle to refList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns refList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from refList

set(handles.addAllButton, 'Enable', 'on');
set(handles.addButton, 'Enable', 'off');
pixels = handles.pixels;
fullT = pixels.getSizeT.getValue;
fullZ = pixels.getSizeZ.getValue;

%get the lineROIs that are relevant to this ref ROI.
roishapeIdx = handles.roishapeIdx;
refROIIdx = handles.refROIIdx;
numROI = length(roishapeIdx);
selectedRefIdx = refROIIdx(get(hObject, 'Value'));

if selectedRefIdx > numROI
    selectedRefTs = 0:fullT-1;
    selectedRefZ = ceil(fullZ/2);
else
    selectedRefTs = roishapeIdx{selectedRefIdx}.T;
    selectedRefZ = roishapeIdx{selectedRefIdx}.Z(1);
end

lineROINames = {};
listedLineROIIdx = [];
for thisLineROI = handles.lineROIIdx
    thisLineTs = roishapeIdx{thisLineROI}.T;
    refTMembers = ismember(thisLineTs, selectedRefTs);
    if all(refTMembers)
        lineROINames = [lineROINames {roishapeIdx{thisLineROI}.ROIName}];
        listedLineROIIdx = [listedLineROIIdx, thisLineROI];
    end
end
handles.listedLineROIIdx = listedLineROIIdx;
set(handles.linesList, 'String', lineROINames);
set(handles.linesList, 'Value', 1);
if isempty(lineROINames)
    set(handles.addAllButton, 'Enable', 'off');
end

%redraw the rendered image for the first plane with this refROI
pixels = handles.pixels;
pixelsId = pixels.getId.getValue;
sizeC = pixels.getSizeC.getValue;
sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
fullImage = zeros(sizeY, sizeX, sizeC);
for thisC = 1:sizeC
    fullImage(:,:,thisC) = getPlaneFromPixelsId(pixelsId, selectedRefZ, thisC-1, selectedRefTs(1));
end
handles.oldT = selectedRefTs(1);
handles.oldZ = selectedRefZ;
handles.displayImage = createRenderedImage(fullImage, pixels);
axes(handles.imageAxes);
handles.projectionHandle = imshow(handles.displayImage);
% refCoords = handles.refROICoords;
% line([refCoords(1) refCoords(2)], [refCoords(3) refCoords(4)], 'color', 'white');

%use Line function to draw this ROI on the image. Also detect if
%'Horizontal' has been selected.
if selectedRefIdx > numROI
    line([1 sizeX], [ceil(sizeY/2) ceil(sizeY/2)], 'color', 'red');
else
    startX = roishapeIdx{selectedRefIdx}.startX(1);
    startY = roishapeIdx{selectedRefIdx}.startY(1);
    endX = roishapeIdx{selectedRefIdx}.endX(1);
    endY = roishapeIdx{selectedRefIdx}.endY(1);
    line([startX endX], [startY endY], 'color', 'red');
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function refList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in queueList.
function queueList_Callback(hObject, eventdata, handles)
% hObject    handle to queueList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns queueList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from queueList

set(handles.removeButton, 'Enable', 'on');


% --- Executes during object creation, after setting all properties.
function queueList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to queueList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addButton.
function addButton_Callback(hObject, eventdata, handles)
% hObject    handle to addButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.removeAllButton, 'Enable', 'on');
%Get the names of the Line and Ref lines to add to the queue list
chosenLineIdx = get(handles.linesList, 'Value');
lineStrings = get(handles.linesList, 'String');
chosenLine = lineStrings{chosenLineIdx};
chosenRefIdx = get(handles.refList, 'Value');
refStrings = get(handles.refList, 'String');
chosenRef = refStrings{chosenRefIdx};
queueString = [chosenLine, ' relative to ' chosenRef];
queueListStrings = get(handles.queueList, 'String');
if all(ismember(queueString, queueListStrings))
    warndlg('This measurement is already in the queue');
    set(handles.addButton, 'Enable', 'off');
    return;
end
if ~iscell(queueListStrings)
    queueListStrings{1} = queueString;
else
    if strcmp(queueListStrings{1}, '')
        queueListStrings{1} = queueString;
    else
        queueListStrings = [queueListStrings; queueString];
    end
end
set(handles.queueList, 'String', queueListStrings);

%List the indices of the Line and Ref lines from the roishapeIdx cell for
%processing when 'Finish' is pressed.
roishapeIdx = handles.roishapeIdx;
numROI = length(roishapeIdx);
queueIndices = handles.queueIndices;
for thisROI = 1:numROI
    if strcmpi(roishapeIdx{thisROI}.ROIName, chosenLine)
        queueIndices.line(end+1) = thisROI;
    elseif strcmpi(roishapeIdx{thisROI}.ROIName, chosenRef)
        queueIndices.ref(end+1) = thisROI;
    end
end
if strcmpi(chosenRef, 'Horizontal')
    queueIndices.ref(end+1) = numROI+1;
end

set(handles.addButton, 'Enable', 'off');
set(handles.finishedButton, 'Enable', 'on');
handles.queueIndices = queueIndices;
guidata(hObject, handles);



% --- Executes on button press in removeButton.
function removeButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

queueIndices = handles.queueIndices;
queueListStrings = get(handles.queueList, 'String');
queueListIdx = get(handles.queueList, 'Value');
if length(queueListStrings) ~= 1
    if queueListIdx ~= length(queueListStrings);
        linesToKeep = queueIndices.line(queueListIdx+1:end);
        queueIndices.line(queueListIdx:queueListIdx+length(linesToKeep)-1) = linesToKeep;

        refsToKeep = queueIndices.ref(queueListIdx+1:end);
        queueIndices.ref(queueListIdx:queueListIdx+length(refsToKeep)-1) = refsToKeep;

        queueIndices.line = queueIndices.line(1:end-1);
        queueIndices.ref = queueIndices.ref(1:end-1);

        for thisIdx = queueListIdx:length(queueListStrings)-1
            queueListStrings{thisIdx} = queueListStrings{thisIdx+1};
        end
        for thisIdx = 1:length(queueListStrings)-1
            tmpListStrings{thisIdx} = queueListStrings{thisIdx};
        end
        queueListStrings = tmpListStrings;
    else
        queueIndices.line = queueIndices.line(1:end-1);
        queueIndices.ref = queueIndices.ref(1:end-1);
        
        for thisIdx = 1:length(queueListStrings)-1
            tmpListStrings{thisIdx} = queueListStrings{thisIdx};
        end
        queueListStrings = tmpListStrings;
    end
else
    queueListStrings = [];
    queueListStrings{1} = '';
    queueIndices.line = [];
    queueIndices.ref = [];
    set(handles.finishedButton, 'Enable', 'off');
end


handles.queueIndices = queueIndices;
set(handles.queueList, 'String', queueListStrings);
set(handles.queueList, 'Value', 1);
set(hObject, 'Enable', 'off');

guidata(hObject, handles);



% --- Executes on button press in finishedButton.
function finishedButton_Callback(hObject, eventdata, handles)
% hObject    handle to finishedButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% queueListStrings = get(handles.queueList, 'String');

% if ~iscell(queueListStrings) || isempty(queueListStrings{1})
%     answer = questdlg('The queue list for this image is empty, do you want to continue to the next image?','Empty Queue','Yes','No','default', 'No');
%     if strcmp(answer, 'No')
%         return;
%     end
% end
uiresume;


function imageAxes_CreateFcn(hObject, eventdata, handles)

axis off;


% --- Executes on button press in addAllButton.
function addAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to addAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

roishapeIdx = handles.roishapeIdx;
numROI = length(roishapeIdx);
chosenRefIdx = get(handles.refList, 'Value');
refStrings = get(handles.refList, 'String');
chosenRef = refStrings{chosenRefIdx};
linesStrings = get(handles.linesList, 'String');
queueListStrings = get(handles.queueList, 'String');
queueIndices = handles.queueIndices;

for thisLine = 1:length(linesStrings)
    chosenLine = linesStrings{thisLine};
    queueString = [chosenLine, ' relative to ' chosenRef];
    if ~iscell(queueListStrings)
        queueListStrings{1} = queueString;
    else
        if strcmp(queueListStrings{1}, '')
            queueListStrings{1} = queueString;
        elseif all(ismember(queueString, queueListStrings))
            continue;
        else
            queueListStrings = [queueListStrings; queueString];
        end
    end
    for thisROI = 1:numROI
        if strcmpi(roishapeIdx{thisROI}.ROIName, chosenLine)
            queueIndices.line(end+1) = thisROI;
        elseif strcmpi(roishapeIdx{thisROI}.ROIName, chosenRef)
            queueIndices.ref(end+1) = thisROI;
        end
    end
    if strcmpi(chosenRef, 'Horizontal')
        queueIndices.ref(end+1) = numROI+1;
    end
end

set(handles.queueList, 'String', queueListStrings);
set(handles.addButton, 'Enable', 'off');
set(handles.removeAllButton, 'Enable', 'on');
set(handles.addAllButton, 'Enable', 'off');
set(handles.finishedButton, 'Enable', 'on');
handles.queueIndices = queueIndices;

guidata(hObject, handles);



% --- Executes on button press in removeAllButton.
function removeAllButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeAllButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

queueListStrings{1} = '';
set(handles.queueList, 'String', queueListStrings);
handles.queueIndices.line = [];
handles.queueIndices.ref = [];
set(hObject, 'Enable', 'off');
set(handles.finishedButton, 'Enable', 'off');

guidata(hObject, handles);

