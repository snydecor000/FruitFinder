function [lstImg] = rgb2lst(rgbImg)
%RGB2LST Summary of this function goes here
%   Detailed explanation goes here
rgbImg = double(rgbImg);
R = rgbImg(:,:,1);
G = rgbImg(:,:,2);
B = rgbImg(:,:,3);

L = (R+G+B)/3;
S = R-B;
T = R-2*G+B;

lstImg = zeros(size(rgbImg));
lstImg(:,:,1) = L;
lstImg(:,:,2) = S;
lstImg(:,:,3) = T;
lstImg = uint8(lstImg);
