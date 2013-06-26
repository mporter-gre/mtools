function pixelsWithPlanes = getMyDatasetImages(datasetId)
%Feed in a dataset ID and get returned all of the pixel id's, pixel names
%and plane data (first z, c and t only) in one structure. You can use
%datasets = getDatasets('username') to get your datasets and id's.
%Do pixelsWithPlanes = getMyDatasetImages(datasetId);
tic

%Connect to the server.
[client, session, gateway] = blitzkriegBop;

%Get the dataset information for the datasetId entered. getLeaves = true.
dataset = gateway.getDataset(datasetId,true);

%Get the pixels in the dataset
pixels = gateway.getPixelsFromDataset(dataset);

%Iterate through the pixels and get the pixel names.
iter = pixels.iterator;
counter = 1; 
while iter.hasNext(); 
    pixelsWithPlanes{counter}.name = char(pixels.get(counter-1).image.getName); 
    iter.next(); 
    counter = counter + 1; 
end

%Iterate through the pixels and get the id to get the planes.
iter = pixels.iterator;
counter = 1; 
while iter.hasNext(); 
    pixelsWithPlanes{counter}.id = double(iter.next().id.val); 
    counter = counter + 1; 
end

%Get the first c, z and t for each plane Id.
for thisPlane = 1:length(pixelsWithPlanes)
    pixelsWithPlanes{thisPlane}.plane = gateway.getPlane(pixelsWithPlanes{thisPlane}.id,0,0,0);
    disp(['loading plane... ', num2str(thisPlane)]);
end

%Close the connection to the server.
gateway.close();
session.close();
client.close();

toc
end