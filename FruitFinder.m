%% Load in the Fruit
close all;
imtool close all;
fruit1 = imread('fruit/mixed_fruit1.tiff');
fruit2 = imread('fruit/mixed_fruit2.tiff');
fruit3 = imread('fruit/mixed_fruit3.tiff');
fruit4 = imread('fruit/fruit_tray.tiff');
%% Display the Fruit
figure();imshow(fruit1);
figure();imshow(fruit2);
figure();imshow(fruit3);
figure();imshow(fruit4);

fruit1HSV = rgb2hsv(fruit1);
fruit2HSV = rgb2hsv(fruit2);
fruit3HSV = rgb2hsv(fruit3);
fruit4HSV = rgb2hsv(fruit4);

% imwrite(fruit1HSV, 'fruit1HSV.jpg');
% imwrite(fruit2HSV, 'fruit2HSV.jpg');
% imwrite(fruit3HSV, 'fruit3HSV.jpg');

imtool(fruit1HSV);
imtool(fruit2HSV);
imtool(fruit3HSV);
imtool(fruit4HSV);
%% Thresholds for the Banana
% Figure 
img = fruit3;
imgHSV = fruit3HSV;
h = imgHSV(:,:,1);
s = imgHSV(:,:,2);
v = imgHSV(:,:,3);

maskBanana = zeros(size(imgHSV,1),size(imgHSV,2));
maskOrange = zeros(size(imgHSV,1),size(imgHSV,2));
maskApple = zeros(size(imgHSV,1),size(imgHSV,2));

idxBanana = find((h>=0.1 & h<=0.2)&(s>=0.6 & s<=0.95)&(v>=0.4&v<=0.95));
idxOrange = find((h>=0&h<=0.12)&(s>=0.6&s<=1)&(v>=0.4&v<=1));
idxApple = find((h>=0.95|h<=0.07)&(s>=0.4&s<=1)&(v>=0&v<=0.6));

maskBanana(idxBanana) = 1;
figure();imshow(maskBanana);

maskOrange(idxOrange) = 1;

maskApple(idxApple) = 1;

maskAll = zeros(size(imgHSV,1),size(imgHSV,2), 3);
maskAll(:,:,1) = maskBanana;
maskAll(:,:,2) = maskOrange;
maskAll(:,:,3) = maskApple;

% imwrite(maskAll,'image3_all_masks.jpg');

CC = bwconncomp(maskBanana,4);
S = regionprops(CC,'Area','MajorAxisLength','MinorAxisLength','Centroid','BoundingBox','PixelIdxList');
for i=1:size(S,1)
    S(i).AspectRatio = S(i).MajorAxisLength/S(i).MinorAxisLength;
end

maxPixels = max([S.Area]);
remove = find([S.Area] <= maxPixels/4);
S(remove) = [];
remove = find([S.AspectRatio] <= 1.8);
S(remove) = [];

% Create a new mask with only the pixels from the connected components that
% passed the previous criteria (size and aspect ratio)
newMask = zeros(size(maskBanana,1),size(maskBanana,2));
newMask(cat(1,S.PixelIdxList)) = 1;
figure();imshow(newMask);

% Now its time to use morphology to make sure that we have some good
% connected components

newMask2 = imopen(newMask,strel('diamond',1));
newMask2 = imclose(newMask2,strel('diamond',1));
figure();imshow(newMask2);

CC2 = bwconncomp(newMask2,4);
S2 = regionprops(CC2,'Area','MajorAxisLength','MinorAxisLength','Centroid','BoundingBox','PixelIdxList');
for i=1:size(S2,1)
    S2(i).AspectRatio = S2(i).MajorAxisLength/S2(i).MinorAxisLength;
end

maxPixels2 = max([S2.Area]);
remove = find([S2.Area] <= maxPixels2/2);
S2(remove) = [];
remove = find([S2.AspectRatio] <= 1.8);
S2(remove) = [];

% Create a new mask with only the pixels from the connected components that
% passed the previous criteria (size and aspect ratio)
newMask3 = zeros(size(newMask2,1),size(newMask2,2));
newMask3(cat(1,S2.PixelIdxList)) = 1;
newMask3 = imfill(newMask3);
figure();imshow(newMask3);

for i=1:length(S2)
 img = insertShape(img,'Rectangle',S2(i).BoundingBox);
 img = insertText(img,S2(i).Centroid,num2str(i),'AnchorPoint','Center');
end
figure();imshow(img);
%% Thresholds for the Oranges
% Figure 1
img = fruit2;
imgHSV = fruit2HSV;
h = imgHSV(:,:,1);
s = imgHSV(:,:,2);
v = imgHSV(:,:,3);

maskOrange = zeros(size(imgHSV,1),size(imgHSV,2));

% Orange
idxOrange = find((h>=0&h<=0.12)&(s>=0.6&s<=1)&(v>=0.4&v<=1));
maskOrange(idxOrange) = 1;
imtool(maskOrange);

