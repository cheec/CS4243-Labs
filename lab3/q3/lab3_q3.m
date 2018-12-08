% CLARENCE CHEE KANG HUI

clc
close all
clearvars

file_names = {
    'pipe.jpg';
    'letterBox.jpg';
    'carmanBox.jpg';
    'checker.jpg';
};

for i = 1 : length(file_names)
    fig = figure;
    
    name = file_names{i};
    pic = imread(name);
    [vPic, hPic, magPic] = my_sobel(double(rgb2gray(pic)));
    
    subplot(2, 2, 1), imshow(pic);
    title('original image');
    subplot(2, 2, 2), imshow(vPic, [0 255]);
    title('vertical edges');
    subplot(2, 2, 3), imshow(hPic, [0 255]);
    title('horizontal edges');
    subplot(2, 2, 4), imshow(magPic, [0 255]);
    title('magnitude edges');
    
    print(fig, '-djpeg', name(1:find(name == '.') - 1) + "_sobel.jpg");
end

function [vPic, hPic, magPic] = my_sobel(im)
    
    v_sobel_kernel = [-1 0 1; -2 0 2; -1 0 1];
    h_sobel_kernel = [1 2 1; 0 0 0; -1 -2 -1];
    
    vPic = my_filter(v_sobel_kernel, im);
    hPic = my_filter(h_sobel_kernel, im);
    magPic = sqrt((vPic .^ 2) + (hPic .^ 2));
end

function fPic = my_filter(kernel, im)
    [rows, cols] = size(im);
    fPic = zeros(rows, cols);
    
    for r = 2 : rows - 1
        for c = 2 : cols - 1
            mul = kernel .* im(r-1:r+1, c-1:c+1);
            fPic(r, c) = sum(mul(:));
        end
    end
end


