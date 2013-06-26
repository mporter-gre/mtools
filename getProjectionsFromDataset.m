function projections = getProjectionsFromDataset(datasets, channel, gateway)
%get 'channel' from projections in the dataset listed in 'datasets'. 'datasets' 
%should contain only one dataset. This script will only use the first one if
%there are more than one.

allTheImages = omerojava.util.GatewayUtils.getImagesFromDataset(datasets.get(0));
numImages = allTheImages.size;
allTheImagesIter = allTheImages.iterator;
i = 1;
while allTheImagesIter.hasNext
    allTheImagesIter.next;
    imageId(i) = allTheImages.get(i-1).getId.getValue;
    projections{i}.imageName = allTheImages.get(i-1).getName.getValue.toCharArray';
    projections{i}.imageId = allTheImages.get(i-1).getId.getValue;
    projections{i}.channel = num2str(channel);
    projections{i}.plane = getPlaneFromImageId(projections{i}.imageId,0,channel-1,0,gateway);
    i = i + 1;
end
    

end