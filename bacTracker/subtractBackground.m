function dataOut = subtractBackground(dataIn)

dataOut = dataIn;
[numRows numCols] = size(dataIn);
numObjects = numRows - 1;
numChannels = floor(numCols/3);
%colour = [{'green'}; {'red'}];
sumCols = [2,5];
meanBkgCols = [3,6];
stDevBkgCols = [4,7];

for thisChannel = 1:numChannels
    %dataOut{1, thisChannel*numChannels+6} = ['Sum ' colour{thisChannel} ' - bkg'];
    %dataOut{1, thisChannel*numChannels+7} = ['Mean ' colour{thisChannel} ' - bkg'];
    meanBkg = dataIn(1, meanBkgCols(thisChannel));
    stDevBkg = dataIn(1, stDevBkgCols(thisChannel));
    bkgThreshold = stDevBkg*2; %If cells are <= mean bkg + 2*std mark them as zero.
    for thisObject = 1:numObjects
        dataOut(thisObject+1, thisChannel*numChannels+6) = dataIn(thisObject+1, sumCols(thisChannel)) - (meanBkg * dataIn(thisObject+1, 1));
        dataOut(thisObject+1, thisChannel*numChannels+7) = dataOut(thisObject+1, thisChannel*numChannels+6) / dataIn(thisObject+1, 1);
        if dataOut(thisObject+1, thisChannel*numChannels+6) <= bkgThreshold
            dataOut(thisObject+1, thisChannel*numChannels+6) = 0;
        end
        if dataOut(thisObject+1, thisChannel*numChannels+7) <= bkgThreshold
            dataOut(thisObject+1, thisChannel*numChannels+7) = 0;
        end
    end
end