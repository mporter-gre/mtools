function varargout = defineLabel(varargin)
% DEFINELABEL M-file for defineLabel.fig
%      DEFINELABEL, by itself, creates a new DEFINELABEL or raises the existing
%      singleton*.
%
%      H = DEFINELABEL returns the handle to a new DEFINELABEL or the handle to
%      the existing singleton*.
%
%      DEFINELABEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEFINELABEL.M with the given input arguments.
%
%      DEFINELABEL('Property','Value',...) creates a new DEFINELABEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before defineLabel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to defineLabel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help defineLabel

% Last Modified by GUIDE v2.5 02-Feb-2010 10:24:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @defineLabel_OpeningFcn, ...
                   'gui_OutputFcn',  @defineLabel_OutputFcn, ...
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


% --- Executes just before defineLabel is made visible.
function defineLabel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to defineLabel (see VARARGIN)

% Choose default command line output for defineLabel
handles.output = hObject;
handles.parentHandles = varargin{1};
colourString = {'Blue', 'Cyan', 'Green', 'Black', 'Magenta', 'Red', 'Yellow'};
set(handles.colourSelect, 'String', colourString);
setappdata(handles.defineLabel, 'colourText', 'Blue');
uicontrol(handles.labelText);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes defineLabel wait for user response (see UIRESUME)
uiwait(handles.defineLabel);


% --- Outputs from this function are returned to the command line.
function varargout = defineLabel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

%varargout{1} = handles.output;



function labelText_Callback(hObject, eventdata, handles)
% hObject    handle to labelText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of labelText as text
%        str2double(get(hObject,'String')) returns contents of labelText as a double




% --- Executes during object creation, after setting all properties.
function labelText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labelText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in colourSelect.
function colourSelect_Callback(hObject, eventdata, handles)
% hObject    handle to colourSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns colourSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colourSelect



% --- Executes during object creation, after setting all properties.
function colourSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colourSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okButton.
function okButton_Callback(hObject, eventdata, handles)
% hObject    handle to okButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colourSelectString = get(handles.colourSelect, 'String');
colourSelectValue = get(handles.colourSelect, 'Value');
setappdata(handles.parentHandles.labelMaker, 'newLabelText', get(handles.labelText, 'String'));
setappdata(handles.parentHandles.labelMaker, 'newLabelColour', colourSelectString{colourSelectValue});
delete(handles.defineLabel);


% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.defineLabel);


function defineLabelCloseReq(hObject, eventdata, handles)

setappdata(handles.parentHandles.labelMaker, 'newLabelText', '');
delete(handles.defineLabel);
