clc
clear
close all

% =========================================
% induced offset in oscillating vs. flash-restricted unidirectional motion

% figure 2C
fig2c_one = 1.892 * 2;
fig2c_two = 2.4264 * 2;

% figure 3B
fig3b_one = 2.592;
fig3b_two = 4.061;

% coparison
one = (fig2c_one - fig3b_one) / fig2c_one * 100;
two = (fig2c_two - fig3b_two) / fig2c_two * 100;

disp('=== Oscillating vs Unidirectional (induced offset) ===')
fprintf('One-probe: %2.0f%% \n', one)
fprintf('Two-probe: %2.0f%% \n\n', two)

% =========================================
one = (fig3b_one-fig2c_one/2) / (fig2c_one/2) * 100;
two = (fig3b_two-fig2c_two/2) / (fig2c_two/2) * 100;

disp('=== Oscillating vs Unidirectional (peak shift) ===')
fprintf('One-probe: %2.0f%% \n', one)
fprintf('Two-probe: %2.0f%% \n\n', two)

% =========================================
two = fig3b_two / 6 * 100;

disp('=== offset report vs. mouse click ===')
fprintf('%2.0f%% \n', two)