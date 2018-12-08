% CLARENCE CHEE KANG HUI
if (exist("diary", "file") == 2)
    delete("diary");
end

diary on
clc
close all
clearvars

%% Q1
pts = zeros(8,3);
pts(1, :) = [-1 -1 -1];
pts(2, :) = [1 -1 -1];
pts(3, :) = [1 1 -1];
pts(4, :) = [-1 1 -1];
pts(5, :) = [-1 -1 1];
pts(6, :) = [1 -1 1];
pts(7, :) = [1 1 1];
pts(8, :) = [-1 1 1];

pts

%% Q2
cam_pos = zeros( 4, 3);
cam_pos(1, :) = [0 0 -5];

for i = 2 : 4
    cam_pos(i, :) = my_quat_rotate(cam_pos(1, :), (i - 1) * -30, [0 1 0]).';
end

for i = 1 : length(cam_pos)
    fprintf("Camera location %d\n", i);
    cam_pos(i, :)
end

%% Q3

disp("using roll, pitch and yaw representation for rotation, the computed matrices are:");
rpymat = zeros(3, 3, 4);
rpymat(:, :, 1) = eye(3);
for i = 2 : 4
    rpymat(:, :, i) = get_rpy((i - 1) * -30);
end
rpymat

disp("using quaternion representation for rotation, the computed matrices are:");
quatmat = zeros(3, 3, 4);
quatmat(:, :, 1) = eye(3);
for i = 2 : 4
    quatmat(:, :, i) = get_quat_mat((i - 1) * -30, [0 1 0]);
end
quatmat

%% Q4

nframes = 4;
npts = size(pts,1);
U = zeros(nframes, npts);
V = zeros(nframes, npts);
[u_0, v_0] = deal(0);
[B_u, B_v, focal_len] = deal(1);

% Orthographic
for i = 1 : nframes
    for j = 1 : length(pts)
        U(i, j) = (pts(j, :) - cam_pos(i, :)) * rpymat(1, :, i).' * B_u + u_0;
        V(i, j) = (pts(j, :) - cam_pos(i, :)) * rpymat(2, :, i).' * B_v + v_0;
    end
end

fig1 = figure();
plot_U_V(U, V, nframes, npts);

% Perspective
for i = 1 : nframes
    for j = 1 : length(pts)
        U(i, j) = focal_len * (pts(j, :) - cam_pos(i, :)) * rpymat(1, :, i).' * B_u ...
            / ((pts(j, :) - cam_pos(i, :)) * rpymat(3, :, i).') ...
            + u_0;
        V(i, j) = focal_len * (pts(j, :) - cam_pos(i, :)) * rpymat(2, :, i).' * B_v ...
            / ((pts(j, :) - cam_pos(i, :)) * rpymat(3, :, i).') ...
            + v_0;
    end
end

fig2 = figure();
plot_U_V(U, V, nframes, npts);

print('-dpng', fig1, 'orthographic.png');
print('-dpng', fig2, 'perspective.png');

%% Q5

fr = 3;
H = zeros(8, 9);
for i = 1 : length(pts(1:4))
    u_p = pts(i, 1) / pts(i, 3);
    v_p = pts(i, 2) / pts(i, 3);
    u_c = U(fr, i) / focal_len;
    v_c = V(fr, i) / focal_len;
    H(i * 2 - 1, :) = [u_p, v_p, 1, 0, 0, 0, -u_c * u_p, -u_c * v_p, -u_c];
    H(i * 2, :)     = [0, 0, 0, u_p, v_p, 1, -v_c * u_p, -v_c * v_p, -v_c];
end

[~, ~, svd_V] = svd(H);
H = reshape(svd_V(:, end), 3, 3).'; % last column because we transpose it
disp("Homography matrix before normalization of H_33:")
H
disp("Homography matrix after normalization of H_33:")
H / H(end) % normalize by H_33

diary off
%% Helper Functions

function plot_U_V(U, V, nframes, npts)
for fr = 1 : nframes
    subplot(2, 2, fr), plot(U(fr,:), V(fr,:), '*');
    str = sprintf("Frame %d", fr);
    title(str);
    for p = 1 : npts
        text(U(fr, p) + 0.02, V(fr, p) + 0.02, num2str(p));
    end
end
end

function new_pos = my_quat_rotate(start, deg, w)
ang_rad = deg / 180 * pi;
new_pos = start * cos(ang_rad) ...
    + dot(start, w) * (w * (1 - cos(ang_rad))) ...
    + cross(w, start) * sin(ang_rad);
end

function rpy = get_rpy(deg)
ang_rad = deg / 180 * pi;
% only rotating about y-axis i.e. yaw non-zero but pitch, roll zero
% thus simplifying the matrix a lot as sin(0) = 0 and cos(0) = 1
rpy(1, :) = [cos(ang_rad) 0 sin(ang_rad)];
rpy(2, :) = [0 1 0];
rpy(3, :) = [-sin(ang_rad) 0 cos(ang_rad)];
end

function qmat = get_quat_mat(deg, w)
ang_rad = deg / 180 * pi;
q = [cos(ang_rad / 2), sin(ang_rad / 2) .* w];
qmat(1, :) = [q(1) * q(1) + q(2) * q(2) - q(3) * q(3) - q(4) * q(4), 2 * (q(2) * q(3) - q(1) * q(4)), 2 * (q(2) * q(4) + q(1) * q(3))];
qmat(2, :) = [2 * (q(2) * q(3) + q(1) * q(4)), q(1) * q(1) + q(3) * q(3) - q(2) * q(2) - q(4) * q(4),  2 * (q(3) * q(4) - q(1) * q(2))];
qmat(3, :) = [2 * (q(2) * q(4) - q(1) * q(3)), 2 * (q(3) * q(4) + q(1) * q(2)), q(1) * q(1) + q(4) * q(4) - q(2) * q(2) - q(3) * q(3)];
end