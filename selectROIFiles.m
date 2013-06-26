function selectROIFiles

infobox = helpdlg('You are going to be asked for your username and password for Nightshade, for some information about your experimental conditions and to select the ROI files for each condition you have. Cropped movies of your event will be saved in the dataset of the original movies, and after processing has completed you will be asked where to save the results spreadsheet.', 'Information');
uiwait(infobox);
username = inputdlg('What is your Nightsahde Username?');
password = inputdlg('What is your Nightshade Password?');
username = username{1};
password = password{1};
numConditions = inputdlg('How many experimental conditions do you have? For example "control" and "drug1" would be 2.', 'Number of conditions');
numConditions = str2double(numConditions);
dataOut = {'Original Movie', 'Cropped Movie' 'Condition', 'Time For Event';};
for thisCondition = 1:numConditions
    conditionName{thisCondition} = inputdlg(['Give condition ', num2str(thisCondition), ' a name...']);
    [files{thisCondition}, paths{thisCondition}] = uigetfile('*.xml', 'Choose your ROI files condition', 'MultiSelect', 'on');
end

for thisCondition = 1:numConditions
    if iscell(files{thisCondition})
        numFiles{thisCondition} = length(files{thisCondition});
        for thisFile = 1:numFiles{thisCondition}
            [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile}] = eventTimerAndCrop(paths{thisCondition}, files{thisCondition}{thisFile}, username, password, thisFile, numFiles{thisCondition}, thisCondition, numConditions);
            numROI = length(ROIIdx{thisCondition}{thisFile});
            for thisROI = 1:numROI
                dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{thisROI}.origName roishapeIdx{thisCondition}{thisFile}{thisROI}.name conditionName{thisCondition}{1} roishapeIdx{thisCondition}{thisFile}{thisROI}.deltaT}];
            end
        end
    else
        thisFile = 1;
        numFiles = 1;
        [ROIIdx{thisCondition}{thisFile} roishapeIdx{thisCondition}{thisFile}] = eventTimerAndCrop(paths{thisCondition}, files{thisCondition}, username, password, thisFile, numFiles, thisCondition, numConditions);
        numROI = length(ROIIdx{thisCondition}{thisFile});
        for thisROI = 1:numROI
            dataOut = [dataOut; {roishapeIdx{thisCondition}{thisFile}{thisROI}.origName roishapeIdx{thisCondition}{thisFile}{thisROI}.name conditionName{thisCondition}{1} roishapeIdx{thisCondition}{thisFile}{thisROI}.deltaT}];
        end
    end
end

[saveFile savePath] = uiputfile('*.xls','Save Results','EventTimeResults.xls');
xlswrite([savePath saveFile], dataOut);

end