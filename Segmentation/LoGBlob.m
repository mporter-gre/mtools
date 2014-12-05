function imgOut = LoGBlob(img, blobSize, sig, minSize, maxSize)

filterWidth = blobSize + 2;
if ~rem(filterWidth,2) %make the filter with an odd number
    filterWidth = filterWidth + 1;
end

%win = fspecial('log', filterWidth, filterWidth/2.1).*-1;
win = fspecial('log', filterWidth, sig).*-1;

convImg = conv2(img, win, 'same');

segImg = seg2D(convImg, 0, 0, minSize);

props = regionprops(segImg, 'Area');

numObj = length(props);
if numObj > 0
    for thisObj = 1:numObj
        thisSize = props(thisObj).Area;
        if thisSize > maxSize
            segImg(segImg==thisObj) = 0;
        end
    end
end

imgOut = imfill(segImg, 'holes');