CC = bwconncomp(maskOrange,4);
S = regionprops(CC,'Area','MajorAxisLength','MinorAxisLength','Centroid','BoundingBox','PixelIdxList');
for i=1:size(S,1)
    S(i).AspectRatio = S(i).MajorAxisLength/S(i).MinorAxisLength;
end

maxPixels = max([S.Area]);
remove = find([S.Area] <= maxPixels/6);
S(remove) = [];
% remove = find([S.AspectRatio] >= 2);
% S(remove) = [];

% Create a new mask with only the pixels from the connected components that
% passed the previous criteria (size and aspect ratio)
maskOrange2 = zeros(size(maskOrange,1),size(maskOrange,2));
maskOrange2(cat(1,S.PixelIdxList)) = 1;
imtool(maskOrange2);

% Now its time to use morphology to make sure that we have some good
% connected components

maskOrange3 = imclose(maskOrange2,strel('disk',2));
maskOrange3 = imopen(maskOrange3,strel('disk',2));
%maskBanana = imdilate(maskBanana,strel('diamond',2));
imtool(maskOrange3);

CC2 = bwconncomp(maskOrange3,4);
S2 = regionprops(CC2,'Area','MajorAxisLength','MinorAxisLength','Centroid','BoundingBox','PixelIdxList');
for i=1:size(S2,1)
    S2(i).AspectRatio = S2(i).MajorAxisLength/S2(i).MinorAxisLength;
end

maxPixels2 = max([S2.Area]);
remove = find([S2.Area] <= maxPixels2/6);
S2(remove) = [];
% remove = find([S2.AspectRatio] >= 2);
% S2(remove) = [];

% Create a new mask with only the pixels from the connected components that
% passed the previous criteria (size and aspect ratio)
maskOrange4 = zeros(size(maskOrange3,1),size(maskOrange3,2));
maskOrange4(cat(1,S2.PixelIdxList)) = 1;
imtool(maskOrange4);

for i=1:length(S2)
 img = insertShape(img,'Rectangle',S2(i).BoundingBox);
 img = insertText(img,S2(i).Centroid,num2str(i),'AnchorPoint','Center');
end
figure();imshow(img);

%% Thresholds for the Apples
% Figure 1
img = fruit2;
imgHSV = fruit2HSV;
h = imgHSV(:,:,1);
s = imgHSV(:,:,2);
v = imgHSV(:,:,3);

maskApple = zeros(size(imgHSV,1),size(imgHSV,2));

% Apple
idxApple = find((h>=0.95|h<=0.07)&(s>=0.4&s<=1)&(v>=0&v<=0.6));
maskApple(idxApple) = 1;
imtool(maskApple);

CC = bwconncomp(maskApple,4);
S = regionprops(CC,'Area','MajorAxisLength','MinorAxisLength','Centroid','BoundingBox','PixelIdxList');
for i=1:size(S,1)
    S(i).AspectRatio = S(i).MajorAxisLength/S(i).MinorAxisLength;
end

maxPixels = max([S.Area]);
remove = find([S.Area] <= maxPixels/6);
S(remove) = [];
remove = find([S.AspectRatio] >= 2);
S(remove) = [];

% Create a new mask with only the pixels from the connected components that
% passed the previous criteria (size and aspect ratio)
maskApple2 = zeros(size(maskApple,1),size(maskApple,2));
maskApple2(cat(1,S.PixelIdxList)) = 1;
imtool(maskApple2);

% Now its time to use morphology to make sure that we have some good
% connected components

maskApple3 = imclose(maskApple2,strel('disk',2));
maskApple3 = imopen(maskApple3,strel('disk',2));
%maskBanana = imdilate(maskBanana,strel('diamond',2));
imtool(maskApple3);

CC2 = bwconncomp(maskApple3,4);
S2 = regionprops(CC2,'Area','MajorAxisLength','MinorAxisLength','Centroid','BoundingBox','PixelIdxList');
for i=1:size(S2,1)
    S2(i).AspectRatio = S2(i).MajorAxisLength/S2(i).MinorAxisLength;
end

maxPixels2 = max([S2.Area]);
remove = find([S2.Area] <= maxPixels2/6);
S2(remove) = [];
remove = find([S2.AspectRatio] >= 2);
S2(remove) = [];

% Create a new mask with only the pixels from the connected components that
% passed the previous criteria (size and aspect ratio)
maskApple4 = zeros(size(maskApple3,1),size(maskApple3,2));
maskApple4(cat(1,S2.PixelIdxList)) = 1;
imtool(maskApple4);

for i=1:length(S2)
 img = insertShape(img,'Rectangle',S2(i).BoundingBox);
 img = insertText(img,S2(i).Centroid,num2str(i),'AnchorPoint','Center');
end
figure();imshow(img);

