function projList = getProjectIdsFromDatasetIds(dsList)

global session;

queryService = session.getQueryService;
numDs = length(dsList);
projList = {};

for thisDs = 1:numDs
    qString = ['select link from ProjectDatasetLink as link where link.child.id = ' num2str(dsList(thisDs))];
    result = queryService.findAllByQuery(qString, []);
    
    numProj = result.size;
    for thisProj = 1:numProj
        thisProjId = result.get(thisProj-1).getParent.getId.getValue;
        projList{end+1,1} = thisProjId;
        proj = getProjects(session, thisProjId, false);
        projList{end,2} = char(proj.getName.getValue.getBytes');
    end
end
