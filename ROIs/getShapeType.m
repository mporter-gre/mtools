function shapeType = getShapeType(shape)
%Return a shapeType in simple text taken from the omero.model.shapeI
%shapeType = getShapeType(shape)

shapeClass = class(shape);

switch shapeClass
    case {'omero.model.EllipseI'}
        shapeType = 'ellipse';
    
    case {'omero.model.RectI'}
        shapeType = 'rect';
    
    case{'omero.model.PolylineI'}
        shapeType = 'polyLine';
        
    case{'omero.model.PointI'}
        shapeType = 'point';
        
    case{'omero.model.PolygonI'}
        shapeType = 'polygon';
        
    case{'omero.model.LineI'}
        shapeType = 'line';
        
    case{'omero.model.TextI'}
        shapeType = 'text';
end