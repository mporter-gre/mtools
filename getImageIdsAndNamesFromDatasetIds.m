function [sortedImages imageIds imageNames sortedDatasetNames] = getImageIdsAndNamesFromDatasetIds(datasetIds)

global session

numDs = length(datasetIds);
datasets = getDatasets(session, datasetIds, true);
datasetNames = {};
images = java.util.ArrayList;
for thisDs = 1:numDs
    dsId = datasets(thisDs).getId.getValue;
    
    datasetName = char(datasets(thisDs).getName.getValue.getBytes');
    numImages = datasets(thisDs).sizeOfImageLinks;
    imageIter = datasets(thisDs).iterateImageLinks;
    while imageIter.hasNext
        datasetNames{end+1} = datasetName;
        dsImageLink = imageIter.next;
        images.add(dsImageLink.getChild);
    end
end


%pass in the whole datasetId list and all the images will be returned, no
%need to loop through the datasets for this.


numImages = images.size;
if numImages == 0
    images = [];
    imageIds = [];
    imageNames = [];
    return;
end

%imageNameId{numImages,2} = [];
%imageNames{numImages} = [];

%Put the imageIds and Names into cells to be sorted alphabetically
imageIter = images.iterator;
counter = 1;
while imageIter.hasNext
    imageNameId{counter,1} = char(images.get(counter-1).getName.getValue.getBytes');
    imageNameId{counter,2} = num2str(images.get(counter-1).getId.getValue);
    imageNameId{counter,3} = datasetNames{counter};
    counter = counter + 1;
    imageIter.next;
end
datasetNames = [];
[imageNameId sortIdx] = sortrows(imageNameId,1);

%Move the sorted Ids and Names into vector/cells to be returned.
%imageNameId = sortrows(imageNameId);
sortedImages = java.util.ArrayList;
for thisImage = 1:numImages
    imageNames{thisImage} = imageNameId{thisImage, 1};
    imageIds(thisImage) = str2double(imageNameId{thisImage, 2});
    sortedDatasetNames{thisImage} = imageNameId{thisImage, 3};
    sortedImages.add(images.get(sortIdx(thisImage)-1));
end
    
