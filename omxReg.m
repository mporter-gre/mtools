function corr_offset = omxReg(image1, image2)

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

corrMatrix = normxcorr2(image1,image2);
maxCorrMatrix = max2(corrMatrix);
maxIndex = find(corrMatrix==maxCorrMatrix);
[maxY maxX] = ind2sub(size(corrMatrix), maxIndex);

corr_offset = [(maxX-size(image1,2)) (maxY-size(image1,1))];  %divide each part by 2 maybe??

end
