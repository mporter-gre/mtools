function showme(image)
%Create a new figure window and imshow the image, scaled bewteen 0 and the
%max intensity of the image. If the image is 3D, each plane will be
%displayed in a subplot.
%Do showme(image)

numPlanes = length(image(1,1,:));
if numPlanes == 1
    image = double(image);
    figure;
    imshow(image, [0 ceil(max2(image))]);
else
    rootClasses = sqrt(numPlanes);
    rootStr = num2str(rootClasses);
    [token, remain] = strtok(rootStr, '.');
    if isempty(remain)
        subRows = rootClasses;
        subCols = rootClasses;
    else
        rootRemainder = str2num(remain(2));
        if rootRemainder < 5
            subRows = floor(rootClasses);
            subCols = ceil(rootClasses);
        else
            subRows = ceil(rootClasses);
            subCols = ceil(rootClasses);
        end
    end

    figure;
    for thisPlane = 1:numPlanes;
        subplot(subRows, subCols, thisPlane); imshow(image(:,:,thisPlane), [0 ceil(max2(image(:,:,thisPlane)))]);
    end
end
    
end