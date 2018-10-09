function varargout = lineSelector(varargin)
%LINESELECT M-file for lineSelect.fig
%      LINESELECT, by itself, creates a new LINESELECT or raises the existing
%      singleton*.
%
%      H = LINESELECT returns the handle to a new LINESELECT or the handle to
%      the existing singleton*.
%
%      LINESELECT('Property','Value',...) creates a new LINESELECT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to lineSelect_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      LINESELECT('CALLBACK') and LINESELECT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in LINESELECT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lineSelect

% Last Modified by GUIDE v2.5 19-Oct-2009 13:52:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lineSelect_OpeningFcn, ...
                   'gui_OutputFcn',  @lineSelect_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before lineSelect is made visible.
function lineSelect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for lineSelect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lineSelect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lineSelect_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in linesList.
function linesList_Callback(hObject, eventdata, handles)
% hObject    handle to linesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns linesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from linesList


% --- Executes during object creation, after setting all properties.
function linesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in refList.
function refList_Callback(hObject, eventdata, handles)
% hObject    handle to refList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns refList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from refList


% --- Executes during object creation, after setting all properties.
function refList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


