function [greenPos redPos greenStartZ] = pixelCountPerZ(greenSegStack, redSegStack, numROIZ)

greenStart = 0;
greenPos = zeros(numROIZ,1);
redPos = zeros(numROIZ,1);
for thisROIZ = 1:numROIZ
    greenThisZLinear = reshape(greenSegStack(:,:,thisROIZ), [], 1);
    greenPos(thisROIZ) = sum(greenThisZLinear);
    if greenStart == 0
        if greenPos(thisROIZ) > 0
            greenStart = 1;
            greenStartZ = thisROIZ;
        end
    end
    redThisZLinear = reshape(redSegStack(:,:,thisROIZ), [], 1);
    redPos(thisROIZ) = sum(redThisZLinear);
end

