function varargout = recordCentreMode(varargin)
% RECORDCENTREMODE M-file for recordCentreMode.fig
%      RECORDCENTREMODE, by itself, creates a new RECORDCENTREMODE or raises the existing
%      singleton*.
%
%      H = RECORDCENTREMODE returns the handle to a new RECORDCENTREMODE or the handle to
%      the existing singleton*.
%
%      RECORDCENTREMODE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RECORDCENTREMODE.M with the given input arguments.
%
%      RECORDCENTREMODE('Property','Value',...) creates a new RECORDCENTREMODE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before recordCentreMode_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to recordCentreMode_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help recordCentreMode

% Last Modified by GUIDE v2.5 12-Feb-2010 11:21:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @recordCentreMode_OpeningFcn, ...
                   'gui_OutputFcn',  @recordCentreMode_OutputFcn, ...
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


% --- Executes just before recordCentreMode is made visible.
function recordCentreMode_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to recordCentreMode (see VARARGIN)

% Choose default command line output for recordCentreMode
handles.output = hObject;
handles.parentHandles = varargin{1};
handles.parentHandleName = varargin{2};
scrsz = get(0,'ScreenSize');
%newPosition = [(scrsz(3)/2) (scrsz(4)/2) 324 200];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes recordCentreMode wait for user response (see UIRESUME)
uiwait(handles.recordCentreMode);


% --- Outputs from this function are returned to the command line.
function varargout = recordCentreMode_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on button press in clickModeButton.
function clickModeButton_Callback(hObject, eventdata, handles)
% hObject    handle to clickModeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.recordCentreMode, 'recordMode', 'clickMode');
close(handles.recordCentreMode);


% --- Executes on button press in playbackModeButton.
function playbackModeButton_Callback(hObject, eventdata, handles)
% hObject    handle to playbackModeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.recordCentreMode, 'recordMode', 'playbackMode');
close(handles.recordCentreMode);


% --- Executes on button press in showHelpButton.
function showHelpButton_Callback(hObject, eventdata, handles)
% hObject    handle to showHelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


figPosition = get(handles.recordCentreMode, 'Position');
figPosition(4) = 200;
set(handles.recordCentreMode, 'Position', figPosition);
clickLabelPos = get(handles.clickModeLabel, 'Position');
playbackLabelPos = get(handles.playbackModeLabel, 'Position');
clickLabelPos(2) = 40;
playbackLabelPos(2) = 40;
set(handles.clickModeLabel, 'Position', clickLabelPos);
set(handles.playbackModeLabel, 'Position', playbackLabelPos);


function closeReqFcn(hObject, eventdata, handles)

recordMode = getappdata(handles.recordCentreMode, 'recordMode');
if isempty(recordMode)
    setappdata(handles.parentHandles.(handles.parentHandleName), 'stopRecording', 1);
else
    setappdata(handles.parentHandles.(handles.parentHandleName), 'recordMode', recordMode);
end
delete(handles.recordCentreMode);


