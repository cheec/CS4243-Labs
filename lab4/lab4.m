% CLARENCE CHEE KANG HUI

clc
close all
clearvars
diary on

vid = VideoReader('traffic.mp4')
num_frames = ceil(vid.Duration * vid.FrameRate);
frame = readFrame(vid);
frame_idx = 2;

first_frame = frame; % save first frame

RGB_avg = double(first_frame);
RGB_freq = zeros(vid.Height, vid.Width, 256, 3);
RGB_freq(1, 1, first_frame(1, 1, :), :) = RGB_freq(1, 1, first_frame(1, 1, :), :) + 1;

%% Step 3: getting background by incremental average/median/mode
disp("Estimating background...")
while hasFrame(vid)
    frame = readFrame(vid);
    for r = 1 : vid.Height
        for c = 1 : vid.Width
            for i = 1 : 3
                val = double(frame(r, c, i));
                
                % using incremental average technique
                RGB_avg(r, c, i) = my_inc_avg( ...
                    frame_idx, ...
                    RGB_avg(r, c, i), ...
                    val ...
                );
            
                % counting RGB frequencies for mode/median
                RGB_freq(r, c, val + 1, i) = RGB_freq(r, c, val + 1, i) + 1;
            end
        end
    end
    frame_idx = frame_idx + 1;
end

% Computing mode and median background out of curiosity 
mode_background = zeros(vid.Height, vid.Width, 3);
med_background = zeros(vid.Height, vid.Width, 3);

for r = 1 : vid.Height
    for c = 1 : vid.Width
        mode_background(r, c, :) = [
            my_mode(RGB_freq(r, c, :, 1)) - 1
            my_mode(RGB_freq(r, c, :, 2)) - 1
            my_mode(RGB_freq(r, c, :, 3)) - 1
        ];
        med_background(r, c, :) = [
            my_med(RGB_freq(r, c, :, 1), num_frames) - 1
            my_med(RGB_freq(r, c, :, 2), num_frames) - 1
            my_med(RGB_freq(r, c, :, 3), num_frames) - 1
        ];
    end
end

% converting to 8-bit ints
med_background = uint8(med_background); 
mode_background = uint8(mode_background);
avg_background = uint8(RGB_avg);

fig = figure;

subplot(3, 3, 1); imshow(avg_background);
title("average BG");

subplot(3, 3, 2); imshow(mode_background);
title("mode BG");

subplot(3, 3, 3); imshow(med_background);
title("median BG");

imwrite(avg_background, 'step3_avg_bg.png');
imwrite(mode_background, 'step3_mode_bg.png');
imwrite(med_background, 'step3_med_bg.png');

%% Step 4: getting foreground from first and last frame
disp("Subtracting background to get foreground...")

avg_foreground_first = my_fg_extract(first_frame, avg_background, 50);
subplot(3, 3, 4); imshow(avg_foreground_first);
title("subtracted average bg - first");
imwrite(avg_foreground_first, 'step4_avg_fg_first.png');

mode_foreground_first = my_fg_extract(first_frame, mode_background, 35);
subplot(3, 3, 5); imshow(mode_foreground_first);
title("subtracted mode bg - first");
imwrite(mode_foreground_first, 'step4_mode_fg_first.png');

med_foreground_first = my_fg_extract(first_frame, med_background, 35);
subplot(3, 3, 6); imshow(med_foreground_first);
title("subtracted med bg - first");
imwrite(med_foreground_first, 'step4_med_fg_first.png');

% `frame` holds the last frame
avg_foreground_last = my_fg_extract(frame, avg_background, 45);
subplot(3, 3, 7); imshow(avg_foreground_last);
title("subtracted average bg - last");
imwrite(avg_foreground_last, 'step4_avg_fg_last.png');

mode_foreground_last = my_fg_extract(frame, mode_background, 30);
subplot(3, 3, 8); imshow(mode_foreground_last);
title("subtracted mode bg - last");
imwrite(mode_foreground_last, 'step4_mode_fg_last.png');

