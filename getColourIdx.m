function chIdx = getColourIdx(session, theImage, colour)

%Get the index of the channel that is colour 'blue', 'green', 'red',
%'farred'
%Example: chIdx = getColourIdx(imageObj, 'green')
%         chIdx = 0

pixServ = session.getPixelsService;
pixels = theImage.getPrimaryPixels;

numC = pixels.getSizeC.getValue;
pixDesc = pixServ.retrievePixDescription(pixels.getId.getValue);

for thisC = 1:numC
    ch = pixDesc.getChannel(thisC-1);
    chLog = ch.getLogicalChannel;
    
    emWave = chLog.getEmissionWave.getValue;
    
    if strcmpi(colour, 'blue')  
        if (300 < emWave) && (emWave < 460)
            chIdx = thisC-1;
            return;
        end
    end
    if strcmpi(colour, 'green') 
        if (460 < emWave) && (emWave < 570)
            chIdx = thisC-1;
            return;
        end
    end
    if strcmpi(colour, 'red') 
        if (570 < emWave) && (emWave < 640)
            chIdx = thisC-1;
            return;
        end
    end
    if strcmpi(colour, 'farred') 
        if emWave > 640
            chIdx = thisC-1;
            return;
        end
    end
end