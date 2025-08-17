% Matlab code using Neural Network to rank variables from a dataset 
% for which the first 23 columns represent independent variables 
% and the last 13 columns represent dependent variables. 
% Display relative contributions in percentages in descending order 
% and save the output as an xls file. 
% Also rank the top 5 independent variables for each of the top 
% 5 dependent variables.
% Load the data from the Excel spreadsheet
data = xlsread('data_new.xlsx'); 

% Define X and Y
X = data(:, 24:end); % Independent variables (last 13 columns)
Y = data(:, 1:23); % Dependent variables (first 23 columns)

% Check for and handle missing values
if any(isnan(X(:))) || any(isnan(Y(:)))
    disp('Handling missing values: removing rows with NaNs.');
    % Remove rows with NaN values
    validRows = ~any(isnan([X Y]), 2);
    X = X(validRows, :);
    Y = Y(validRows, :);
end

% Initialize variables
numDepVars = size(Y, 2);
numIndepVars = size(X, 2);
importanceResults = zeros(numDepVars, numIndepVars);

% Train a neural network for each dependent variable
for i = 1:numDepVars
    % Define neural network architecture
    net = feedforwardnet([10, 10]); % Example: two hidden layers with 10 neurons each
    net = configure(net, X', Y(:, i)');
    net.trainParam.epochs = 100;
    net.trainParam.lr = 0.01;
    net.trainParam.mc = 0.9;
    net = train(net, X', Y(:, i)');
    
    % Compute permutation importance
    [~, permImportance] = permutationImportance(net, X, Y(:, i));
    importanceResults(i, :) = permImportance';
end

% Compute average importance for each dependent variable
avgImportance = mean(importanceResults, 2);

% Rank dependent variables based on their average importance
[~, rankedIndices] = sort(avgImportance, 'descend');
topDepVarsIndices = rankedIndices(1:5); % Top 5 dependent variables

% Create figure for plots
figure;

% Plot importance for top 5 dependent variables
for i = 1:length(topDepVarsIndices)
    depIdx = topDepVarsIndices(i);
    subplot(2, 3, i);
    bar(importanceResults(depIdx, :));
    title(['Importance for Dependent Variable ', num2str(depIdx)]);
    xlabel('Independent Variables');
    ylabel('Importance');
end

% Save importance plots
saveas(gcf, 'Dependent_Variable_Importance.png');

% Calculate correlation strength
correlations = zeros(numDepVars, numIndepVars);
for i = 1:numDepVars
    correlations(i, :) = corr(X, Y(:, i));
end

% Plot correlation matrix
figure;
imagesc(correlations);
colorbar;
title('Correlation Between Dependent and Independent Variables');
xlabel('Independent Variables');
ylabel('Dependent Variables');
saveas(gcf, 'Correlation_Matrix.png');

% Prepare data for Excel
topVariables = strcat('Variable', string(1:numIndepVars));
outputTable = cell(numDepVars + 1, numIndepVars + 1); % Adjust size to fit headers and data

% Add headers
outputTable{1, 1} = 'Dependent Variable';
for j = 1:numIndepVars
    outputTable{1, j + 1} = topVariables{j}; % Assign headers individually
end

% Fill in data
for i = 1:numDepVars
    outputTable{i + 1, 1} = ['Dep Var ', num2str(i)];
    for j = 1:numIndepVars
        outputTable{i + 1, j + 1} = importanceResults(i, j); % Assign data individually
    end
end

% Save to Excel
xlswrite('Dependent_Variable_Importance.xlsx', outputTable);

disp('Plots and excel file have been saved.');

% Define permutation importance function
function [importance, permImportance] = permutationImportance(net, X, Y)
    % Compute the baseline performance
    baselinePerformance = perform(net, X', Y');
    
    % Initialize importance scores
    permImportance = zeros(size(X, 2), 1);
    
    for j = 1:size(X, 2)
        % Permute the j-th feature
        X_perm = X;
        X_perm(:, j) = X(randperm(size(X, 1)), j);
        
        % Compute the performance with permuted feature
        permPerformance = perform(net, X_perm', Y');
        
        % Importance is the decrease in performance
        permImportance(j) = baselinePerformance - permPerformance;
    end
    
    % Normalize importance scores
    importance = permImportance / sum(permImportance);
