function bacTrackerParameters(parentHandles, parentFigureName)
%Create the parameters structure for segmenting and tracking Bacillus. Edit
%these as necessary.

% Copyright (C) 2013-2014 University of Dundee & Open Microscopy Environment.
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

param.movieName = 'TestSchnitz-01';
param.movieDate = '2010-04-27';
param.movieKind = 'bacillus';
param.rootDir = 'D:\TestSchnitzData04272010\';
param.dateDir = 'D:\TestSchnitzData04272010\2010-04-27\';
param.movieDir = 'D:\TestSchnitzData04272010\2010-04-27\TestSchnitz-01\';
param.imageDir = 'D:\TestSchnitzData04272010\';
param.segmentationDir = 'D:\TestSchnitzData04272010\2010-04-27\TestSchnitz-01\segmentation\';
param.tracksDir = 'D:\TestSchnitzData04272010\2010-04-27\TestSchnitz-01\data\';


param.edge_lapofgauss_sigma = 3;
param.minCellArea = 30;
param.minCellLengthConservative= 12;
param.minCellLength = 20;            % JCR observed 2005-02-16
param.maxCellWidth = 20;             % JCR observed 2005-02-16
param.minNumEdgePixels = 215;        % ME set to 215 in mail to JCR 2005-08-18
param.maxThreshCut = 0.3;
param.maxThreshCut2 = 0.2;
param.maxThresh = 0.25;
param.minThresh = 0.25;
param.imNumber1 = 2;
param.imNumber2 = 1;
param.radius = 5;
param.angThresh = 2.7;

setappdata(parentHandles.(parentFigureName), 'param', param);