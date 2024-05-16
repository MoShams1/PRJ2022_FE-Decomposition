clc
clear
close all

load fig2C.mat
load fig3B.mat

% =========================================
% induced offset in oscillating vs. flash-restricted unidirectional motion

% figure 2C
fig2c_one = one_probe_err_pooled .* 2;
fig2c_two = two_probe_err_pooled .* 2;

% figure 3B
fig3b_one = one_probe_dist;
fig3b_two = two_probe_dist;

% comparison
one = (fig2c_one - fig3b_one) ./ fig2c_one .* 100;
two = (fig2c_two - fig3b_two) ./ fig2c_two .* 100;

disp('=== Oscillating vs Unidirectional (induced offset) ===')
fprintf('median difference in One-probe: %2.0f%% \n', median(one))
fprintf('median difference in Two-probe: %2.0f%% \n\n', median(two))

% =========================================
% one = (fig3b_one-fig2c_one/2) ./ (fig2c_one./2) .* 100;
% two = (fig3b_two-fig2c_two/2) ./ (fig2c_two./2) .* 100;
% 
% disp('=== Oscillating vs Unidirectional (peak shift) ===')
% fprintf('median difference in One-probe: %2.0f%% \n', median(one))
% fprintf('median difference in Two-probe: %2.0f%% \n\n', median(two))

% =========================================
osc_two = median((fig2c_two./2) ./ 6 .* 100);
uni_lead = median(lead2 ./ 6 .* 100);
uni_trail = median(trail2 ./ 6 .* 100);

fprintf('median shift in oscillating frame: %2.0f%%\n', osc_two)
fprintf('median shift of Initiating probe in unidirectional frame: %2.0f%%\n', uni_lead)
fprintf('median shift of Terminating probe in unidirectional frame: %2.0f%%\n', uni_trail)

