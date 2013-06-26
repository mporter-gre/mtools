function [sortedImages imageIds imageNames sortedDatasetNames] = getImageIdsAndNamesFromDatasetIds(datasetIds)
global gateway

numDs = length(datasetIds);
datasetContainer = omero.api.ContainerClass.Dataset;
datasetIdList = java.util.ArrayList;
datasetNames = {};
images = java.util.ArrayList;
for thisDs = 1:numDs
    dsId = datasetIds(thisDs);
    datasetIdList.add(java.lang.Long(dsId));
    datasetObjList = gateway.getDatasets(datasetIdList,false);
    datasetName = char(datasetObjList.get(0).getName.getValue.getBytes');
    imagesThisDs = gateway.getImages(datasetContainer,datasetIdList);
    numImages = imagesThisDs.size;
    for thisImage = 1:numImages
        datasetNames{end+1} = datasetName;
        images.add(imagesThisDs.get(thisImage-1));
    end
    datasetIdList = java.util.ArrayList;
%     images = [images imagesThisDs];
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
    
