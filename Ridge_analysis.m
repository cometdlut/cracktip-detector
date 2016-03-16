close all
clear all

%start = 1;
final = 1269;
initXmin = 20;
initXmax = 30;
lowerBound = 15;
upperBound = 65;
cracktip = [];

filename = sprintf('./20150720_SLR_whitepaint/ridge-contours/image-0001-crop.csv');
fid = fopen(filename);
contour = textscan(fid, '%f%f%f%f%f%f%f%s', 'Delimiter', ',', 'Headerlines', 1);
conID = contour{3};
allX = contour{5};
allY = contour{6};

candidate = [];
imageFile = sprintf('./20150720_SLR_whitepaint/crop-image/image-0001-crop.png');
raw = imread(imageFile);
imgHandle = imshow(raw);

uniqIDs = unique(conID);
for j = 1: size(uniqIDs, 1)
    k = uniqIDs(j);
    indices = conID == k;
    X = allX(indices);
    Y = allY(indices);
    [IDmaxY, IDmaxIndex] = max(Y);
    IDmaxX = X(IDmaxIndex);
    candidate = [candidate; IDmaxX IDmaxY];
    
end
xind = find(candidate(:,1) >=initXmin & candidate(:,1) <=initXmax);
[maxY, indY] = max(candidate(xind, 2));
newcandidate = candidate(xind);
maxX = newcandidate(indY);

cracktip = [cracktip; maxY];
hold on
plot(maxX, maxY, 'o',...
    'markerfacecolor', 'r', 'markeredgecolor', 'r', 'markersize', 4);
saveas(imgHandle, sprintf('./20150720_SLR_whitepaint/overlay-ydistance-matlab/image-0001-overlay.png'));
fclose(fid)

for i = 2: final
    filename = sprintf('./20150720_SLR_whitepaint/ridge-contours/image-%04d-crop.csv', i);
    fid = fopen(filename);
    contour = textscan(fid, '%f%f%f%f%f%f%f%s', 'Delimiter', ',', 'Headerlines', 1);
    conID = contour{3};
    allX = contour{5};
    allY = contour{6};
    
    candidate = [];
    imageFile = sprintf('./20150720_SLR_whitepaint/crop-image/image-%04d-crop.png', i);
    raw = imread(imageFile);
    imgHandle = imshow(raw);
    
    uniqIDs = unique(conID);
    for j = 1: size(uniqIDs, 1)
        k = uniqIDs(j);
        indices = conID == k;
        X = allX(indices);
        Y = allY(indices);
        [IDmaxY, IDmaxIndex] = max(Y);
        IDmaxX = X(IDmaxIndex);
        % first filtering
        if IDmaxX > lowerBound && IDmaxX < upperBound;
            candidate = [candidate; IDmaxX IDmaxY];
        end
    end
    
    % second filtering
    distance = candidate(:, 2) - maxY;
    
    if any(distance >= 0)
        candidate = candidate(distance >= 0, :);
        [~, ind] = min(distance(distance >= 0));
        
    else
        [~, ind] = min(abs(distance));
    end
    
    maxX = candidate(ind, 1);
    maxY = candidate(ind, 2);
    cracktip = [cracktip; maxY];
    
    hold on
    plot(maxX, maxY, 'o',...
        'markerfacecolor', 'r', 'markeredgecolor', 'r', 'markersize', 4);
    saveas(imgHandle, sprintf('./20150720_SLR_whitepaint/overlay-ydistance-matlab/image-%04d-overlay.png', i));
    fclose(fid)
    close all
    save('workspace.mat', 'cracktip')
end


figure
x = 1 : size(cracktip);
plot(x, cracktip, 'o')



