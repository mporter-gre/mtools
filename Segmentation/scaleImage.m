function [imageOut, imgMin] = scaleImage(imageIn)

imgMin = min2(imageIn);
imgMax = max2(imageIn);
imageOut = imageIn;
fig = figure('Position',[400,200,670,370]);

imgWindow = axes('Units', 'Pixels', 'Position', [20, 60, 256, 256]);
scaleSlider = uicontrol('Style', 'Slider', 'Units', 'Pixels', 'Position', [20, 30, 256, 15], 'Callback', {@sliderMove, imageOut, imgMax, fig});

imagesc(imageIn, [imgMin imgMax]), colormap('gray'), axis('off');
segWindow = axes('Units', 'Pixels', 'Position', [380, 60, 256, 256]);
axis('off')
segBtn = uicontrol('Style', 'pushbutton', 'Units', 'Pixels', 'String', 'Test ->', 'Position', [288, 170, 80, 30], 'Callback', {@segImage, imgMin, imgMax, scaleSlider});


end


function [imageOut, imgMin] = sliderMove(hObject, eventdata, imageOut, imgMax, imgWindow, fig)

imgMin = get(hObject, 'Value')*imgMax;
imgWindow = axes('Units', 'Pixels', 'Position', [20, 60, 256, 256]);
imagesc(imageOut, [imgMin imgMax]), colormap('gray'), axis('off');
imageOut(find(imageOut<imgMin)) = 0;
setappdata(hObject,'outputImage',imageOut);

end



function segImage(hObject, eventdata, imgMin, imgMax, scaleSlider)

imageOut = getappdata(scaleSlider, 'outputImage');
imgMedFilt = medfilt2(imageOut);
imgEdged = getImageEdges(imgMedFilt, 15);
imgFilled = imfill(imgEdged, 'holes');

imgBwl = bwlabel(imgFilled);
imgProps = regionprops(imgBwl, 'BoundingBox', 'Area');
[imgWidth, imgHeight] = size(imageOut);
for thisCell = 1:length(imgProps)
    xStart = imgProps(thisCell).BoundingBox(1);
    yStart = imgProps(thisCell).BoundingBox(2);
    xEnd = xStart + imgProps(thisCell).BoundingBox(3);
    yEnd = yStart + imgProps(thisCell).BoundingBox(4);

    if xStart <= 1 || yStart <= 1 || xEnd >= imgWidth || yEnd >= imgHeight
        imgBwl(find(imgBwl==thisCell)) = 0;
    end
end

%reset the counter of the bwlabel image
imgBwl = bwlabel(imgBwl);

segWindow = axes('Units', 'Pixels', 'Position', [380, 60, 256, 256]);
imagesc(imgBwl);
axis('off');


end