function dataOut = sumIntensitiesAreasFromDICSeg(segStack, varargin)
%dataOut = sumIntensitiesAreasFromDICSeg(segStack, intStack1, intStack2...);
%Input a segmentation mask stack (as a labelMatrix) and intensity stacks to
%be returned the area/volume for each object (dataOut(:,1)), summed
%intensities, means and stDevs of each intensity stack (dataOut(:,2:end))

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
for thisChannel = 1:numChannels
    intStack.(['stack' num2str(thisChannel)]) = varargin{thisChannel};
end

objVals = unique(segStack(segStack>0));
numObj = length(objVals);
dataOut = zeros(numObj, 3*numChannels + 1);

for counter = 1:numObj
    thisObj = objVals(counter);
    intVals = intStack.stack1(segStack == thisObj);
    dataOut(counter, 1) = length(intVals);
    columnCounter = 1;
    for thisChannel = 1:numChannels
        dataOut(counter, columnCounter + 1) = sum(intStack.(['stack' num2str(thisChannel)])(segStack == thisObj));
        dataOut(counter, columnCounter + 2) = mean(intStack.(['stack' num2str(thisChannel)])(segStack == thisObj));
        dataOut(counter, columnCounter + 3) = std(double(intStack.(['stack' num2str(thisChannel)])(segStack == thisObj)));
        columnCounter = columnCounter + 3;
    end
end
