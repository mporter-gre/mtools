function varargout = attachResults(varargin)
% ATTACHRESULTS MATLAB code for attachResults.fig
%      ATTACHRESULTS, by itself, creates a new ATTACHRESULTS or raises the existing
%      singleton*.
%
%      H = ATTACHRESULTS returns the handle to a new ATTACHRESULTS or the handle to
%      the existing singleton*.
%
%      ATTACHRESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ATTACHRESULTS.M with the given input arguments.
%
%      ATTACHRESULTS('Property','Value',...) creates a new ATTACHRESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before attachResults_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to attachResults_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help attachResults

% Last Modified by GUIDE v2.5 11-Mar-2016 15:00:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @attachResults_OpeningFcn, ...
                   'gui_OutputFcn',  @attachResults_OutputFcn, ...
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


% --- Executes just before attachResults is made visible.
function attachResults_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to attachResults (see VARARGIN)

% Choose default command line output for attachResults
handles.output = hObject;

projList = varargin{1};
dsList = varargin{2};
fileNames = varargin{3};
filePath = varargin{4};
numProj = length(projList);
numDs = length(dsList);
projPanel = handles.projPanel;
dsPanel = handles.dsPanel;
setappdata(handles.attachResults, 'chkCounter', 0);
setappdata(handles.attachResults, 'numProj', numProj);
setappdata(handles.attachResults, 'numDs', numDs);
setappdata(handles.attachResults, 'fileNames', fileNames);
setappdata(handles.attachResults, 'filePath', filePath);
set(handles.projSlider, 'Min', 1);
set(handles.projSlider, 'Max', numProj);
set(handles.projSlider, 'Value', numProj);
set(handles.projSlider, 'SliderStep', [1/numProj , 10/numProj]);
set(handles.dsSlider, 'Min', 1);
set(handles.dsSlider, 'Max', numDs);
set(handles.dsSlider, 'Value', numDs);
set(handles.dsSlider, 'SliderStep', [1/numDs , 10/numDs]);

%Build the checkboxes for projects and datasets
uiStepY = 1.846;
topPos = 13.077;
for thisProj = 1:numProj
    handles.(['projChk' num2str(thisProj)]) = uicontrol(projPanel, 'Style', 'Checkbox', 'String', projList{thisProj,1}, 'Units', 'characters', 'Position', [2.6, topPos, 38, 1.846], 'Callback', {@checkbox_Callback, handles}, 'TooltipString', projList{thisProj,1});
    if thisProj > 8
        set(handles.(['projChk' num2str(thisProj)]), 'Visible', 'off');
    end
    topPos = topPos - uiStepY;
end

topPos = 13.077;
for thisDs = 1:numDs
    handles.(['dsChk' num2str(thisDs)]) = uicontrol(dsPanel, 'Style', 'Checkbox', 'String', dsList{thisDs,1}, 'Units', 'characters', 'Position', [2.6, topPos, 38, 1.846], 'Callback', {@checkbox_Callback, handles}, 'TooltipString', dsList{thisDs,1});
    if thisDs > 8
        set(handles.(['dsChk' num2str(thisDs)]), 'Visible', 'off');
    end
    topPos = topPos - uiStepY;
end

if numProj > 8
    set(handles.projSlider, 'Enable', 'on');
end
if numDs > 8
    set(handles.dsSlider, 'Enable', 'on');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes attachResults wait for user response (see UIRESUME)
uiwait(handles.attachResults);


% --- Outputs from this function are returned to the command line.
function varargout = attachResults_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on button press in attachBtn.
function attachBtn_Callback(hObject, eventdata, handles)
% hObject    handle to attachBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

numProj = getappdata(handles.attachResults, 'numProj');
numDs = getappdata(handles.attachResults, 'numDs');
fileNames = getappdata(handles.attachResults, 'fileNames');
filePath = getappdata(handles.attachResults, 'filePath');

numFiles = length(fileNames);


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function checkbox_Callback(hObject, callbackdata, handles)

chkCounter = getappdata(handles.attachResults, 'chkCounter');

chkValue = get(hObject, 'Value');

if chkValue == 1
    set(handles.attachBtn, 'Enable', 'on');
    chkCounter = chkCounter + 1;
else
    chkCounter = chkCounter - 1;
end
if chkCounter == 0
    set(handles.attachBtn, 'Enable', 'off');
end

setappdata(handles.attachResults, 'chkCounter', chkCounter);


% --- Executes on slider movement.
function dsSlider_Callback(hObject, eventdata, handles)
% hObject    handle to dsSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

numDs = getappdata(handles.attachResults, 'numDs');
dsList = getappdata(handles.attachResults, 'dsList');
sliderVal = floor(get(handles.dsSlider, 'Value'));
topDs = numDs-sliderVal+1;
bottomDs = topDs + 7;
uiStepY = 1.846;
topPos = 13.077;

for thisDs = 1:numDs
    if thisDs < topDs || thisDs > bottomDs
        set(handles.(['dsChk' num2str(thisDs)]), 'Visible', 'off')
    else
        set(handles.(['dsChk' num2str(thisDs)]), 'position', [2.6, topPos, 38, 1.846], 'Visible', 'on');
        topPos = topPos - uiStepY;
    end
end



% --- Executes during object creation, after setting all properties.
function dsSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dsSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function projSlider_Callback(hObject, eventdata, handles)
% hObject    handle to projSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

numProj = getappdata(handles.attachResults, 'numProj');
projList = getappdata(handles.attachResults, 'projList');
sliderVal = floor(get(handles.projSlider, 'Value'));
topProj = numProj-sliderVal+1;
bottomProj = topProj + 7;
uiStepY = 1.846;
topPos = 13.077;

for thisProj = 1:numProj
    if thisProj < topProj || thisProj > bottomProj
        set(handles.(['projChk' num2str(thisProj)]), 'Visible', 'off')
    else
        set(handles.(['projChk' num2str(thisProj)]), 'position', [2.6, topPos, 38, 1.846], 'Visible', 'on');
        topPos = topPos - uiStepY;
    end
end


% --- Executes during object creation, after setting all properties.
function projSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function projScroll(handles)

numProj = getappdata(handles.attachResults, 'numProj');
projList = getappdata(handles.attachResults, 'projList');
topProj = get(handles.projSlider, 'Value');
bottomProj = topProj + 7;
uiStepY = 1.846;
topPos = 13.077;

for thisProj = 1:numProj
    if thisProj < topProj || thisProj > bottomProj
        set(handles.(['projChk' num2str(thisProj)]), 'Visible', 'off')
    else
        set(handles.(['projChk' num2str(thisProj)]), 'position', [2.6, topPos, 38, 1.846], 'Visible', 'on');
        topPos = topPos - uiStepY;
    end
end
