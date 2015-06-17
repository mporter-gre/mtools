function showmeMesh(image, matchIntRange)
%Create a new figure window and mesh the image. If the image is 3D, each 
%plane will be displayed in a subplot.
%Do showmeMesh(image, matchIntRange)

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

numPlanes = length(image(1,1,:));
if numPlanes == 1
    image = double(image);
    figure;
    if islogical(image)
        imshow(image, [0 1]);
    else
        mesh(image);
    end
else
    maxInt = max(max2(image));
    minInt = min(min2(image));
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

    figure;
    
    if islogical(image)
        for thisPlane = 1:numPlanes;
            subplot(subRows, subCols, thisPlane); imshow(image(:,:,thisPlane), [0 1]);
        end
    else
        for thisPlane = 1:numPlanes;
            subplot(subRows, subCols, thisPlane); mesh(image(:,:,thisPlane));
            if matchIntRange
                zlim([minInt maxInt]);
            end
        end
    end
end
    
end
