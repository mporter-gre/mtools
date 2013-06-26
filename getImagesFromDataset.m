function plane = getImagesFromDataset(datasetId, gateway)

allTheImages = omerojava.util.GatewayUtils.getImagesFromDataset(datasets.get(1));
numImages = allTheImages.size;
allTheImagesIter = allTheImages.iterator;
i = 1;
while allTheImagesIter.hasNext
    imageId(i) = allTheImages.get(i-1).getId.getValue;
    i = i + 1;
    

end