function varargout = loginLabelMaker(varargin)
% LOGINLABELMAKER M-file for loginLabelMaker.fig
%      LOGINLABELMAKER, by itself, creates a new LOGINLABELMAKER or raises the existing
%      singleton*.
%
%      H = LOGINLABELMAKER returns the handle to a new LOGINLABELMAKER or the handle to
%      the existing singleton*.
%
%      LOGINLABELMAKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOGINLABELMAKER.M with the given input arguments.
%
%      LOGINLABELMAKER('Property','Value',...) creates a new LOGINLABELMAKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before loginLabelMaker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to loginLabelMaker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help loginLabelMaker

% Last Modified by GUIDE v2.5 18-Feb-2010 11:32:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @loginLabelMaker_OpeningFcn, ...
                   'gui_OutputFcn',  @loginLabelMaker_OutputFcn, ...
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


% --- Executes just before loginLabelMaker is made visible.
function loginLabelMaker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to loginLabelMaker (see VARARGIN)

% Choose default command line output for loginLabelMaker
handles.output = hObject;

set(handles.passText, 'KeyPressFcn', {@passKeyPress, handles});
setappdata(handles.loginBoxIt, 'passData', []);
checkLoginHistory(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes loginLabelMaker wait for user response (see UIRESUME)
% uiwait(handles.loginLabelMaker);


% --- Outputs from this function are returned to the command line.
function varargout = loginLabelMaker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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



function userText_Callback(hObject, eventdata, handles)
% hObject    handle to userText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of userText as text
%        str2double(get(hObject,'String')) returns contents of userText as a double


% --- Executes during object creation, after setting all properties.
function userText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to userText (see GCBO)
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


% --- Executes on button press in loginButton.
function loginButton_Callback(hObject, eventdata, handles)
% hObject    handle to loginButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

server = get(handles.serverText, 'String');
username = get(handles.userText, 'String');
password = getappdata(handles.loginBoxIt, 'passData');
set(hObject, 'Enable', 'off');
try
    gatewayConnect(username, password, server, '4064');
catch
    errordlg([{'There was a problem logging in.'} {'Check your details and try again'}], 'Login failed', 'modal');
    set(hObject, 'Enable', 'on');
    return;
end
saveHistory(username, server)
labelMaker(username, server);
close(handles.loginBoxIt);



    
function passKeyPress(hObject, eventdata, handles)

lastChar = eventdata.Character;
lastKey = eventdata.Key;
currPass = getappdata(handles.loginBoxIt, 'passData');
charset = char(33:126);
nativeLastChar = unicode2native(lastChar);
if nativeLastChar == 13
    loginButton_Callback(hObject, eventdata, handles);
elseif lastChar
    if any(charset == lastChar)
        password = [currPass lastChar];
    elseif strcmp(lastKey, 'backspace')
        password = currPass(1:end-1);
    elseif strcmp(lastKey, 'delete')
        password = '';
    else
        return;
    end

    setappdata(handles.loginBoxIt, 'passData', password);
    numChars = length(password);
    stars(1:numChars) = '*';
    set(hObject, 'String', stars);
end



function checkLoginHistory(handles)

if ispc
    sysUser = getenv('username');
    sysUserHome = getenv('userprofile');
    historyFile = [sysUserHome '\omero\analysisHistory.mat'];
    try
        history = open(historyFile);
        set(handles.userText, 'String', history.omeroUser);
        set(handles.serverText, 'String', history.omeroServer);
        uicontrol(handles.passText);
    catch
    end
end


function saveHistory(omeroUser, omeroServer)

if ispc
    sysUserHome = getenv('userprofile');
    sysUser = getenv('username');
    omeroDir = [sysUserHome '\omero'];
    historyFile = [sysUserHome '\omero\analysisHistory.mat'];
    if ~isdir(omeroDir)
        mkdir(omeroDir)
    end
    save(historyFile, 'omeroUser', 'omeroServer');

end