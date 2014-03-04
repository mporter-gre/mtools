function showmeRaw(image)
%Create a new figure window and imshow the image, scaled bewteen 0 and the
%max intensity of the image. If the image is 3D, each plane will be
%displayed in a subplot.
%Do showme(image)

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

global sectionFigure;

numPlanes = length(image(1,1,:));
if numPlanes == 1
    image = double(image);
    sectionFigure = figure('NumberTitle','off','MenuBar','none','Toolbar','none');
    imshow(image, [0 ceil(max2(image))]);
else
    rootClasses = sqrt(numPlanes);
    rootStr = num2str(rootClasses);
    [token, remain] = strtok(rootStr, '.');
    if isempty(remain)
        subRows = rootClasses;
        subCols = rootClasses;
    else
        rootRemainder = str2num(remain(2));
        if rootRemainder < 5
            subRows = floor(rootClasses);
            subCols = ceil(rootClasses);
        else
            subRows = ceil(rootClasses);
            subCols = ceil(rootClasses);
        end
    end

    sectionFigure = figure('Name','Click on your lowest and highest acceptable Z-sections.','NumberTitle','off','MenuBar','none');
    for thisPlane = 1:numPlanes;
        subplot(subRows, subCols, thisPlane); imshow(image(:,:,thisPlane)); title(num2str(thisPlane));
    end
end
set(sectionFigure, 'WindowButtonUpFcn', {@clickSection, sectionFigure});
    
end
