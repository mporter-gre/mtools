function manualCSV(data, filePath, fileName)
%Matlab csvwrite doesn't handle strings, so if you need to have strings in
%your csv do manualCSV(data, filePath, fileName). 

%Ensure the .csv extension.
[fileName remain] = strtok(fileName, '.');
filePathName = [filePath fileName '.csv'];

%Make sure the data are all strings.
[rows cols] = size(data);
for thisRow = 1:rows
    for thisCol = 1:cols
        if isnumeric(data{thisRow, thisCol})
            data{thisRow, thisCol} = num2str(data{thisRow, thisCol});
        end
    end
end

%Write out data to file
fid = fopen(filePathName, 'w');
for thisRow = 1:rows
    for thisCol = 1:cols
        fprintf(fid, '%s', data{thisRow, thisCol});
        fprintf(fid, '%s', ',');
    end
    fprintf(fid, '%s\n', '');
end
fclose(fid);
