function varargout = distanceChannelSelector(varargin)
% DISTANCECHANNELSELECTOR M-file for distanceChannelSelector.fig
%      DISTANCECHANNELSELECTOR, by itself, creates a new DISTANCECHANNELSELECTOR or raises the existing
%      singleton*.
%
%      H = DISTANCECHANNELSELECTOR returns the handle to a new DISTANCECHANNELSELECTOR or the handle to
%      the existing singleton*.
%
%      DISTANCECHANNELSELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISTANCECHANNELSELECTOR.M with the given input arguments.
%
%      DISTANCECHANNELSELECTOR('Property','Value',...) creates a new DISTANCECHANNELSELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before distanceChannelSelector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to distanceChannelSelector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help distanceChannelSelector

% Last Modified by GUIDE v2.5 19-Aug-2009 14:33:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @distanceChannelSelector_OpeningFcn, ...
                   'gui_OutputFcn',  @distanceChannelSelector_OutputFcn, ...
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


% --- Executes just before distanceChannelSelector is made visible.
function distanceChannelSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to distanceChannelSelector (see VARARGIN)

% Choose default command line output for distanceChannelSelector
handles.output = hObject;
handles.remember = [];
handles.rememberScope = [];

% Update handles structure
set(handles.channelSelect1, 'String', varargin{1});
set(handles.channelSelect2, 'String', varargin{1});
numChannels = length(varargin{1});
handles.numChannels = numChannels;

% Update handles structure
guidata(hObject, handles);
uiwait;

% UIWAIT makes distanceChannelSelector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = distanceChannelSelector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = get(handles.channelSelect1, 'Value');
varargout{3} = get(handles.channelSelect2, 'Value');
varargout{4} = handles.remember;
varargout{5} = handles.rememberScope;
close(hObject);
drawnow;


% --- Executes on selection change in channelSelect1.
function channelSelect1_Callback(hObject, eventdata, handles)
% hObject    handle to channelSelect1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns channelSelect1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelSelect1


% --- Executes during object creation, after setting all properties.
function channelSelect1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelSelect1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channelSelect2.
function channelSelect2_Callback(hObject, eventdata, handles)
% hObject    handle to channelSelect2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns channelSelect2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelSelect2


% --- Executes during object creation, after setting all properties.
function channelSelect2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelSelect2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rememberCheck.
function rememberCheck_Callback(hObject, eventdata, handles)
% hObject    handle to rememberCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rememberCheck

if get(hObject, 'Value') == 1
    set(handles.rememberConditionRadio, 'Enable', 'on');
    set(handles.rememberAllRadio, 'Enable', 'on');
end
if get(hObject, 'Value') == 0
    set(handles.rememberConditionRadio, 'Enable', 'off');
    set(handles.rememberAllRadio, 'Enable', 'off');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
% hObject    handle to okButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.remember = get(handles.rememberCheck, 'Value');
handles.rememberScope = get(get(handles.rememberPanel, 'SelectedObject'), 'Tag');

guidata(hObject, handles);
uiresume;


