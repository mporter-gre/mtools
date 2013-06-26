function dataOut = sumIntensitiesAreasFromDICSeg(segStack, varargin)
%dataOut = sumIntensitiesAreasFromDICSeg(segStack, intStack1, intStack2...);
%Input a segmentation mask stack (as a labelMatrix) and intensity stacks to
%be returned the area/volume for each object (dataOut(:,1)), summed
%intensities, means and stDevs of each intensity stack (dataOut(:,2:end))

numChannels = length(varargin);
for thisChannel = 1:numChannels
    intStack.(['stack' num2str(thisChannel)]) = varargin{thisChannel};
end

objVals = unique(segStack(segStack>0));
numObj = length(objVals);
dataOut = zeros(numObj, 3*numChannels + 1);

for counter = 1:numObj
    thisObj = objVals(counter);
    intVals = intStack.stack1(segStack == thisObj);
    dataOut(counter, 1) = length(intVals);
    columnCounter = 1;
    for thisChannel = 1:numChannels
        dataOut(counter, columnCounter + 1) = sum(intStack.(['stack' num2str(thisChannel)])(segStack == thisObj));
        dataOut(counter, columnCounter + 2) = mean(intStack.(['stack' num2str(thisChannel)])(segStack == thisObj));
        dataOut(counter, columnCounter + 3) = std(intStack.(['stack' num2str(thisChannel)])(segStack == thisObj));
        columnCounter = columnCounter + 3;
    end
end