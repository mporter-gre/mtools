function plane = getRenderedPlaneFromImageId(id, z, t, gateway)

pixels = gateway.getPixelsFromImage(id);
pixelsId = pixels.get(0).getId().getValue();
renderedPlane = gateway.getRenderedImage(pixelsId, z, t);
plane2D = omerojava.util.GatewayUtils.getPlane2D(pixels.get(0), renderedPlane);
plane = plane2D.getPixelsArrayAsDouble(1);

end