med_foreground_last = my_fg_extract(frame, med_background, 30);
subplot(3, 3, 9); imshow(med_foreground_last);
title("subtracted med bg - last");
imwrite(med_foreground_last, 'step4_med_fg_last.png');

print(fig, '-dpng', "step4_all.png");

%% Step 5: Counting cars/bikes

disp("Counting cars/bikes...");

car_count = 0;

vid.CurrentTime = 0; % restart the video

% l1/2/3 is a flag set when there is a car in the lane
% l1/2/3_prev is the previous value of l1/2/3 by the previous frame
% l1/2/3_no_car_cnt counts the number of frames that encounter a
%   background, if we hit `no_car_threshold` frames, we deem that the car
%   has successfully driven by.
% Initialize all to zero with `deal(0)`
[l1, l1_prev, l2, l2_prev, l3, l3_prev, ...
    l1_no_car_cnt, l2_no_car_cnt, l3_no_car_cnt] = deal(0);

% hard-coded pixel locations of each lane
lane1 = 1:122;
lane2 = 145:315;
lane3 = 346:640;

% if lane encounters `no_car_threshold` number of frames of background,
% then we deem that the car has driven by and we reset the l1/2/3 flags.
no_car_threshold = 8;

% the car counting algo works by just looking at the bottom row of pixels
% and checking if there's any movement in the following lanes.
while hasFrame(vid)
    frame = readFrame(vid);
    
    % extract foreground of bottom row of pixels -> convert to binary
    fg = uint8(rgb2gray( ...
        my_fg_extract(frame(end, :, :), avg_background(end, :, :), 30)) > 0);
    
    % Lane 1
    if contains_car(fg(lane1))
        l1 = 1;
        l1_no_car_cnt = 0;
    elseif l1_no_car_cnt == no_car_threshold
        l1 = 0;
        l1_no_car_cnt = 0;
    else
        l1_no_car_cnt = l1_no_car_cnt + 1;
    end
    
    % Lane 2
    if contains_car(fg(lane2))
        l2 = 1;
        l2_no_car_cnt = 0;
    elseif l2_no_car_cnt == no_car_threshold
        l2_no_car_cnt = 0;
        l2 = 0;
    else
        l2_no_car_cnt = l2_no_car_cnt + 1;
    end
    
    % Lane 3
    if contains_car(fg(lane3))
        l3 = 1;
        l3_no_car_cnt = 0;
    elseif l3_no_car_cnt == no_car_threshold
        l3_no_car_cnt = 0;
        l3 = 0;
    else
        l3_no_car_cnt = l3_no_car_cnt + 1;
    end
    
    % we increment count when the previous frame had no car, but this frame
    % now has a car for each lane.
    car_count = car_count + (~l1_prev && l1) + (~l2_prev && l2) + (~l3_prev && l3);
    
    fprintf("Current car/bike count: %d\n", car_count);

    % to store previous values of l1/2/3
    [l1_prev, l2_prev, l3_prev] = deal(l1, l2, l3);
end

disp("===========================");
fprintf("Total number of cars/bikes that touched bottom of video: %d\n", car_count);
disp("===========================");

diary off

%% Helper Functions

function is_car = contains_car(lane)
is_car = sum(lane(:)) > 10; % if 10 pixels are '1', we treat this as a car
end

% foreground extraction by subtracting background above a threshold
function fg = my_fg_extract(pic, bg, threshold)
fg = pic .* uint8(abs(pic - bg) > threshold);
end

% incremental average method to avoid overflow
function M_k = my_inc_avg(k, M_k_prev, R_k)
M_k = (R_k / k) + ((k - 1) / k) * M_k_prev;
end

% returns the index of the median of the array
function med_idx = my_med(arr, num_frames)
curr_sum = 0;
for i = 1 : length(arr)
    curr_sum = curr_sum + arr(i);
    if curr_sum >= (num_frames / 2)
        med_idx = i;
        break
    end
end
end

% returns the index of the mode of the frequency array
function mode_idx = my_mode(arr)
modes = find(arr == max(arr));
mode_idx = modes(1);
end