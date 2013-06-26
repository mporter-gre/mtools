function corr_offset = omxReg(image1, image2)

corrMatrix = normxcorr2(image1,image2);
maxCorrMatrix = max2(corrMatrix);
maxIndex = find(corrMatrix==maxCorrMatrix);
[maxY maxX] = ind2sub(size(corrMatrix), maxIndex);

corr_offset = [(maxX-size(image1,2)) (maxY-size(image1,1))];  %divide each part by 2 maybe??

end