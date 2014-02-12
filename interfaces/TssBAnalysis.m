function varargout = TssBAnalysis(varargin)
% TSSBANALYSIS MATLAB code for TssBAnalysis.fig
%      TSSBANALYSIS, by itself, creates a new TSSBANALYSIS or raises the existing
%      singleton*.
%
%      H = TSSBANALYSIS returns the handle to a new TSSBANALYSIS or the handle to
%      the existing singleton*.
%
%      TSSBANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TSSBANALYSIS.M with the given input arguments.
%
%      TSSBANALYSIS('Property','Value',...) creates a new TSSBANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TssBAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TssBAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TssBAnalysis

% Last Modified by GUIDE v2.5 12-Feb-2014 22:32:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TssBAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @TssBAnalysis_OutputFcn, ...
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


% --- Executes just before TssBAnalysis is made visible.
function TssBAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TssBAnalysis (see VARARGIN)

% Choose default command line output for TssBAnalysis
handles.output = hObject;
password = '';
setappdata(hObject,'passData',password);
set(handles.passText, 'KeyPressFcn', {@passKeyPress, handles});

setappdata(handles.TssBAnalysis, 'selectedDsIds', []);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TssBAnalysis wait for user response (see UIRESUME)
% uiwait(handles.TssBAnalysis);


% --- Outputs from this function are returned to the command line.
function varargout = TssBAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function usernameText_Callback(hObject, eventdata, handles)
% hObject    handle to usernameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of usernameText as text
%        str2double(get(hObject,'String')) returns contents of usernameText as a double


% --- Executes during object creation, after setting all properties.
function usernameText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to usernameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function passText_Callback(hObject, eventdata, handles)
% hObject    handle to passText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of passText as text
%        str2double(get(hObject,'String')) returns contents of passText as a double


% --- Executes during object creation, after setting all properties.
function passText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to passText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loginBtn.
function loginBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loginBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'enable', 'off');
success = logIn(handles);
if success == 0
    set(hObject, 'enable', 'on');
    return;
end

set(handles.chooseDatasetsBtn, 'enable', 'on');



% --- Executes on button press in chooseDatasetsBtn.
function chooseDatasetsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to chooseDatasetsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datasetChooser(handles, 'TssBAnalysis');
dsIds = getappdata(handles.TssBAnalysis, 'selectedDsIds');
if ~isempty(dsIds)
    set(handles.analyseBtn, 'enable', 'on');
end


% --- Executes on button press in analyseBtn.
function analyseBtn_Callback(hObject, eventdata, handles)
% hObject    handle to analyseBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.TssBAnalysis, 'visible', 'off');
dsIds = getappdata(handles.TssBAnalysis, 'selectedDsIds');
TssBAnalysisQueue(dsIds);
set(handles.TssBAnalysis, 'visible', 'off');


function passKeyPress(hObject, eventdata, handles)

lastChar = eventdata.Character;
lastKey = eventdata.Key;
currPass = getappdata(handles.TssBAnalysis, 'passData');
charset = char(33:126);
if lastChar
    if any(charset == lastChar)
        password = [currPass lastChar];
    elseif strcmp(lastKey, 'backspace')
        password = currPass(1:end-1);
    elseif strcmp(lastKey, 'delete')
        password = '';
    else
        return;
    end

    setappdata(handles.TssBAnalysis, 'passData', password);
    numChars = length(password);
    stars(1:numChars) = '*';
    set(hObject, 'String', stars);
end



function success = logIn(handles)

global client;
global session;

credentials{1} = get(handles.usernameText, 'String');
credentials{2} = getappdata(handles.TssBAnalysis, 'passData');
credentials{3} = 'nightshade.openmicroscopy.org.uk';
credentials{4} = '4064';
setappdata(handles.TssBAnalysis, 'credentials', credentials);
if isempty(credentials{1}) || isempty(credentials{2}) || isempty(credentials{3}) || isempty(credentials{4})
    helpdlg('Check you have entered a Username and Password.');
    success = false;
    return;
end

%First check the login works. Client, session and gateway are global, so
%will persist and be kept alive until application close.
try
    if ~isjava(client)
        userLoginOmero(credentials{1}, credentials{2}, credentials{3}, credentials{4});
        success = true;
        selectUserDefaultGroup(credentials{1}, handles, 'TssbAnalysis');
    else
        experimenter = char(session.getAdminService.getExperimenter(0).getOmeName.getValue.getBytes)';
        if strcmp(experimenter, credentials{1})
            success = true;
        else
            userLogoutOmero;
            success = logIn(handles);
        end
    end
%     uiwait(groupSelection);
catch ME
    clear global client;
    clear global session;
    disp(ME.message);
    warndlg('Could not log on to the server. Check your details and try again.');
    success = false;
    return;
end
