function varargout = getIntensitiesInROI(imageId, varargin)
%[varargout] = getIntensitiesInROI(imageId, varargin)
%Varargin should be 2/3 dim matrices of intensity data (green channel, red
%channel etc). Every varargin will have a matching varargout. Atm will only
%give data for first ROI in an image (sum, mean and stDev).

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

numChannels = length(varargin);
[imageIdxNoROI roiShapes] = ROIImageCheck(imageId);

if ~isempty(imageIdxNoROI)
    disp(['No ROIs found for image ' num2str(imageId)]);
    return
end

roi = roiShapes{1}{1};

if ~strcmpi(roi.shapeType, 'rect')
    disp('First ROI is not a rectangle');
    return
end

X = round(roi.shape1.getX.getValue);
Y = round(roi.shape1.getY.getValue);
width = roi.shape1.getWidth.getValue;
height = roi.shape1.getHeight.getValue;
[numY numX numZ] = size(varargin{1});
varargout = {};

for thisChannel = 1:numChannels
    for thisZ = 1:numZ
        intensities.(['channel' num2str(thisChannel)])(:,:,thisZ) = reshape(varargin{thisChannel}(Y:Y+height-1, X:X+width-1, thisZ), 1, []);
    end
    intensities.(['channel' num2str(thisChannel)]) = squeeze(reshape(intensities.(['channel' num2str(thisChannel)]), 1, []));
    varargout{thisChannel} = [sum(intensities.(['channel' num2str(thisChannel)])), mean(intensities.(['channel' num2str(thisChannel)])), std(double(intensities.(['channel' num2str(thisChannel)])))];
end
