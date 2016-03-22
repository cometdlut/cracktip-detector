close all
clear all

% Input parameters
final = 813;
initXmin = 20;
initXmax = 40;
lowerBound = 1;
upperBound = 75;
cracktip = [];
%fitting_para = {'line = 4;','high = 230;','low = 87;',...
    %'sigma = 1.65;','lower = 0.68;','upper = 4.76'};

% Check first image
filename = sprintf('./fijiresult/image-0001-crop.csv');
fid = fopen(filename);
contour = textscan(fid, '%f%f%f%f%f%f%f%s', 'Delimiter', ',', 'Headerlines', 1);
conID = contour{3};
allX = contour{5};
allY = contour{6};

candidate = [];
imageFile = sprintf('./crop-image/image-0001-crop.png');
raw = imread(imageFile);
imgHandle = imshow(raw);

uniqIDs = unique(conID);

for j = 1: size(uniqIDs, 1)
    k = uniqIDs(j);
    indices = conID == k;
    X = allX(indices);
    Y = allY(indices);
    hold all
    plot(X, Y, '-', 'linewidth', 3);
    
    [IDmaxY, IDmaxIndex] = max(Y);
    IDmaxX = X(IDmaxIndex);
    candidate = [candidate; IDmaxX IDmaxY];
end

saveas(imgHandle, sprintf('./result2/image-0001-contours.eps'));

xind = find(candidate(:,1) >=initXmin & candidate(:,1) <=initXmax);
[maxY, indY] = max(candidate(xind, 2));
newcandidate = candidate(xind);
maxX = newcandidate(indY);

cracktip = [cracktip; maxY];
figure
imgHandle = imshow(raw);
hold on
plot(maxX, maxY, 'o',...
    'markerfacecolor', 'r', 'markeredgecolor', 'r', 'markersize', 4);
saveas(imgHandle, sprintf('./result2/image-0001-overlay.eps'));
fclose(fid)
close all

%%  Run the rest of images
for i = 2: final
    filename = sprintf('./fijiresult/image-%04d-crop.csv', i);
    fid = fopen(filename);
    contour = textscan(fid, '%f%f%f%f%f%f%f%s', 'Delimiter', ',', 'Headerlines', 1);
    conID = contour{3};
    allX = contour{5};
    allY = contour{6};
    
    contour = [];
    endpoint = [];
    candidate = [];
    imageFile = sprintf('./crop-image/image-%04d-crop.png', i);
    raw = imread(imageFile);
    figure
    imgoverlay = imshow(raw);
    
    uniqIDs = unique(conID);
    for j = 1: size(uniqIDs, 1)
        k = uniqIDs(j);
        indices = conID == k;
        X = allX(indices);
        Y = allY(indices);
        
        hold all
        plot(X, Y, '-', 'linewidth', 3);
        [IDmaxY, IDmaxIndex] = max(Y);
        IDmaxX = X(IDmaxIndex);
        [IDminY, IDminIndex] = min(Y);
        IDminX = X(IDminIndex);
        endpoint = [endpoint; k, IDmaxX, IDmaxY];
        % first filtering
        if IDmaxX > lowerBound && IDmaxX < upperBound;
            candidate = [candidate; IDmaxX IDmaxY, IDminY IDminX];
        end
    end
    saveas(imgoverlay, sprintf('./result2/image-%04d-contours.eps', i), 'epsc');
    
    % second filtering
    distance = candidate(:, 2) - maxY;
    
    if any(distance >= 0)
        candidate2 = candidate(distance >= 0, :);
        [list, ~] = ismember(candidate(:, 2), candidate2(:, 2));
        contourbottom = candidate(list, 2)
        contourtop = candidate(list, 3);
        contourlength = contourbottom - contourtop;
        %contourtopX = candidate(list, 4);
        %Xdiff = abs(contourtopX - maxX);
        gap = contourtop - maxY;
        
        % third filtering
        for k = 1: size(gap)
            if gap(k) > 5 || contourlength(k) < 3 %|| Xdiff(k) > 12 
                candidate2(k, :) = nan;
            end
        end
        if all(isnan(candidate2))  == 0
            [~, ind] = max(ismember(candidate(:, 2), candidate2(:,2)));
        else 
            [~, ind] = ismember(max(distance(distance<0)), distance);
        end
        
    else
        [~, ind] = ismember(max(distance(distance<0)), distance);
        
    end
        
    maxX = candidate(ind, 1);
    maxY = candidate(ind, 2);
    cracktip = [cracktip; maxY];
    figure
    imgHandle = imshow(raw);
    hold on
    plot(maxX, maxY, 'o',...
        'markerfacecolor', 'r', 'markeredgecolor', 'r', 'markersize', 4);
    saveas(imgHandle, sprintf('./result2/image-%04d-overlay.eps', i), 'epsc');
    fclose(fid)
    close all
    %save('workspace300.mat', 'cracktip')       % save 'cracktip' only
    save('workspace_result.mat')    % save all variables
end

%% Create plot
figure
x = 1 : size(cracktip);
plot(x, cracktip, 'o');
xlabel('image number','FontSize',14);
ylabel('crack tip position (pixel)', 'FontSize',14);
%annotation(gcf,'textbox',...
    %[0.18 0.6 0.18 0.25],...
    %'String',...
    %'FontSize',14,...
    %'LineStyle','none');