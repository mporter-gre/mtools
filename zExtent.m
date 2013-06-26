function [signalStart extent] = zExtent(segStack, pixels)

% if isjava(pixels)
%     pixels = pixels.get(0);
% end

[numY numX numZ] = size(segStack);
%numX = pixels.getSizeX.getValue;
%numY = pixels.getSizeY.getValue;

extent = zeros(numY, numX);
signalStart = zeros(numY, numX);
for thisX = 1:numX
    for thisY = 1:numY
        stopState = 0;
        for thisZ = 1:numZ
            if segStack(thisY, thisX, thisZ) == 1
                if stopState == 0
                    signalStart(thisY, thisX) = thisZ;
                end
                stopState = 1;
            end
            if segStack(thisY, thisX, thisZ) == 0 && stopState == 1
                extent(thisY, thisX) = thisZ-1;
                break;
            end
            if thisZ == numZ && stopState == 1 && extent(thisY, thisX) > 0
                extent(thisY, thisX) = thisZ;
            end
        end
    end
end