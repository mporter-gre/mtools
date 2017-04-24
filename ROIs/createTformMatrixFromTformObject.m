function tformMatrix = createTformMatrixFromTformObject(tform)

A00 = tform.getA00.getValue;
A10 = tform.getA10.getValue;
A01 = tform.getA01.getValue;
A11 = tform.getA11.getValue;
A02 = tform.getA02.getValue;
A12 = tform.getA12.getValue;

tformMatrix = [A00, A10, 0; A01, A11, 0; A02, A12, 1];