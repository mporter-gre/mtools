function varargout = chymographTest(varargin)
% CHYMOGRAPHTEST M-file for chymographTest.fig
%      CHYMOGRAPHTEST, by itself, creates a new CHYMOGRAPHTEST or raises the existing
%      singleton*.
%
%      H = CHYMOGRAPHTEST returns the handle to a new CHYMOGRAPHTEST or the handle to
%      the existing singleton*.
%
%      CHYMOGRAPHTEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHYMOGRAPHTEST.M with the given input arguments.
%
%      CHYMOGRAPHTEST('Property','Value',...) creates a new CHYMOGRAPHTEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before chymographTest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to chymographTest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help chymographTest

% Last Modified by GUIDE v2.5 04-Dec-2009 11:02:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @chymographTest_OpeningFcn, ...
                   'gui_OutputFcn',  @chymographTest_OutputFcn, ...
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


% --- Executes just before chymographTest is made visible.
function chymographTest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to chymographTest (see VARARGIN)

% Choose default command line output for chymographTest
handles.output = hObject;
handles.fullImage = varargin{1};
handles.pixels = varargin{2};
guidata(hObject, handles);
%set(handles.figure1, 'WindowButtonMotionFcn', {@figure1_WindowButtonMotionFcn, handles});
numT = length(handles.fullImage{1});
renderAndDisplay(handles, 1);
% for thisT = 1:100
%     renderAndDisplay(handles, thisT);
%     getPointPerT(handles, thisT)
% end




% Update handles structure
guidata(hObject, handles);

% UIWAIT makes chymographTest wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = chymographTest_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = getappdata(handles.figure1, 'points');


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
rect = getrect(handles.axes1);
line([rect(1) rect(1)+rect(3)], [rect(2) rect(2)], 'color', 'white');
line([rect(1) rect(1)+rect(3)], [rect(2)+rect(4) rect(2)+rect(4)], 'color', 'white');
line([rect(1) rect(1)], [rect(2) rect(2)+rect(4)], 'color', 'white');
line([rect(1)+rect(3) rect(1)+rect(3)], [rect(2)+rect(4) rect(2)], 'color', 'white');


function renderAndDisplay(handles, t)

imageAtT(:,:,1) = handles.fullImage{1}{t};
imageAtT(:,:,2) = handles.fullImage{2}{t};

renderedImage = createRenderedImage(imageAtT, handles.pixels);
axes(handles.axes1)
handles.imageHandle = imshow(renderedImage);
guidata(handles.axes1, handles);
%set(handles.imageHandle, 'ButtonDownFcn', {@image_ButtonDownFcn, handles});
%robot = java.awt.robot;

%pos = get(handles.imageHandle, 'Position');
%set(0, 'PointerLocation', pos(1:2));
%pause(10)
set(0,'units','pix');
screenSize = get(0,'screensize');

% increment = 0;
% for i = 1:10
%     imagePosition(handles, increment)
%     increment = increment + 10;
%     pause(1);
% end


function imagePosition(handles, increment)

% robot = java.awt.Robot;
% robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
% robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
% %[x,y] = ginput(1)
% currentPoint = get(handles.axes1, 'CurrentPoint')
% axes(handles.axes1);
% axesPosition = get(handles.axes1, 'Position')
% windowPosition = get(handles.figure1, 'Position')
% minY = axesPosition(1) + windowPosition(1)
% minX = axesPosition(2) + windowPosition(2)
% maxY = minY + axesPosition(3);
% maxX = minX + axesPosition(4);
% 
% set(0, 'PointerLocation', [minY+increment minX+increment])

function getPointPerT(handles, thisT)

%windowPosition = get(handles.figure1, 'Position');
axesPosition = get(handles.axes1, 'Position');
minX = axesPosition(1);
minY = axesPosition(2);
maxX = minX + axesPosition(3);
maxY = minY + axesPosition(4);

robot = java.awt.Robot;
robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
currentPoint = get(handles.figure1, 'CurrentPoint');

points = getappdata(handles.figure1, 'points');
if currentPoint(1,1) > minX && currentPoint(1,2) > minY && currentPoint(1,1) < maxX && currentPoint(1,2) < maxY
    points(thisT,1) = currentPoint(1,1) - minX;
    points(thisT,2) = currentPoint(1,2) - minY;
end
setappdata(handles.figure1, 'points', points);



%function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)

% windowPosition = get(handles.figure1, 'Position');
% axesPosition = get(handles.axes1, 'Position');
% minX = axesPosition(1);
% minY = axesPosition(2);
% maxX = minX + axesPosition(3);
% maxY = minY + axesPosition(4);
% 
% robot = java.awt.Robot;
% robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
% robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);
% currentPoint = get(handles.figure1, 'CurrentPoint');
% 
% if currentPoint(1,2) > maxY
%     set(0, 'PointerLocation', [(currentPoint(1,1) + windowPosition(1)-1) (maxY + windowPosition(2)-1)]);
% end
% if currentPoint(1,1) > maxX
%     set(0, 'PointerLocation', [(maxX + windowPosition(1)-1) (currentPoint(1,2) + windowPosition(2)-1)]);
% end
