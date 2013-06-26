function updatedTransform = updateTransform(transform, transformType, rotate, skew, scale, transX, transY)


if isempty(transform)
    if strcmp(transformType, 'translate')
        updatedTransform = ['matrix(1 0 0 1 ' transX ' ' transY ')'];
    end
    return;
end


if strcmp(transform, 'none') || strncmp(transform, 'translate', 9)
    if strcmp(transformType, 'translate')
        updatedTransform = ['matrix(1 0 0 1 ' transX ' ' transY ')'];
    end
    return;
end


if strncmp(transform, 'matrix', 5)
    closeBracket = findstr(transform, ')');
    openBracket = findstr(transform, '(');
    transformData = transform(openBracket+1:closeBracket-1);
    spaceChars = findstr(transformData, ' ');
    firstPart = transformData(1:spaceChars(1)-1);
    secondPart = transformData(spaceChars(1)+1:spaceChars(2)-1);
    thirdPart = transformData(spaceChars(2)+1:spaceChars(3)-1);
    fourthPart = transformData(spaceChars(3)+1:spaceChars(4)-1);
    fifthPart = transformData(spaceChars(4)+1:spaceChars(5)-1);
    sixthPart = transformData(spaceChars(5)+1:end);
    
    if strcmp(transformType, 'translate')
        %updatedTransform = ['matrix(' firstPart ' ' secondPart ' ' thirdPart ' ' fourthPart ' ' transX ' ' transY ')'];
        %Hack to prevent scaling...
        updatedTransform = ['matrix(1 ' secondPart ' ' thirdPart ' ' fourthPart ' ' transX ' ' transY ')'];
    end
    return;
end







