function imgOut = bugSeg(img)

imgEdge = edge(img, 'sobel');
imgEdgeBWA = bwareaopen(imgEdge, 15);
imgEdgeBWAHull = bwconvhull(imgEdgeBWA, 'objects', 8);

[imgSeg2D minValue] = seg2D(double(img), 0, 0, 10);

combinedEdgeHullSeg = imgEdge + imgEdgeBWAHull + logical(imgSeg2D);
combinedEdgeHullSegAmp = combinedEdgeHullSeg;
combinedEdgeHullSegAmp(combinedEdgeHullSeg>0) = combinedEdgeHullSeg(combinedEdgeHullSeg>0)+1000;
[segBWL minValue] = seg2D(combinedEdgeHullSegAmp, 0, 0, 10);

bugProps = regionprops(segBWL, 'majoraxis', 'minoraxis', 'eccentricity', 'area');

objectValues = unique(segBWL(segBWL>0));
numObjects = length(objectValues);

for thisObject = 1:numObjects
    major = bugProps(thisObject).MajorAxisLength;
    minor = bugProps(thisObject).MinorAxisLength;
    eccen = bugProps(thisObject).Eccentricity;
    area = bugProps(thisObject).Area;
    if major == 0 || minor == 0 || eccen < 0.3 || area < 40
        thisObjVal = objectValues(thisObject);
        segBWL(segBWL==thisObjVal) = 0;
    end
end

imgOut = segBWL;