function showmeRawLargeScreenZSections(image)
%Create a new figure window and imshow the image, scaled bewteen 0 and the
%max intensity of the image. If the image is 3D, each plane will be
%displayed in a subplot.
%Do showme(image)

global sectionFigure;

screensize = get(0,'ScreenSize');

numPlanes = length(image(1,1,:));
if numPlanes == 1
    image = double(image);
    sectionFigure = figure('NumberTitle','off','MenuBar','none','Toolbar','none');
    imshow(image, [0 ceil(max2(image))]);
else
    rootClasses = sqrt(numPlanes);
    rootStr = num2str(rootClasses);
    [token, remain] = strtok(rootStr, '.');
    if isempty(remain)
        subRows = rootClasses;
        subCols = rootClasses;
    else
        rootRemainder = str2double(remain(2));
        if rootRemainder < 5
            subRows = floor(rootClasses);
            subCols = ceil(rootClasses);
        else
            subRows = ceil(rootClasses);
            subCols = ceil(rootClasses);
        end
    end

    sectionFigure = figure('Name','Click on your lowest and highest acceptable Z-sections.','NumberTitle','off','MenuBar','none','Position',[35 35 screensize(3)-100 screensize(4)-100]);
    for thisPlane = 1:numPlanes;
        subplot(subRows, subCols, thisPlane); imshow(image(:,:,thisPlane)); title(num2str(thisPlane));
    end
end
set(sectionFigure, 'WindowButtonUpFcn', {@clickSection, sectionFigure});

end