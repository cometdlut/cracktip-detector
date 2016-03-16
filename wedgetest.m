close all
clear all

%% find threshold

folder = 'canonR400_backillumination_0.2_25fps';
%folder = '.';
%nimage = length(dir([folder '/*.jpeg']));
% define a window to analyze
startX = 550;
startY = 450;
% find the threshold from the first image
im0 = imread([folder '/image-001.jpeg']);
im_gray0 = rgb2gray(im0);
% make the window wide enough
im_window0 = im_gray0(startY:(startY + 200), (startX:startX + 450));
im_reshape0 = reshape(im_window0, [], 1);
im_double0 = im2double(im_reshape0);
figure
hist(im_double0, 100);
threshold = 0.09;
[height, width] = size(im_gray0);

%% read in multiple images
deltaX = 100;
deltaY = 30;
halflength = 100;
cracktip = [];
mkdir([folder '/cracktip'])
for i = 188:188
    filename = sprintf('%s/image-%03d.jpeg', folder, i);
    im = imread(filename);
    im_gray = rgb2gray(im);
    % make the window wide enough
    im_window = im_gray((startY - deltaY):(startY + deltaY), ...
                        (startX - deltaX):(startX + deltaX));
    im_window = im2double(im_window);
    BW_window = im2bw(im_window, threshold);
    [r, c, v] = find(BW_window);
    [cracktip_X, ind] = max(c);
    cracktip_Y = r(ind);
    startX = startX - deltaX + cracktip_X;
    startY = startY - deltaY + cracktip_Y;
    cracktip = [cracktip; startX];
    figure('Visible','off')
    imshow(im);
    hold on
    plot([startX, startX], [startY - halflength, startY + halflength], ...
         'y-', 'linewidth', 1);
    
    set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 width height])
    print(sprintf('%s/cracktip/%03d.jpeg', folder, i), '-djpeg', '-r1')
    close
end
%% Plot crackgrowth with time

crackgrowth = cracktip(2:end) - cracktip(1:(end - 1));
%crackgrowth(crackgrowth < 0) = 0;

time = linspace(1, nimage - 1, nimage -1);
figure
h = plot (crackgrowth, 'ro-')
xlabel('Time (s)', 'fontsize', 15);
ylabel('Crack Growth', 'fontsize', 15);
print([folder '/crackgrowth'], '-dpdf')


