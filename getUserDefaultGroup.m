function group = getUserDefaultGroup(session, username)


adminService = session.getAdminService;
userObj = adminService.lookupExperimenter(username);
userId = userObj.getId.getValue;
%userGroups = adminService.containedGroups(userId);
group = char(adminService.getDefaultGroup(userId).getName.getValue.getBytes');