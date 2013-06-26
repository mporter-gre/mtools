function affineMatrix = parseAffineMatrix(transform)

closeBracket = strfind(transform, ')');
openBracket = strfind(transform, '(');
transformData = transform(openBracket+1:closeBracket-1);
spaceChars = strfind(transformData, ' ');
firstPart = str2double(transformData(1:spaceChars(1)-1));
secondPart = str2double(transformData(spaceChars(1)+1:spaceChars(2)-1));
thirdPart = str2double(transformData(spaceChars(2)+1:spaceChars(3)-1));
fourthPart = str2double(transformData(spaceChars(3)+1:spaceChars(4)-1));
fifthPart = str2double(transformData(spaceChars(4)+1:spaceChars(5)-1));
sixthPart = str2double(transformData(spaceChars(5)+1:end));

affineMatrix = [firstPart thirdPart fifthPart; secondPart fourthPart sixthPart; 0 0 1];