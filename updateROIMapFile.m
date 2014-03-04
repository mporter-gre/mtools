function updateROIMapFile(username, server, pixelsId, ROIPath)
%Update the ROIMapFile with the new ROI file for pixelsId.
%Do updateROIMapFile(username, server, pixelsId, ROIPath)
%
%Author Michael Porter

% Copyright (C) 2010-2014 University of Dundee.
% All rights reserved.
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

pixelsId = num2str(pixelsId);
sysUserHome = getenv('userprofile');
defaultUserPath = userpath;
if strcmp(defaultUserPath(1), 'H')
    %This is a really horrible hack to get around working on this Domain.
    %Sorry!!!!
    ROIMapFilePath = 'H:\omero\roiFileMap.xml';
else
    ROIMapFilePath = [sysUserHome '/omero/roiFileMap.xml'];
end
try
    fileStruct = xml2struct(ROIMapFilePath);
catch
    warndlg([{'No ROIFileMap found. The expected location was:'} {ROIMapFilePath}], 'File not found.');
    return;
end
serverChild = 0;
userChild = 0;

%Check to see if the pixelsId already has an ROI file associated with it.
%If it does, replace the ROI file path and write the xml file.
for thisChild1 = 1:length(fileStruct.children)
    if strcmp(fileStruct.children(thisChild1).name, '#text');
        continue;
    end
    thisServer = fileStruct.children(thisChild1).attributes(1).value;
    if strcmp(thisServer, server)
        serverChild = thisChild1;
        for thisChild2 = 1:length(fileStruct.children(thisChild1).children)
            if strcmp(fileStruct.children(thisChild1).children(thisChild2).name, '#text');
                continue;
            end
            thisUser = fileStruct.children(thisChild1).children(thisChild2).attributes(1).value;
            if strcmp(thisUser, username)
                userChild = thisChild2;
                for thisChild3 = 1:length(fileStruct.children(thisChild1).children(thisChild2).children);
                    if strcmp(fileStruct.children(thisChild1).children(thisChild2).children(thisChild3).name, '#text');
                        continue;
                    end
                    thisPixelsId = fileStruct.children(thisChild1).children(thisChild2).children(thisChild3).attributes(1).value;
                    if strcmp(thisPixelsId, pixelsId)
                        for thisChild4 = 1:length(fileStruct.children(thisChild1).children(thisChild2).children(thisChild3).children)
                            if strcmp(fileStruct.children(thisChild1).children(thisChild2).children(thisChild3).children(thisChild4).name, 'file')
                                fileStruct.children(thisChild1).children(thisChild2).children(thisChild3).children(thisChild4).attributes(1).value = ROIPath;
                                newXMLFile = struct2xml(fileStruct);
                                xmlwrite(ROIMapFilePath, newXMLFile);
                                return;
                            end
                        end
                    end
                end
            end
        end
    end
end

%Create a new entry for the pixelsId.
if serverChild > 0 && userChild > 0
    lengthChild3 = length(fileStruct.children(serverChild).children(userChild).children);
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).name = 'pixelsid';
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).attributes(1).name = 'id';
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).attributes(1).value = pixelsId;
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).attributes(2).name = 'xmlns';
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).attributes(2).value = 'http://openmicroscopy.org.uk';
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).data = '';
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).children(1).name = 'file';
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).children(1).attributes(1).name = 'filename';
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).children(1).attributes(1).value = ROIPath;
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).children(1).attributes(2).name = 'xmlns';
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).children(1).attributes(2).value = 'http://openmicroscopy.org.uk';
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).children(1).data = '';
    fileStruct.children(serverChild).children(userChild).children(lengthChild3+1).children(1).children = [];
    newXMLFile = struct2xml(fileStruct);
    xmlwrite(ROIMapFilePath, newXMLFile);
end

if serverChild == 0 || userChild == 0
    warndlg([{'There is no entry in the ROIFileMap'} {'for you on this server'}], 'Server/User Not Found');
end