end

% % Define X and Y
% X = data(:, 24:end); % Independent variables (last 13 columns)
% Y = data(:, 1:23); % Dependent variables (first 23 columns)
% 
% % Check for and handle missing values
% if any(isnan(X(:))) || any(isnan(Y(:)))
%     disp('Handling missing values: removing rows with NaNs.');
%     % Remove rows with NaN values
%     validRows = ~any(isnan([X Y]), 2);
%     X = X(validRows, :);
%     Y = Y(validRows, :);
% end
% 
% % Initialize variables
% numDepVars = size(Y, 2);
% numIndepVars = size(X, 2);
% importanceResults = zeros(numDepVars, numIndepVars);
% 
% % Train a neural network for each dependent variable
% for i = 1:numDepVars
%     % Define neural network architecture
%     net = feedforwardnet([10, 10]); % Example: two hidden layers with 10 neurons each
%     net = configure(net, X', Y(:, i)');
%     net.trainParam.epochs = 100;
%     net.trainParam.lr = 0.01;
%     net.trainParam.mc = 0.9;
%     net = train(net, X', Y(:, i)');
% 
%     % Compute permutation importance
%     [~, permImportance] = permutationImportance(net, X, Y(:, i));
%     importanceResults(i, :) = permImportance';
% end
% 
% % Compute average importance for each dependent variable
% avgImportance = mean(importanceResults, 2);
% 
% % Rank dependent variables based on their average importance
% [~, rankedIndices] = sort(avgImportance, 'descend');
% topDepVarsIndices = rankedIndices(1:5); % Top 5 dependent variables
% 
% % Create figure for plots
% figure;
% 
% % Plot importance for top 5 dependent variables
% for i = 1:length(topDepVarsIndices)
%     depIdx = topDepVarsIndices(i);
%     subplot(2, 3, i);
%     bar(importanceResults(depIdx, :));
%     title(['Importance for Dependent Variable ', num2str(depIdx)]);
%     xlabel('Independent Variables');
%     ylabel('Importance');
% end
% 
% % Save importance plots
% saveas(gcf, 'Dependent_Variable_Importance.png');
% 
% % Calculate correlation strength
% correlations = zeros(numDepVars, numIndepVars);
% for i = 1:numDepVars
%     correlations(i, :) = corr(X, Y(:, i));
% end
% 
% % Plot correlation matrix
% figure;
% imagesc(correlations);
% colorbar;
% title('Correlation Between Dependent and Independent Variables');
% xlabel('Independent Variables');
% ylabel('Dependent Variables');
% saveas(gcf, 'Correlation_Matrix.png');
% 
% % Prepare data for Excel
% topVariables = strcat('Variable', string(1:numIndepVars));
% outputTable = cell(numDepVars, numIndepVars + 1);
% 
% % Add headers
% outputTable{1, 1} = 'Dependent Variable';
% outputTable{1, 2:end} = topVariables;
% 
% % Fill in data
% for i = 1:numDepVars
%     outputTable{i + 1, 1} = ['Dep Var ', num2str(i)];
%     outputTable{i + 1, 2:end} = importanceResults(i, :);
% end
% 
% % Save to Excel
% xlswrite('Dependent_Variable_Importance.xlsx', outputTable);
% 
% disp('Plots and excel file have been saved.');
% 
% % Define permutation importance function
% function [importance, permImportance] = permutationImportance(net, X, Y)
%     % Compute the baseline performance
%     baselinePerformance = perform(net, X', Y');
% 
%     % Initialize importance scores
%     permImportance = zeros(size(X, 2), 1);
% 
%     for j = 1:size(X, 2)
%         % Permute the j-th feature
%         X_perm = X;
%         X_perm(:, j) = X(randperm(size(X, 1)), j);
% 
%         % Compute the performance with permuted feature
%         permPerformance = perform(net, X_perm', Y');
% 
%         % Importance is the decrease in performance
%         permImportance(j) = baselinePerformance - permPerformance;
%     end
% 
%     % Normalize importance scores
%     importance = permImportance / sum(permImportance);
%end