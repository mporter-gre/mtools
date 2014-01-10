function minValue = minUnderMask(img, mask)

logicalMaskLinear = reshape(logical(mask), 1, []);
imgLinear = reshape(img, 1, []);
% imgType = class(imgLinear);
% maskLinear = typecast(logicalMaskLinear, imgType);
linearCombined = sort(unique(imgLinear .* double(logicalMaskLinear)));
if max(linearCombined) == 0
    minValue = 0;
else
    minValue = linearCombined(2);
end