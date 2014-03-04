function planeOut = numberOverlay(planeIn, xCoord, yCoord, numeral)
%Will overlay basic numerals onto a matrix at a specified x,y coordinate.
%These numerals are 12x6 pixels, valued 0 for black, 4095 for white.
%'numeral' in an integer 0 to 9.

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

load numerals.mat;
planeOut = planeIn;

if numeral == 0
    for row = 1:12
        for col = 1:6
            planeOut(row+yCoord, col+xCoord) = no0(row, col);
        end
    end
end

if numeral == 1
    for row = 1:12
        for col = 1:6
            planeOut(row+yCoord, col+xCoord) = no1(row, col);
        end
    end
end

if numeral == 2
    for row = 1:12
        for col = 1:6
            planeOut(row+yCoord, col+xCoord) = no2(row, col);
        end
    end
end

if numeral == 3
    for row = 1:12
        for col = 1:6
            planeOut(row+yCoord, col+xCoord) = no3(row, col);
        end
    end
end

if numeral == 4
    for row = 1:12
        for col = 1:6
            planeOut(row+yCoord, col+xCoord) = no4(row, col);
        end
    end
end

if numeral == 5
    for row = 1:12
        for col = 1:6
            planeOut(row+yCoord, col+xCoord) = no5(row, col);
        end
    end
end

if numeral == 6
    for row = 1:12
        for col = 1:6
            planeOut(row+yCoord, col+xCoord) = no6(row, col);
        end
    end
end

if numeral == 7
    for row = 1:12
        for col = 1:6
            planeOut(row+yCoord, col+xCoord) = no7(row, col);
        end
    end
end

if numeral == 8
    for row = 1:12
        for col = 1:6
            planeOut(row+yCoord, col+xCoord) = no8(row, col);
        end
    end
end

if numeral == 9
    for row = 1:12
        for col = 1:6
            planeOut(row+yCoord, col+xCoord) = no9(row, col);
        end
    end
end

end
