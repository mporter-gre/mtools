function varargout = bacTrackerMenu(varargin)
% BACTRACKERMENU M-file for bacTrackerMenu.fig
%      BACTRACKERMENU, by itself, creates a new BACTRACKERMENU or raises the existing
%      singleton*.
%
%      H = BACTRACKERMENU returns the handle to a new BACTRACKERMENU or the handle to
%      the existing singleton*.
%
%      BACTRACKERMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACTRACKERMENU.M with the given input arguments.
%
%      BACTRACKERMENU('Property','Value',...) creates a new BACTRACKERMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bacTrackerMenu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bacTrackerMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bacTrackerMenu

% Last Modified by GUIDE v2.5 23-Aug-2010 09:58:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bacTrackerMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @bacTrackerMenu_OutputFcn, ...
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


% --- Executes just before bacTrackerMenu is made visible.
function bacTrackerMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bacTrackerMenu (see VARARGIN)

% Choose default command line output for bacTrackerMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bacTrackerMenu wait for user response (see UIRESUME)
% uiwait(handles.bacTrackerMenu);


% --- Outputs from this function are returned to the command line.
function varargout = bacTrackerMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in addDatasetsButton.
function addDatasetsButton_Callback(hObject, eventdata, handles)
% hObject    handle to addDatasetsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datasetChooser(handles, 'bacTrackerMenu')
getappdata(handles.bacTrackerMenu, 'selectedDsNames')
getappdata(handles.bacTrackerMenu, 'selectedDsIds')

bacTrackerParameters(handles, 'bacTrackerMenu');
disp('pause place')


% --- Executes when user attempts to close bacTrackerMenu.
function bacTrackerMenu_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to labelMaker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

%gatewayDisconnect;
delete(hObject);