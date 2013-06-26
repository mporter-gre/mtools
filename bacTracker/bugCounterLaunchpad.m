function bugCounterLaunchpad(handles, credentials)

global gateway;

bugCounterMain(handles, credentials);

% numImages = length(imageIdVec);
% header = {'numPix' 'sum green' 'mean green' 'stDev green' 'sum red' 'mean red' 'stDev red' 'sum green - bkg' 'mean green - bkg' 'sum red - bkg' 'mean red - bkg'};
% tic;
% for thisImg = 1:numImages
%     filename = num2str(imageIdVec(thisImg));
%     pixels = gateway.getPixelsFromImage(imageIdVec(thisImg));
%     DICStack = getStackFromPixels(pixels, 0, 0);
%     greenStack = getStackFromPixels(pixels, 1, 0);
%     redStack = getStackFromPixels(pixels, 2, 0);
%     
%     segStack = DICSeg(DICStack, 60);
%     dataOut = sumIntensitiesAreasFromDICSeg(segStack, greenStack, redStack);
%     [greenBkg redBkg] = getIntensitiesInROI(imageIdVec(thisImg), greenStack, redStack);
%     bkgLine = [0 greenBkg redBkg];
%     dataOut = [bkgLine; dataOut];
%     dataOut = subtractBackground(dataOut);
%     createSpreadsheetFromData(dataOut, header, filename);
%     toc
% end

