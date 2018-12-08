% CLARENCE CHEE KANG HUI

close all
clc
clearvars

file_names = {
    'pipe.jpg';
    'letterBox.jpg';
    'carmanBox.jpg';
    'checker.jpg';
};

for i = 1 : length(file_names)
    name = file_names{i};
    rgb_pic = imread(name);
    pic = rgb2gray(rgb_pic);
    
    Ix = zeros(size(pic));    
    Iy = zeros(size(pic));
    
    Iy(2:end, :) = pic(2:end, :) - pic(1:end-1, :);
    Ix(:, 2:end) = pic(:, 2:end) - pic(:, 1:end-1);
    
    eig_min = [];
    eig_min_xy = {};
    
    for r = 7 : 7 : size(pic, 1) - 7
        for c = 7 : 7 : size(pic, 2) - 7
            Ix_2 = Ix(r-6:r+6, c-6:c+6) .* Ix(r-6:r+6, c-6:c+6);
            Ix_Iy = Ix(r-6:r+6, c-6:c+6) .* Iy(r-6:r+6, c-6:c+6);
            Iy_2 = Iy(r-6:r+6, c-6:c+6) .* Iy(r-6:r+6, c-6:c+6);
            
            A = [sum(Ix_2(:)), sum(Ix_Iy(:)); sum(Ix_Iy(:)), sum(Iy_2(:))];
           
            % appending eigenvalue and coordinate
            eig_min(end + 1) = min(eig(A));
            eig_min_xy{end + 1} = [c, r];
        end
    end
    
    [~, I] = sort(eig_min);
    sorted_eig_min_xy = eig_min_xy(I);
    top_eig_xy = sorted_eig_min_xy(end-199:end);
    
    fig = figure;
    imshow(rgb_pic);
    
    for j = 1 : length(top_eig_xy)
        rectangle('Position', [top_eig_xy{j} - 6, 13, 13], 'EdgeColor', 'r', 'LineWidth', 1);
    end
    
    print(fig, '-dpng',  name(1:find(name == '.') - 1) + "_corners.png")
end
