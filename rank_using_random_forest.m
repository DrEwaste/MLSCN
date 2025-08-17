% Matlab code using random forest to rank variables from a dataset 
% for which the first 23 columns represent independent variables 
% and the last 13 columns represent dependent variables. 
% Display relative contributions in percentages in descending order 
% and save the output as an xls file. 
% Also rank the top 5 independent variables for each of the top 
% 5 dependent variables.
% Load the data from the Excel spreadsheet
data = xlsread('data_new.xlsx'); 

% Define X and Y
X = data(:, 1:23); % Independent variables
Y = data(:, 24:end); % Dependent variables

% Initialize matrices to store percentage contributions and importance
percentContributions = zeros(size(X, 2), size(Y, 2));
meanImportance = zeros(1, size(Y, 2));

% Train Random Forest models and compute predictor importance
for i = 1:size(Y, 2)
    % Build Random Forest model for the current dependent variable
    rf = fitcensemble(X, Y(:, i), 'Method', 'Bag', 'NumLearningCycles', 100, 'Learner', 'tree');
    
    % Get the importance of each predictor
    importance = rf.predictorImportance;
    
    % Calculate the percentage contribution of each variable
    contributionPercentages = (importance / sum(importance)) * 100;
    
    % Store the percentage contributions
    percentContributions(:, i) = contributionPercentages;
    
    % Calculate mean importance for ranking dependent variables
    meanImportance(i) = mean(contributionPercentages);
end

% Rank the dependent variables based on their mean importance
[~, top5DependentIndices] = maxk(meanImportance, 5); % Top 5 dependent variable indices

% Initialize matrix to store the top 5 independent variables for each of the top 5 dependent variables
sortedContributions = zeros(5, 5);

% Create figures to visualize the top 5 independent variables for each top 5 dependent variable
for i = 1:5
    depIdx = top5DependentIndices(i);
    [sortedValues, rankOrder] = sort(percentContributions(:, depIdx), 'descend');
    top5Indices = rankOrder(1:5);
    top5Values = sortedValues(1:5);
    
    % Plot the top 5 independent variables
    figure;
    bar(top5Values);
    set(gca, 'XTickLabel', strcat('X', string(top5Indices)));
    title(['Top 5 Independent Variables for Dependent Variable Y' num2str(depIdx)]);
    xlabel('Independent Variables');
    ylabel('Importance (%)');
    xtickangle(45); % Rotate x-axis labels for better readability
    saveas(gcf, sprintf('Top5_Independent_Variables_Y%d.png', depIdx));
end

% Rank the dependent variables based on their mean importance
[~, sortedDepIndices] = sort(meanImportance, 'descend');
top5DepIndices = sortedDepIndices(1:5);
top5DepValues = meanImportance(top5DepIndices);

% Create a figure to visualize the top 5 dependent variables based on their mean importance
figure;
bar(top5DepValues);
set(gca, 'XTickLabel', strcat('Y', string(top5DepIndices)));
title('Top 5 Dependent Variables Based on Mean Importance');
xlabel('Dependent Variables');
ylabel('Mean Importance (%)');
xtickangle(45); % Rotate x-axis labels for better readability
saveas(gcf, 'Top5_Dependent_Variables.png');

% Create a table with ranked variables and their contributions
variableNames = strcat('X', string(1:23)); % Independent variables
dependentNames = strcat('Y', string(1:size(Y, 2))); % Dependent variables

% Prepare output data for the top 5 dependent variables
outputData = zeros(5, size(X, 2)); % 5 top dependent variables, all independent variables
for i = 1:5
    depIdx = top5DependentIndices(i);
    outputData(i, :) = percentContributions(:, depIdx)';
end

% Create and save the results table
outputTable = array2table(outputData, 'RowNames', strcat('Y', string(top5DependentIndices)), 'VariableNames', variableNames);
writetable(outputTable, 'RandomForest_Variable_Contributions.xlsx', 'WriteRowNames', true);

disp('Plots and excel file have been saved.');
