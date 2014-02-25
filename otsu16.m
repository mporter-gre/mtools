function [K] = otsu16(im) 

% OTSU thresholds gray-scale image using Otsu's method. 
% input is image IM, and output is the threshold value.
% Programmed By Yingzi (Eliza) Du on 03/08/2004

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

im = uint16(im); %Change it back to uint8 
imline = reshape(im,1,[]); %reshape the matrix into a row vector
spread = 0:4095; %The range of possible values in the image.
h = hist(imline, spread)';%Get the histogram of the image using a bin for every possible intensity value (spread).
h = h/sum(h); %normalize the histogram
h = h';
im = double(im);
mn = min(min(im))+1;
mx = max(max(im))+1;
j = 0:4095; %The range of intensity values to check threshold at.
size(h)
size(j)
ut=sum(h.*j);
dett=sum(h.*((j-ut).^2));
w0 = 0;
mxvalue = 0;
for i=mn:mx-1
   j=0:i-1;
   w0 = w0 + h(i);
   w1 = 1 - w0;
   u0 = sum(h(j+1).*j)/w0;
   u1=(ut-w0.*u0)/w1;
   detb=w0.*w1.*((u0-u1).^2);
   n = detb/dett;
   if (n > mxvalue)
      mxvalue = n;
      K=i-1;
  end;
end;


