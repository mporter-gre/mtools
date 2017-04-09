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

% Last Modified by GUIDE v2.5 25-Mar-2016 14:48:19

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
global session
handles.output = hObject;

dsList = varargin{1};
fileNames = varargin{2};
filePath = varargin{3};
projList = getProjectIdsFromDatasetIds(dsList);
numProjRtnd = size(projList,1);
possIdx = 1:numProjRtnd;
[~, idx] = unique([projList{:,1}], 'stable');
idxDel = setdiff(possIdx, idx);
projList(idxDel,:) = [];
numProj = size(projList,1);
numDs = length(dsList);
projPanel = handles.projPanel;
dsPanel = handles.dsPanel;
%%%%Change this to work out the projects list from the dsList/Ids

setappdata(handles.attachResults, 'chkCounter', 0);
setappdata(handles.attachResults, 'numProj', numProj);
setappdata(handles.attachResults, 'numDs', numDs);
setappdata(handles.attachResults, 'fileNames', fileNames);
setappdata(handles.attachResults, 'filePath', filePath);
setappdata(handles.attachResults, 'projList', projList);
setappdata(handles.attachResults, 'dsList', dsList);
setappdata(handles.attachResults, 'allowClose', 0);

if numProj > 8
    set(handles.projSlider, 'Min', 1);
    set(handles.projSlider, 'Max', numProj);
    set(handles.projSlider, 'Value', numProj);
    set(handles.projSlider, 'SliderStep', [1/numProj , 10/numProj]);
end
if numDs > 8
    set(handles.dsSlider, 'Min', 1);
    set(handles.dsSlider, 'Max', numDs);
    set(handles.dsSlider, 'Value', numDs);
    set(handles.dsSlider, 'SliderStep', [1/numDs , 10/numDs]);
end

%Build the checkboxes for projects and datasets
uiStepY = 1.846;
topPos = 13.077;
for thisProj = 1:numProj
    handles.(['projChk' num2str(thisProj)]) = uicontrol(projPanel, 'Style', 'Checkbox', 'String', projList{thisProj,2}, 'Units', 'characters', 'Position', [2.6, topPos, 38, 1.846], 'Callback', {@checkbox_Callback, handles}, 'TooltipString', projList{thisProj,2});
    if thisProj > 8
        set(handles.(['projChk' num2str(thisProj)]), 'Visible', 'off');
    end
    topPos = topPos - uiStepY;
end

topPos = 13.077;
for thisDs = 1:numDs
    thisDsObj = getDatasets(session, dsList(thisDs));
    thisDsName = char(thisDsObj.getName.getValue.getBytes');
    handles.(['dsChk' num2str(thisDs)]) = uicontrol(dsPanel, 'Style', 'Checkbox', 'String', thisDsName, 'Units', 'characters', 'Position', [2.6, topPos, 38, 1.846], 'Callback', {@checkbox_Callback, handles}, 'TooltipString', thisDsName);
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
varargout{1} = 0;


% --- Executes on button press in attachBtn.
function attachBtn_Callback(hObject, eventdata, handles)
% hObject    handle to attachBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global session

set(hObject, 'Enable', 'off');
set(handles.cancelBtn, 'Enable', 'off');
drawnow;
numProj = getappdata(handles.attachResults, 'numProj');
numDs = getappdata(handles.attachResults, 'numDs');
projList = getappdata(handles.attachResults, 'projList');
dsList = getappdata(handles.attachResults, 'dsList');
fileNames = getappdata(handles.attachResults, 'fileNames');
filePath = getappdata(handles.attachResults, 'filePath');
[~, numFiles] = size(fileNames);

for thisFile = 1:numFiles
    if numFiles == 1
        thisFilePath = [filePath fileNames];
    else
        thisFilePath = [filePath fileNames{thisFile}];
    end
    fa = writeFileAnnotation(session, thisFilePath, 'Description', ['Results created with OMERO.mtools on ' date]);
    
    for thisProj = 1:numProj
        val = get(handles.(['projChk' num2str(thisProj)]), 'Value');
        if val == 1
            projId = projList{thisProj, 1};
            link = linkAnnotation(session, fa, 'project', projId);
        end
    end
    for thisDs = 1:numDs
        val = get(handles.(['dsChk' num2str(thisDs)]), 'Value');
        if val == 1
            dsId = dsList(thisDs);
            link = linkAnnotation(session, fa, 'dataset', dsId);
        end
    end
end
set(hObject, 'Enable', 'on');
set(handles.cancelBtn, 'Enable', 'on');
uiwait(msgbox('Results attached.', 'modal'));
setappdata(handles.attachResults, 'allowClose', 1);
attachResults_CloseRequestFcn(hObject, eventdata, handles);
    


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
attachResults_CloseRequestFcn('a','b',handles);


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



% --- Executes when user attempts to close boxIt.
function attachResults_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to attachResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

allowClose = getappdata(handles.attachResults, 'allowClose');

if allowClose == 0
    answer = questdlg([{'Are you sure you do not want to attach'} {'your results to a project or dataset?'}], 'Discard Changes?', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')
        return;
    end
end

uiresume(handles.attachResults);
delete(handles.attachResults);
