function varargout = bacTrackerLogin(varargin)
% BACTRACKERLOGIN M-file for bacTrackerLogin.fig
%      BACTRACKERLOGIN, by itself, creates a new BACTRACKERLOGIN or raises the existing
%      singleton*.
%
%      H = BACTRACKERLOGIN returns the handle to a new BACTRACKERLOGIN or the handle to
%      the existing singleton*.
%
%      BACTRACKERLOGIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACTRACKERLOGIN.M with the given input arguments.
%
%      BACTRACKERLOGIN('Property','Value',...) creates a new BACTRACKERLOGIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bacTrackerLogin_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bacTrackerLogin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bacTrackerLogin

% Last Modified by GUIDE v2.5 20-Apr-2011 17:26:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bacTrackerLogin_OpeningFcn, ...
                   'gui_OutputFcn',  @bacTrackerLogin_OutputFcn, ...
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


% --- Executes just before bacTrackerLogin is made visible.
function bacTrackerLogin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bacTrackerLogin (see VARARGIN)

% Choose default command line output for bacTrackerLogin
handles.output = hObject;

password = '';
setappdata(hObject,'passData',password);
%Set the key press function of the password box for **** insertion.
handles.conditionsPaths = '';
handles.conditionsFiles = '';
handles.currDir = cd;
set(handles.passwordText, 'KeyPressFcn', {@passKeyPress, handles});
%set(handles.newConditionText, 'KeyPressFcn', {@newConditionTextKeyPress, handles});
uicontrol(handles.usernameText);
checkLoginHistory(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bacTrackerLogin wait for user response (see UIRESUME)
% uiwait(handles.bacTrackerLogin);


% --- Outputs from this function are returned to the command line.
function varargout = bacTrackerLogin_OutputFcn(hObject, eventdata, handles) 
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



function serverText_Callback(hObject, eventdata, handles)
% hObject    handle to serverText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of serverText as text
%        str2double(get(hObject,'String')) returns contents of serverText as a double


% --- Executes during object creation, after setting all properties.
function serverText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to serverText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function portText_Callback(hObject, eventdata, handles)
% hObject    handle to portText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of portText as text
%        str2double(get(hObject,'String')) returns contents of portText as a double


% --- Executes during object creation, after setting all properties.
function portText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to portText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function passwordText_Callback(hObject, eventdata, handles)
% hObject    handle to passwordText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of passwordText as text
%        str2double(get(hObject,'String')) returns contents of passwordText as a double


% --- Executes during object creation, after setting all properties.
function passwordText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to passwordText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bacTrackerButton.
function bacTrackerButton_Callback(hObject, eventdata, handles)
% hObject    handle to bacTrackerButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

success = logIn(handles);

if success == false
    return;
end
bacTrackerMenu(handles)


function checkLoginHistory(handles)

if ispc
    sysUser = getenv('username');
    sysUserHome = getenv('userprofile');
    historyFile = [sysUserHome '\omero\analysisHistory.mat'];
    try
        history = open(historyFile);
        set(handles.usernameText, 'String', history.omeroUser);
        set(handles.serverText, 'String', history.omeroServer);
        try  %previous versions didn't include port details.
            set(handles.serverPort, 'String', history.omeroPort);
        catch
        end
        uicontrol(handles.passwordText);
    catch
    end
end


function passKeyPress(hObject, eventdata, handles)

lastChar = eventdata.Character;
lastKey = eventdata.Key;
currPass = getappdata(handles.bacTrackerLogin, 'passData');
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

    setappdata(handles.bacTrackerLogin, 'passData', password);
    numChars = length(password);
    stars(1:numChars) = '*';
    set(hObject, 'String', stars);
end



function saveHistory(credentials)

omeroUser = credentials{1};
omeroServer = credentials{3};
omeroPort = credentials{4};
if ispc
    sysUserHome = getenv('userprofile');
    sysUser = getenv('username');
    omeroDir = [sysUserHome '\omero'];
    historyFile = [sysUserHome '\omero\analysisHistory.mat'];
    if ~isdir(omeroDir)
        mkdir(omeroDir)
    end
    save(historyFile, 'omeroUser', 'omeroServer', 'omeroPort');
end


function success = logIn(handles)

global client;
global session;
global gateway;
global clientAlive;

credentials{1} = get(handles.usernameText, 'String');
credentials{2} = getappdata(handles.bacTrackerLogin, 'passData');
credentials{3} = get(handles.serverText, 'String');
credentials{4} = get(handles.portText, 'String');
setappdata(handles.bacTrackerLogin, 'credentials', credentials);
if isempty(credentials{1}) || isempty(credentials{2}) || isempty(credentials{3}) || isempty(credentials{4})
    helpdlg('Check you have entered a Username, Password, Server and Port.');
    return;
end

%First check the login works. Client, session and gateway are global, so
%will persist and be kept alive until application close.
try
    if ~isjava(client)
        gatewayConnect(credentials{1}, credentials{2}, credentials{3}, credentials{4});
        saveHistory(credentials);
        success = true;
    else
        experimenter = char(session.getAdminService.getExperimenter(0).getOmeName.getValue.getBytes)';
        if strcmp(experimenter, credentials{1})
            success = true;
        else
            gatewayDisconnect;
            success = logIn(handles);
        end
    end
catch ME
    clear global client;
    clear global session;
    clear global gateway;
    clear global clientAlive;
    disp(ME.message);
    warndlg('Could not log on to the server. Check your details and try again.');
    success = false;
end


% --- Executes when user attempts to close bactrackerlogin.
function bacTrackerLogin_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to labelMaker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

gatewayDisconnect;
delete(hObject);