function viewPlanesFromRange(startRange, endRange)

[client, session, gateway] = blitzkriegBop;
for id = startRange:endRange
    img = gateway.getPlaneAsInt(id, 0, 0, 0);
    figure(50);
    imshow(img, [min2(img) max2(img)]);
    id
    pause;
end
session.close();
gateway.close();
client.close();

end