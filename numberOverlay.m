function planeOut = numberOverlay(planeIn, xCoord, yCoord, numeral)
%Will overlay basic numerals onto a matrix at a specified x,y coordinate.
%These numerals are 12x6 pixels, valued 0 for black, 4095 for white.
%'numeral' in an integer 0 to 9.

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