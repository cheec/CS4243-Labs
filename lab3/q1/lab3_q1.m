% CLARENCE CHEE KANG HUI

clc
close all
clearvars

% first set of grayscales cutoff thresholds is for full pic
% second set is for cropped bottom half
FNames = {
    'meteora_gray.jpg' [20 220] [10 200];
    'penang_hill_gray.jpg' [10 190] [0 180];
    'foggy_carpark_gray.jpg' [45, 210] [43 160];
};

crop_top = false; % change to true/false to see cropped/uncropped
for i = 1 : 2
    for p = 1 : size(FNames)
        figH = figure;
        
        name = FNames{p, 1};
        thresholds = FNames{p, 2};
        
        pic = imread(name);
        
        if crop_top
            pic = pic(round(size(pic, 1) / 2):end, :); % crop top halves away
            thresholds = FNames{p, 3};
        end
        
        [hPic, h_before, h_after] = my_contrast_stretch(pic, thresholds);
        
        subplot(3,2,1), imshow(pic, [0 255]);
        title('original image');
        subplot(3,2,2), imshow(hPic, [0 255]);
        title('contrast stretched image');
        subplot(3,2,3), plot(h_before);
        title('original histogram');
        subplot(3,2,4), plot(h_after);
        title('contrast stretched hist');
        
        baseName = name(1:find(name == '.') - 1);
        extension = '_c_stretch_results';
        if crop_top
            extension = strcat(extension, '_top_cropped.jpg');
        else
            extension = strcat(extension, '.jpg');
        end
        
        figName = strcat(baseName, extension);
        print(figH, '-djpeg', figName);
    end
    crop_top = true;
end

% performs a contrast stretch on `im`
function [hPic, h_before, h_after] = my_contrast_stretch(im, thresholds)

[rows, cols] = size(im);

h_before = zeros(256, 1);
h_after = zeros(256, 1);
hPic = zeros(rows, cols);

lower_gray = thresholds(1);
upper_gray = thresholds(2);

cutoff_interval = upper_gray - lower_gray;

for r = 1 : rows
    for c = 1 : cols
        grayscale = im(r, c);
        
        % pixels not within cutoff range are clamped at 0 or 255
        % respectively
        if grayscale >= lower_gray && grayscale <= upper_gray
            hPic(r, c) = round(255 * double(grayscale - lower_gray) / cutoff_interval);
        elseif grayscale > upper_gray
            hPic(r, c) = 255;
        end
        
        h_before(grayscale + 1) = h_before(grayscale + 1) + 1;
        h_after(hPic(r, c) + 1) = h_after(hPic(r, c) + 1) + 1;
    end
end

end