function threshold = getSigmaThreshold(patches, sigmaMultiplier)

linearPatch = reshape(patches, 1, []);
patchMean = mean(linearPatch);
patchStDev = std(linearPatch);
threshold = patchMean - (sigmaMultiplier * patchStDev);