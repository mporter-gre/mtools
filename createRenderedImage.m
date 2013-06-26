function renderedImage = createRenderedImage(fullImage, pixels)
%Do renderedImage = createRenderedImage(fullImage, pixels)
%
%Author Michael Porter
%Copyright 2009 University of Dundee. All rights reserved

global session;
%[client session gateway] = gatewayConnect(credentials{1}, credentials{2}, credentials{3});

if strcmp(class(pixels), 'java.util.ArrayList');
    pixels = pixels.get(0);
end
fullImage = double(fullImage);
%maxVal = maxOfType(pixels);
pixelsId = pixels.getId.getValue;
numChannels = pixels.getSizeC.getValue;
sizeX = pixels.getSizeX.getValue;
sizeY = pixels.getSizeY.getValue;
renderingService = session.getRenderingSettingsService;
renderingSettings = renderingService.getRenderingSettings(pixelsId);
renderingModel = renderingSettings.getModel.getValue.getValue;
fullImageScaled = zeros(sizeY, sizeX, numChannels);
pixelsDescription = session.getPixelsService.retrievePixDescription(pixelsId);

for thisChannel = 1:numChannels
    channelBinding = renderingSettings.getChannelBinding(thisChannel-1);
    redVal(thisChannel) = channelBinding.getRed.getValue;
    greenVal(thisChannel) = channelBinding.getGreen.getValue;
    blueVal(thisChannel) = channelBinding.getBlue.getValue;
    active(thisChannel) = channelBinding.getActive.getValue;
    startVal = channelBinding.getInputStart.getValue;
    endVal = channelBinding.getInputEnd.getValue;
    globalMax = pixelsDescription.getChannel(thisChannel-1).getStatsInfo.getGlobalMax.getValue;
    globalMaxScaled = endVal/globalMax;
    startValScaled = startVal/globalMax;
    if globalMaxScaled > 1
        globalMaxScaled = 1;
        startValScaled = 0.5;
    end
    fullImage(:,:,thisChannel) = fullImage(:,:,thisChannel)./globalMax;
    fullImageScaled(:,:,thisChannel) = imadjust(fullImage(:,:,thisChannel), [startValScaled globalMaxScaled], []);
end

[blah activeIdx] = find(active);
numActiveChannels = length(activeIdx);
renderedImage = zeros(sizeY, sizeX, 3);

if strcmp(renderingModel, 'greyscale')
    if redVal(activeIdx) > 0
        greyLevel = redVal(activeIdx);
    elseif greenVal(activeIdx) > 0
        greyLevel = greenVal(activeIdx);
    elseif blueVal(activeIdx) > 0
        greyLevel = blueVal(activeIdx);
    end
    for thisRGB = 1:3
        renderedImage(:,:,thisRGB) = fullImageScaled(:,:,activeIdx).*greyLevel/255;
    end
else
    for thisActiveChannel = 1:numActiveChannels
        if redVal(activeIdx(thisActiveChannel)) ~= 0
            thisRedImage = fullImageScaled(:,:,activeIdx(thisActiveChannel)).*(redVal(activeIdx(thisActiveChannel))/255);
            renderedImage(:,:,1) = renderedImage(:,:,1) + thisRedImage;
        end
        if greenVal(activeIdx(thisActiveChannel)) ~= 0
            thisGreenImage = fullImageScaled(:,:,activeIdx(thisActiveChannel)).*(greenVal(activeIdx(thisActiveChannel))/255);
            renderedImage(:,:,2) = renderedImage(:,:,2) + thisGreenImage;
        end
        if blueVal(activeIdx(thisActiveChannel)) ~= 0
            thisBlueImage = fullImageScaled(:,:,activeIdx(thisActiveChannel)).*(blueVal(activeIdx(thisActiveChannel))/255);
            renderedImage(:,:,3) = renderedImage(:,:,3) + thisBlueImage;
        end
    end
end


renderedImage = double(renderedImage);
disp('');