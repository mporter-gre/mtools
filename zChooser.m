function [startZ stopZ] = zChooser(maskStackBWL)
%Show the user the results of segmentation and ask them to specify
%the correct range of Z-sections.

% Copyright (C) 2013-2014 University of Dundee & Open Microscopy Environment.
% All rights reserved.
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

global ROIText;
global sectionFigure;
global fig1;
global sectionClicked;

numZ = length(maskStackBWL(1,1,:));
if numZ > 25
    showmeRawLargeScreenZSections(maskStackBWL);
else
    showmeRaw(maskStackBWL);
end
sectionsChosen = 0;
while sectionsChosen == 0
    set(ROIText, 'String', 'Click on the LOWEST correct Z-Section.');
    figure(sectionFigure);
    drawnow;
    uiwait(sectionFigure);
    startZ = sectionClicked;
    set(ROIText, 'String', 'Click on the Highest correct Z-Section.');
    figure(sectionFigure);
    drawnow;
    uiwait(sectionFigure);
    stopZ = sectionClicked;
    questionStr = ['Lowest Z = ', num2str(startZ), ', highest Z = ', num2str(stopZ), '?'];
    response = questdlg(questionStr, 'Correct Z-Sections?', 'Yes', 'No', 'Yes');
    if strcmp(response, 'Yes')
        sectionsChosen = 1;
    end
end
close(sectionFigure);
