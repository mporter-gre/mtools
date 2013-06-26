function matrixOut = typecastMatrix(matrixIn, typeString)
%int8, uint8, int16, uint16, int32, uint32, int64, uint64, single, double,
%logical

switch typeString
    case 'int8'
        matrixOut = typecast(matrixIn, 'int8');    
    case 'uint8'
        matrixOut = typecast(matrixIn, 'uint8');
    case 'int16'
        matrixOut = typecast(matrixIn, 'int16');
    case 'uint16'
        matrixOut = typecast(matrixIn, 'uint16');
    case 'int32'
        matrixOut = typecast(matrixIn, 'int32');
    case 'uint32'
        matrixOut = typecast(matrixIn, 'uint32');
    case 'int64'
        matrixOut = typecast(matrixIn, 'int64');
    case 'uint64'
        matrixOut = typecast(matrixIn, 'uint64');
    case 'single'
        matrixOut = typecast(matrixIn, 'Single');
    case 'float'
        matrixOut = typecast(matrixIn, 'Single');
    case 'double'
        matrixOut = typecast(matrixIn, 'Double');
    case 'logical'
        matrixOut = typecast(matrixIn, 'logical');     
end


clear matrixIn;