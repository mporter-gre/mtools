function dsList = getDatasetIdsFromImageIds(imageIds)

global session;

queryService = session.getQueryService;
numImages = length(imageIds);
dsList = {};

for thisImage = 1:numImages
    qString = ['select link from DatasetImageLink as link where link.child.id = ' num2str(imageIds)];
    result = queryService.findAllByQuery(qString, []);
    
    numDs = result.size;
    for thisDs = 1:numDs
        thisDsId = result.get(thisDs-1).getParent.getId.getValue;
        dsList{end+1,1} = thisDsId;
        ds = getDatasets(session, thisDsId, false);
        dsList{end,2} = char(ds.getName.getValue.getBytes');
    end
end