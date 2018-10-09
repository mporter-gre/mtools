function varargout = boxItObjectChooser(varargin)
% BOXITOBJECTCHOOSER M-file for boxItObjectChooser.fig
%      BOXITOBJECTCHOOSER, by itself, creates a new BOXITOBJECTCHOOSER or raises the existing
%      singleton*.
%
%      H = BOXITOBJECTCHOOSER returns the handle to a new BOXITOBJECTCHOOSER or the handle to
%      the existing singleton*.
%
%      BOXITOBJECTCHOOSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BOXITOBJECTCHOOSER.M with the given input arguments.
%
%      BOXITOBJECTCHOOSER('Property','Value',...) creates a new BOXITOBJECTCHOOSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before boxItObjectChooser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to boxItObjectChooser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help boxItObjectChooser

% Last Modified by GUIDE v2.5 18-Feb-2010 16:27:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @boxItObjectChooser_OpeningFcn, ...
                   'gui_OutputFcn',  @boxItObjectChooser_OutputFcn, ...
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


% --- Executes just before boxItObjectChooser is made visible.
function boxItObjectChooser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to boxItObjectChooser (see VARARGIN)

% Choose default command line output for boxItObjectChooser
handles.output = hObject;
handles.parentHandles = varargin{1};
displayImage = varargin{2};
handles.parentHandleName = varargin{3};
axes(handles.imageAxes);
imageHandle = imshow(displayImage);
set(imageHandle, 'ButtonDownFcn', {@image_ButtonDownFcn, handles});

setappdata(handles.boxItObjectChooser, 'imageHandle', imageHandle);
setappdata(handles.boxItObjectChooser, 'displayImage', displayImage);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes boxItObjectChooser wait for user response (see UIRESUME)
uiwait(handles.boxItObjectChooser);


% --- Outputs from this function are returned to the command line.
function varargout = boxItObjectChooser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;



function image_ButtonDownFcn(hObject, eventdata, handles)

displayImage = getappdata(handles.boxItObjectChooser, 'displayImage');

currentPoint = get(handles.imageAxes, 'CurrentPoint');
x = round(currentPoint(1));
y = round(currentPoint(3));
objectValue = displayImage(y, x);
if objectValue == 0
    return;
end
setappdata(handles.parentHandles.([handles.parentHandleName]), 'objectValue', objectValue);
close(handles.boxItObjectChooser);