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

% imtool(fruit1HSV);
% imtool(fruit2HSV);
% imtool(fruit3HSV);
% imtool(fruit4HSV);
%% Thresholds for the Banana
% Select which image to run the algorithm on
img = fruit3;

% Convert the image to HSV and extract each channel
imgHSV = rgb2hsv(img);
H = imgHSV(:,:,1);
S = imgHSV(:,:,2);
V = imgHSV(:,:,3);

% Initialize the masks for bananas, oranges, and apples
maskBanana = zeros(size(imgHSV,1),size(imgHSV,2));
maskOrange = zeros(size(imgHSV,1),size(imgHSV,2));
maskApple = zeros(size(imgHSV,1),size(imgHSV,2));

% Find the indices which match the Hue, Saturation, and Value thresholds
idxBanana = find((H>=0.10&H<=0.20)&(S>=0.6&S<=0.95)&(V>=0.4&V<=0.95));
idxOrange = find((H>=0.00&H<=0.12)&(S>=0.6&S<=1.00)&(V>=0.4&V<=1.00));
idxApple =  find((H>=0.95|H<=0.07)&(S>=0.4&S<=1.00)&(V>=0.0&V<=0.60));

% Create the masks for each fruit
maskBanana(idxBanana) = 1;
maskOrange(idxOrange) = 1;
maskApple(idxApple) = 1;

% Combine the 3 masks into a single mask where Bananas are Red, Oranges are
% Green, and Apples are Blue
maskAll = zeros(size(imgHSV,1),size(imgHSV,2), 3);
maskAll(:,:,1) = maskBanana;
maskAll(:,:,2) = maskOrange;
maskAll(:,:,3) = maskApple;

% imwrite(maskAll,'image3_all_masks.jpg');
imtool(maskAll);

% Generate connected components for each of the 3 masks
CCBanana = bwconncomp(maskBanana,4);
CCOrange = bwconncomp(maskOrange,4);
CCApple = bwconncomp(maskApple,4);

% Extract relevant properties of each connected component
SBanana = regionprops(CCBanana,'Area','MajorAxisLength','MinorAxisLength','PixelIdxList');
for i=1:size(SBanana,1)
    SBanana(i).AspectRatio = SBanana(i).MajorAxisLength/SBanana(i).MinorAxisLength;
end
SOrange = regionprops(CCOrange,'Area','MajorAxisLength','MinorAxisLength','PixelIdxList');
for i=1:size(SOrange,1)
    SOrange(i).AspectRatio = SOrange(i).MajorAxisLength/SOrange(i).MinorAxisLength;
end
SApple = regionprops(CCApple,'Area','MajorAxisLength','MinorAxisLength','PixelIdxList');
for i=1:size(SApple,1)
    SApple(i).AspectRatio = SApple(i).MajorAxisLength/SApple(i).MinorAxisLength;
end

% Filter out connected components if their proporties don't meet area or
% aspect ratio criteria
bananaMaxPixels = max([SBanana.Area]);
remove = find([SBanana.Area] <= bananaMaxPixels/4);
SBanana(remove) = [];
remove = find([SBanana.AspectRatio] <= 1.8);
SBanana(remove) = [];

orangeMaxPixels = max([SOrange.Area]);
remove = find([SOrange.Area] <= orangeMaxPixels/6);
SOrange(remove) = [];
remove = find([SOrange.AspectRatio] >= 2.5);
SOrange(remove) = [];

appleMaxPixels = max([SApple.Area]);
remove = find([SApple.Area] <= appleMaxPixels/6);
SApple(remove) = [];
remove = find([SApple.AspectRatio] >= 2.5);
SApple(remove) = [];

% Create a new mask with only the pixels from the connected components that
% passed the previous criteria (size and aspect ratio)
maskBanana2 = zeros(size(imgHSV,1),size(imgHSV,2));
maskOrange2 = zeros(size(imgHSV,1),size(imgHSV,2));
maskApple2 = zeros(size(imgHSV,1),size(imgHSV,2));
maskBanana2(cat(1,SBanana.PixelIdxList)) = 1;
maskOrange2(cat(1,SOrange.PixelIdxList)) = 1;
maskApple2(cat(1,SApple.PixelIdxList)) = 1;

maskAll = zeros(size(imgHSV,1),size(imgHSV,2), 3);
maskAll(:,:,1) = maskBanana2;
maskAll(:,:,2) = maskOrange2;
maskAll(:,:,3) = maskApple2;
imtool(maskAll);

% Use morphological operations to make sure that we have some good
% connected components

maskBanana3 = imopen(maskBanana2,strel('diamond',1));
maskBanana3 = imclose(maskBanana3,strel('diamond',1));
maskOrange3 = imclose(maskOrange2,strel('disk',2));
maskOrange3 = imopen(maskOrange3,strel('disk',2));
maskApple3 = imclose(maskApple2,strel('disk',2));
maskApple3 = imopen(maskApple3,strel('disk',2));

