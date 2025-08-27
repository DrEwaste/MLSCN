% Monte Carlo Simulation Code for a fixed deposit, mean return, std using
% Gaussian Distribution
%
% Given Parameters (adjustable inputs)
annual_contribution = 6000;
mean_return = 0.07;% mu = 7%
std_dev = 0.15;% sig=15%
num_years = 40;

% Initialisation
contributions = annual_contribution * ones(1, num_years);
returns = zeros(1, num_years);
year_end_values = zeros(1, num_years);
total_value = 0;

% Simulate the investment over 40 years
for i = 1:num_years
    % Generate a random annual return from a normal distribution
    % The return is centered around the mean and has the specified standard deviation
    annual_return = mean_return + std_dev * randn(); 
    returns(i) = annual_return;

    % Calculate year-end-values using compound interest formula
    total_value = (total_value + annual_contribution) * (1 + annual_return);
    year_end_values(i) = total_value;
end

% 
fprintf('Simulated Investment Results over %d Years\n', num_years);
fprintf('-----------------------------------------\n');

% 
fprintf('%-5s %-15s %-15s %-20s\n', 'Year', 'Contribution', 'Annual Return', 'Year-End Value');
for i = 1:num_years
    fprintf('%-5d $%-14.2f %-14.2f%% $%-19.2f\n', i, contributions(i), returns(i) * 100, year_end_values(i));
end

fprintf('\nFinal Value: $%.2f\n', total_value);

% Plot the year-end-values
figure;
plot(1:num_years, year_end_values, 'b-o', 'LineWidth', 2, 'MarkerFaceColor', 'b');
title('Simulated Investment Growth Over 40 Years');
xlabel('Year');
ylabel('Portfolio Value ($)');
grid off;

% Plot the interest returns
figure;
plot(1:num_years, returns, 'b-o', 'LineWidth', 2, 'MarkerFaceColor', 'b');
title('Interest returns Over 40 Years');
xlabel('Year');
ylabel('Percentage Interest ($)');
grid off;