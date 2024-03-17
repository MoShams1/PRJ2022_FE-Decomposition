clc
clear
close all

% Example data (replace with your actual data)
data = randn(100, 3);
% data(:,2) = data(:,2) + .5;
% data(:,3) = data(:,3) + 1;

% Number of bootstrap samples
num_bootstrap_samples = 1000;

% Observed differences between conditions
observed_diff = mean(data(:, 1)) - mean(data(:, 2));
observed_diff = observed_diff - mean(data(:, 2)) + mean(data(:, 3));

% Bootstrap procedure
bootstrap_diffs = zeros(1, num_bootstrap_samples);
for i = 1:num_bootstrap_samples
    % Resample with replacement
    resampled_data = datasample(data, size(data, 1), 'Replace', true);

    % Calculate differences for resampled data
    resampled_diff = mean(resampled_data(:, 1)) - mean(resampled_data(:, 2));
    resampled_diff = resampled_diff - mean(resampled_data(:, 2)) + mean(resampled_data(:, 3));

    % Store the resampled difference
    bootstrap_diffs(i) = resampled_diff;
end

% Calculate p-value
p_value = sum(abs(bootstrap_diffs) > 0) / num_bootstrap_samples * 2;

% Display results
fprintf('Observed Difference: %.4f\n', observed_diff);
fprintf('Bootstrap p-value: %.4f\n', p_value);
