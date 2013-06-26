function bacTrackerParameters(parentHandles, parentFigureName)
%Create the parameters structure for segmenting and tracking Bacillus. Edit
%these as necessary.

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