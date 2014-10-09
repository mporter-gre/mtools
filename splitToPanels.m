function panels = splitToPanels(session, imageId, panelSizeX, panelSizeY, panelZRange, panelTRange)
%Create a series of panels, to fit into sizeX and sizeY etc. from a large
%image

theImage = getImages(session, imageId);
pixels = theImage.getPrimaryPixels;

panelNumZ = length(panelZRange);
panelNumT = length(panelZRange);

sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
numZ = pixels.getSizeZ.getValue;
numC = pixels.getSizeC.getValue;
numT = pixels.getSizeT.getValue;
%tInc = pixels.getTimeIncrement;

if panelSizeX > sizeX
    panelSizeX = sizeX;
end
if panelSizeY > sizeY
    panelSizeY = sizeY;
end
if panelNumZ > numZ
    panelNumZ = numZ;
end

if panelNumT > numT
    panelNumT = numT;
end

x = 1;
y = 1;
numPanelsX = floor(sizeX / panelSizeX);
numPanelsY = floor(sizeY / panelSizeY);
counter = 1;
for thisPanelY = 1:numPanelsY
    x = 1;
    for thisPanelX = 1:numPanelsX
        for thisPanelC = 1:numC
            for thisPanelZ = 1:panelNumZ
                for thisPanelT = 1:panelNumT
                    %tile = getTile(session, imageID, z, c, t, x, y, w, h);
                    panels{counter}{thisPanelC}(:,:,thisPanelZ,thisPanelT) = getTile(session, imageId, panelZRange(thisPanelZ)-1, thisPanelC-1, panelTRange(thisPanelT)-1, x, y, panelSizeX, panelSizeY);
                end
            end
        end
        counter = counter + 1;
        x = x + panelSizeX-1;
    end
    y = y + panelSizeY-1;
end











