function varargout = objectViewAndSelect(varargin)
% OBJECTVIEWANDSELECT M-file for objectViewAndSelect.fig
%      OBJECTVIEWANDSELECT, by itself, creates a new OBJECTVIEWANDSELECT or raises the existing
%      singleton*.
%
%      H = OBJECTVIEWANDSELECT returns the handle to a new OBJECTVIEWANDSELECT or the handle to
%      the existing singleton*.
%
%      OBJECTVIEWANDSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OBJECTVIEWANDSELECT.M with the given input arguments.
%
%      OBJECTVIEWANDSELECT('Property','Value',...) creates a new OBJECTVIEWANDSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before objectViewAndSelect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to objectViewAndSelect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help objectViewAndSelect

% Last Modified by GUIDE v2.5 20-Aug-2009 13:33:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @objectViewAndSelect_OpeningFcn, ...
                   'gui_OutputFcn',  @objectViewAndSelect_OutputFcn, ...
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


% --- Executes just before objectViewAndSelect is made visible.
function objectViewAndSelect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to objectViewAndSelect (see VARARGIN)

% Choose default command line output for objectViewAndSelect
handles.output = hObject;
handles.theImage = varargin{1};
numZ = length(handles.theImage(1,1,:));
set(handles.zSlider, 'Max', numZ-1); %Slider will index from 0.
%set(hObject, 'ButtonDownFcn', {@clickFigure, handles});
handles.imageHandle = imshow(handles.theImage(:,:,1));
set(handles.imageHandle, 'ButtonDownFcn', {@clickImage, handles});
% set(handles.imageAxes, 'ButtonDownFcn', {@clickAxes})


% Update handles structure
guidata(hObject, handles);


% UIWAIT makes objectViewAndSelect wait for user response (see UIRESUME)
% uiwait(handles.objectViewer);


% --- Outputs from this function are returned to the command line.
function varargout = objectViewAndSelect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function zSlider_Callback(hObject, eventdata, handles)
% hObject    handle to zSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
zSection = round(get(hObject, 'Value'));
handles.imageHandle = imshow(handles.theImage(:,:,zSection+1));
set(handles.imageHandle, 'ButtonDownFcn', {@clickImage, handles});
guidata(hObject, handles);
%get(handles.imageAxes, 'CurrentPoint')


% --- Executes during object creation, after setting all properties.
function zSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function clickImage(hObject, eventdata, handles)
handles.currentPoint = get(handles.imageAxes, 'CurrentPoint');
Y = round(handles.currentPoint(1));
X = round(handles.currentPoint(4));
Z = round(get(handles.zSlider, 'Value'))+1;
handles.theImage(Y,X,Z)
%intensity = handles.theImage(Y,X,round(get(handles.zSlider, 'Value')))
%handles.selectedObjectValue = handles.imageHandle(Y,X)
guidata(hObject, handles);
