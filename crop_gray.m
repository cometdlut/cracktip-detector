close all
clear all

filename = sprintf('./original-image/image-0002.png');
original = imread(filename);
figure
img1 = imshow(original);
pause

nimage = length(dir('./original-image/*.png'));
for i = 2 : nimage;
    filename = sprintf('./original-image/image-%04d.png', i);
    original = imread(filename);
    cropfig = imcrop(original, [905, 50, 115, 930]);
    gray = rgb2gray(cropfig);
    imshow(gray);
    %imwrite(gray, sprintf('./crop-image2/%s-%04d-crop.png', 'image', i));
    saveas(gcf, sprintf('./crop-image2/%s-%04d-crop.eps', 'image', i),'epsc');
end