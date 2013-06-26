function minValue = minUnderMask(img, mask)

logicalMaskLinear = reshape(logical(mask), 1, []);
imgLinear = reshape(img, 1, []);
linearCombined = sort(unique(imgLinear .* logicalMaskLinear));
if max(linearCombined) == 0
    minValue = 0;
else
    minValue = linearCombined(2);
end