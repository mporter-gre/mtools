function TssBAnalysisQueue(dsIds)

global session;

pixServ = session.getPixelsService;

images = getImages(session, 'dataset', dsIds);

progress = waitbar(0, 'Downloading images');
numImages = length(images);
for thisImage = 1:numImages
    imageId = images(thisImage).getId.getValue;
    theImage = getImages(session, imageId);
    imageName = char(theImage.getName.getValue.getBytes');
    pixels = theImage.getPrimaryPixels;
    numC = pixels.getSizeC.getValue;
    
    for thisC = 1:numC
        pixDesc = pixServ.retrievePixDescription(pixels.getId.getValue);
        ch = pixDesc.getChannel(thisC-1);
        chLog = ch.getLogicalChannel;
        chName = char(chLog.getName.getValue.getBytes');
        if strcmpi(chName, 'FITC')
            greenIdx = thisC-1;
        end
        if strcmpi(chName, 'TRITC')
            redIdx = thisC-1;
        end
    end
    progressFraction = thisImage/numImages;
    waitbar(progressFraction, progress, 'Downloading images');
    greenStack = getStack(session, imageId, greenIdx, 0);
    redStack = getStack(session, imageId, redIdx, 0);
    
    cellProps = TssBRunAnalysis(greenStack, redStack, progress, progressFraction);
    waitbar(progressFraction, progress, 'Saving data');
    cellPropsToXLS(cellProps, imageName);
end

close(progress);