% CLARENCE CHEE KANG HUI

clc
close all
clearvars

FNames = {
    'meteora_gray.jpg';
    'penang_hill_gray.jpg';
    'foggy_carpark_gray.jpg';
};

enable_task_2 = true;

for p = 1 : size(FNames)
    figH = figure;
    
    pic = imread(FNames{p});
    if enable_task_2
        pic = pic(round(size(pic, 1) / 2):end, :); % crop top halves away
    end
    
    [hPic, h_before, h_after, c_before, c_after] = my_hist_eq(pic, 256);
    
    subplot(3,2,1), imshow(pic, [0 255]);
    title('original image');
    subplot(3,2,2), imshow(hPic, [0 255]);
    title('hist equalized image');
    subplot(3,2,3), plot(h_before);
    title('original histogram');
    subplot(3,2,4), plot(h_after);
    title('equalized hist');
    subplot(3,2,5), plot(c_before);
    title('original cumu hist');
    subplot(3,2,6), plot(c_after);
    title('equalized cumu hist');
    
    baseName = FNames{p}(1:find(FNames{p}=='.')-1);
    extension = '_histogram_eq_results';
    if enable_task_2
        extension = strcat(extension, '_task_2.jpg');
    else
        extension = strcat(extension, '.jpg');
    end
    
    figName = strcat(baseName, extension);
    print(figH, '-djpeg', figName);
end

% performs a histogram equalization on `im`
function [hPic, h_before, h_after, c_before, c_after] = my_hist_eq(im, bins)

[rows, cols] = size(im);
num_pix = rows * cols;

h_before = zeros(bins, 1);

% generating histogram
for r = 1 : rows
    for c = 1 : cols
        grayscale = im(r, c);
        h_before(grayscale + 1) = h_before(grayscale + 1) + 1;
    end
end

c_before = my_cummulate(h_before); % cummulative histogram
interval = num_pix / bins; % no. pix per bucket

hPic = zeros(rows, cols);
h_after = zeros(bins, 1);

% re-mapping intensities to buckets
for r = 1 : rows
    for c = 1 : cols
        h_grayscale = ceil(c_before(im(r, c) + 1) / interval) - 1;
        hPic(r, c) = h_grayscale;
        % generating new histogram
        h_after(h_grayscale + 1) = h_after(h_grayscale + 1) + 1;
    end
end

c_after = my_cummulate(h_after); % new cummulative histogram

end

% a helper function to create a cummulative sum array
function out = my_cummulate(arr)
out = arr;
for i = 2 : length(arr)
    out(i) = out(i - 1) + arr(i);
end
end
