function TssBAnalysisQueue(dsIds)

global session;

uiwait
pixServ = session.getPixelsService;

numDs = length(dsIds);
imageIds = [];
for thisDs = 1:numDs
    imageIds = [imageIds; getImagesFromDataset(session, dsIds(thisDs))];
end

numImages = length(imageIds);
for thisImage = 1:numImages
    imageId = imageIds(thisImage);
    theImage = getImages(session, imageId);
    imageName = char(theImage.getName.getValue.getBytes');
    pixels = theImage.getPrimaryPixels;
    numC = pixeld.getSizeC.getValue;

    for thisC = 1:numC
        pixDesc = pixServ.retrievePixDescription(pixels.getId.getValue);
        ch = pixDesc.getChannel(thisC-1);
        chLog = ch.getLogicalChannel;
        chName = char(chLog.getName.getValue.getBytes');
        if strcmpi(chName, 'FITC')
            greenIdx = thisC;
        end
        if strcmpi(chName, 'TRITC')
            redIdx = thisC;
        end
    end
    
    greenStack = getStack(session, imageId, greenIdx-1, 0);
    redStack = getStack(session, imageId, redIdx-1, 0);
    
    cellProps = TssBRunAnalysis(greenStack, redStack);
    
    cellPropsToXLS(cellProps, imageName);
end
    