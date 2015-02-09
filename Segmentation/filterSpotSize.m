function spotMask = filterSpotSize(spotMask, minSize)
%spotMask = filterSpotSize(spotMask, minSize)
%Filter out spots below a minimum size from a mask image.

spotMaskBWL = bwlabeln(spotMask);
props = regionprops(spotMaskBWL, 'Area');

numSpots = length(props);

for thisSpot = 1:numSpots
    if props(thisSpot).Area < minSize
        spotMask(spotMaskBWL==thisSpot) = 0;
    end
end