maskAll = zeros(size(imgHSV,1),size(imgHSV,2), 3);
maskAll(:,:,1) = maskBanana3;
maskAll(:,:,2) = maskOrange3;
maskAll(:,:,3) = maskApple3;
imtool(maskAll);

% Again, generate connected components for each of the 3 masks.  These
% masks are the result of the morphological operations
CCBanana = bwconncomp(maskBanana3,4);
CCOrange = bwconncomp(maskOrange3,4);
CCApple = bwconncomp(maskApple3,4);

% Extract relevant properties of each connected component
SBanana = regionprops(CCBanana,'Area','MajorAxisLength','MinorAxisLength','Centroid','BoundingBox','PixelIdxList');
for i=1:size(SBanana,1)
    SBanana(i).AspectRatio = SBanana(i).MajorAxisLength/SBanana(i).MinorAxisLength;
end
SOrange = regionprops(CCOrange,'Area','MajorAxisLength','MinorAxisLength','Centroid','BoundingBox','PixelIdxList');
for i=1:size(SOrange,1)
    SOrange(i).AspectRatio = SOrange(i).MajorAxisLength/SOrange(i).MinorAxisLength;
end
SApple = regionprops(CCApple,'Area','MajorAxisLength','MinorAxisLength','Centroid','BoundingBox','PixelIdxList');
for i=1:size(SApple,1)
    SApple(i).AspectRatio = SApple(i).MajorAxisLength/SApple(i).MinorAxisLength;
end

% Filter out connected components if their proporties don't meet area or
% aspect ratio criteria
bananaMaxPixels = max([SBanana.Area]);
remove = find([SBanana.Area] <= bananaMaxPixels/2);
SBanana(remove) = [];
remove = find([SBanana.AspectRatio] <= 1.8);
SBanana(remove) = [];

orangeMaxPixels = max([SOrange.Area]);
remove = find([SOrange.Area] <= orangeMaxPixels/6);
SOrange(remove) = [];
remove = find([SOrange.AspectRatio] >= 2.5);
SOrange(remove) = [];

appleMaxPixels = max([SApple.Area]);
remove = find([SApple.Area] <= appleMaxPixels/6);
SApple(remove) = [];
remove = find([SApple.AspectRatio] >= 2.5);
SApple(remove) = [];

% Create a new mask with only the pixels from the connected components that
% passed the previous criteria (size and aspect ratio)
maskBanana4 = zeros(size(imgHSV,1),size(imgHSV,2));
maskOrange4 = zeros(size(imgHSV,1),size(imgHSV,2));
maskApple4 = zeros(size(imgHSV,1),size(imgHSV,2));
maskBanana4(cat(1,SBanana.PixelIdxList)) = 1;
maskBanana4 = imfill(maskBanana4);
maskOrange4(cat(1,SOrange.PixelIdxList)) = 1;
maskApple4(cat(1,SApple.PixelIdxList)) = 1;

maskAll = zeros(size(imgHSV,1),size(imgHSV,2), 3);
maskAll(:,:,1) = maskBanana4;
maskAll(:,:,2) = maskOrange4;
maskAll(:,:,3) = maskApple4;
imtool(maskAll);

for i=1:length(SBanana)
 img = insertShape(img,'Rectangle',SBanana(i).BoundingBox,'Color','yellow','Opacity',0.4);
 img = insertText(img,SBanana(i).Centroid,num2str(i),'AnchorPoint','LeftCenter','BoxOpacity',0);
 img = insertShape(img,'FilledRectangle',[SBanana(i).Centroid 3 3],'Color','cyan','Opacity',1);
end
for j=1:length(SOrange)
 img = insertShape(img,'Rectangle',SOrange(j).BoundingBox,'Color',[255,127,0],'Opacity',0.4);
 img = insertText(img,SOrange(j).Centroid,num2str(j),'AnchorPoint','LeftCenter','BoxOpacity',0);
 img = insertShape(img,'FilledRectangle',[SOrange(j).Centroid 3 3],'Color','cyan','Opacity',1);
end
for k=1:length(SApple)
 img = insertShape(img,'Rectangle',SApple(k).BoundingBox,'Color','red','Opacity',0.4);
 img = insertText(img,SApple(k).Centroid,num2str(k),'AnchorPoint','LeftCenter','BoxOpacity',0,'TextColor','white');
 img = insertShape(img,'FilledRectangle',[SApple(k).Centroid 3 3],'Color','cyan','Opacity',1);
end
text = append('Fruit Counts: Bananas-',num2str(i),'  Oranges-',num2str(j),'  Apples-',num2str(k));
img = insertText(img,[size(img,1) 0],text,'AnchorPoint','RightTop','BoxOpacity',0,'TextColor','black');
figure();imshow(img);

