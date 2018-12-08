% CLARENCE CHEE KANG HUI

clc 
close all
clearvars

h = [-1 0 1 0 0 0 0 0 0 0];
x = [5 5 5 5 5 0 0 0 0 0];

results = figure;

paddedH  = [zeros(1,9) h];
paddedX  = [zeros(1,9) x];
flippedH = [fliplr(h) zeros(1,9)];

subplot(4,1,1), stem([-9:9], paddedH, 'k'), title('h');
subplot(4,1,2), stem([-9:9], paddedX, 'r'), title('x');
subplot(4,1,3), stem([-9:9], flippedH, 'b'), title('h flipped');

% to implement the convolution equation  g[m] = sum_t ( x[m-t]*h[t] )

conv_result = zeros(1,19);

temp = flippedH;

for m = 0 : 9
    
    csum = sum(paddedX .* temp);
    conv_result(m+10) = csum;
    
    subplot(4,1,4), stem([-9:9], conv_result, 'k'), title('convolution result');
   
    pause(.5)
    
    temp = [0 temp(1:length(temp)-1)];
    subplot(4,1,3), stem([-9:9], temp, 'b'), ylim([min(h) max(h)]), title('h flipped');
    
end


print(results, '-djpeg', "conv_results_q2");



