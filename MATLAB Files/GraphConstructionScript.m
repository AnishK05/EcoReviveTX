%% Load the dataset and remove rows with NaN values
data = readtable('EcologicalRestoration_FinalDataset.csv');
data = rmmissing(data); % Remove rows with NaN values
disp(head(data));

%% Extract unique values for RestorationTime and Ecosystem
restorationTimes = unique(data.RestorationTime_years_);
ecosystems = unique(data.Ecosystem);

% Initialize variables to store statistics
mean_lnRR_SOC = zeros(length(restorationTimes), length(ecosystems));
mean_lnRR_TN = zeros(length(restorationTimes), length(ecosystems));
mean_lnRR_TP = zeros(length(restorationTimes), length(ecosystems));

std_lnRR_SOC = zeros(length(restorationTimes), length(ecosystems));
std_lnRR_TN = zeros(length(restorationTimes), length(ecosystems));
std_lnRR_TP = zeros(length(restorationTimes), length(ecosystems));

n = zeros(length(restorationTimes), length(ecosystems)); % Sample counts

% Calculate statistics for each group
for i = 1:length(restorationTimes)
    for j = 1:length(ecosystems)
        % Filter data for the current group
        groupData = data(data.RestorationTime_years_ == restorationTimes(i) & ...
                         strcmp(data.Ecosystem, ecosystems{j}), :);
        
        if ~isempty(groupData)
            % Calculate mean and standard deviation
            mean_lnRR_SOC(i, j) = mean(groupData.lnRR_SOC, 'omitnan');
            mean_lnRR_TN(i, j) = mean(groupData.lnRR_TN, 'omitnan');
            mean_lnRR_TP(i, j) = mean(groupData.lnRR_TP, 'omitnan');
            
            std_lnRR_SOC(i, j) = std(groupData.lnRR_SOC, 'omitnan');
            std_lnRR_TN(i, j) = std(groupData.lnRR_TN, 'omitnan');
            std_lnRR_TP(i, j) = std(groupData.lnRR_TP, 'omitnan');
            
            n(i, j) = height(groupData);
        end
    end
end

% Calculate standard errors
stdErr_lnRR_SOC = std_lnRR_SOC ./ sqrt(n);
stdErr_lnRR_TN = std_lnRR_TN ./ sqrt(n);
stdErr_lnRR_TP = std_lnRR_TP ./ sqrt(n);

%% Line plot of average lnRR.SOC, lnRR.TN, and lnRR.TP over restoration time for each ecosystem
figure;
hold on;

colors = lines(3);

for j = 1:length(ecosystems)
    % Plot average lnRR.SOC with error bars for the current ecosystem
    errorbar(restorationTimes, mean_lnRR_SOC(:, j), stdErr_lnRR_SOC(:, j), ...
             'o-', 'DisplayName', ['SOC - ' ecosystems{j}], 'Color', colors(1, :));

    % Plot average lnRR.TN with error bars
    errorbar(restorationTimes, mean_lnRR_TN(:, j), stdErr_lnRR_TN(:, j), ...
             's-', 'DisplayName', ['TN - ' ecosystems{j}], 'Color', colors(2, :));

    % Plot average lnRR.TP with error bars
    errorbar(restorationTimes, mean_lnRR_TP(:, j), stdErr_lnRR_TP(:, j), ...
             'd-', 'DisplayName', ['TP - ' ecosystems{j}], 'Color', colors(3, :));
end

xlabel('Restoration Time (years)');
ylabel('Average lnRR');
title('Average lnRR of SOC, TN, and TP Over Restoration Time by Ecosystem');
legend('show');
grid on;
hold off;

% Save the figure
saveas(gcf, '1. Average_lnRR_Over_Restoration_Time_by_Ecosystem.png');

%% Visualizing the effect of Climate on lnRR metrics with error bars
climateGroups = unique(data.Climate);

% Preallocate for average values and standard errors
averageLnRRSOCClimates = zeros(length(climateGroups), 1);
averageLnRRTNClimates = zeros(length(climateGroups), 1);
averageLnRRTPClimates = zeros(length(climateGroups), 1);
stdErrLnRRSOC = zeros(length(climateGroups), 1);
stdErrLnRRTN = zeros(length(climateGroups), 1);
stdErrLnRRTP = zeros(length(climateGroups), 1);

for i = 1:length(climateGroups)
    climateData = data(strcmp(data.Climate, climateGroups{i}), :);
    averageLnRRSOCClimates(i) = mean(climateData.lnRR_SOC, 'omitnan');
    averageLnRRTNClimates(i) = mean(climateData.lnRR_TN, 'omitnan');
    averageLnRRTPClimates(i) = mean(climateData.lnRR_TP, 'omitnan');
    
    stdErrLnRRSOC(i) = std(climateData.lnRR_SOC, 'omitnan') / sqrt(size(climateData, 1));
    stdErrLnRRTN(i) = std(climateData.lnRR_TN, 'omitnan') / sqrt(size(climateData, 1));
    stdErrLnRRTP(i) = std(climateData.lnRR_TP, 'omitnan') / sqrt(size(climateData, 1));
end

% Create a bar graph to visualize average lnRR by climate type with error bars
figure;
barData = [averageLnRRSOCClimates, averageLnRRTNClimates, averageLnRRTPClimates];
barHandle = bar(barData);
set(gca, 'XTickLabel', climateGroups);
xlabel('Climate Types');
ylabel('Average lnRR');
title('Average lnRR of SOC, TN, and TP by Climate Type');
xtickangle(45); % Rotate x-axis labels for better readability
grid on;

% Add error bars
hold on;
for i = 1:size(barData, 2)
    % Get the x-coordinates of the bar centers
    x = barHandle(i).XEndPoints; 
    
    % Use the correct error bar values based on the variable being plotted
    if i == 1
        err = stdErrLnRRSOC;
    elseif i == 2
        err = stdErrLnRRTN;
    else
        err = stdErrLnRRTP;
    end
    
    % Add error bars
    errorbar(x, barData(:, i), err, 'k', 'LineStyle', 'none');
end

% Add a legend to differentiate SOC, TN, and TP
legend({'SOC', 'TN', 'TP'}, 'Location', 'northeast');

hold off;

% Save the figure
saveas(gcf, '2. Average_lnRR_by_Climate_with_ErrorBars.png');

%% Correlation Matrix Heatmap of Key Variables

% Create a correlation matrix for specified variables
selectedVars = data{:, {'MAT_C_', 'MAP_mm_', 'SoilDepth_cm_', 'AmbientSOC_gKg_1_', 'lnRR_SOC', 'lnRR_TN', 'lnRR_TP'}};
corrMatrix = corr(selectedVars, 'Rows', 'complete');

figure;
h = heatmap(corrMatrix, 'Title', 'Correlation Matrix of Key Variables', ...
            'XDisplayLabels', {'MAT', 'MAP', 'Soil Depth', 'Ambient SOC', 'lnRR.SOC', 'lnRR.TN', 'lnRR.TP'}, ...
            'YDisplayLabels', {'MAT', 'MAP', 'Soil Depth', 'Ambient SOC', 'lnRR.SOC', 'lnRR.TN', 'lnRR.TP'}, ...
            'ColorLimits', [-1 1], 'Colormap', jet);

% Save the heatmap as a PNG file
saveas(gcf, '3. Correlation_Matrix_Heatmap_Key_Variables.png');

%% Enzyme Activity Over Time

% Define unique restoration times
uniqueRestorationTimes = unique(data.RestorationTime_years_);

% Initialize arrays to store means
mean_lnRR_invertase = zeros(length(uniqueRestorationTimes), 1);
mean_lnRR_urease = zeros(length(uniqueRestorationTimes), 1);
mean_lnRR_catalase = zeros(length(uniqueRestorationTimes), 1);
mean_lnRR_phosphatase = zeros(length(uniqueRestorationTimes), 1);

% Calculate means for each restoration time
for i = 1:length(uniqueRestorationTimes)
    % Get current restoration time
    currTime = uniqueRestorationTimes(i);
    
    % Extract data for the current restoration time
    subset = data(data.RestorationTime_years_ == currTime, :);
    
    % Calculate means for each enzyme activity
    mean_lnRR_invertase(i) = mean(subset.lnRR_invertase, 'omitnan');
    mean_lnRR_urease(i) = mean(subset.lnRR_urease, 'omitnan');
    mean_lnRR_catalase(i) = mean(subset.lnRR_catalase, 'omitnan');
    mean_lnRR_phosphatase(i) = mean(subset.lnRR_phosphatase, 'omitnan');
end

% Plot enzyme activity over restoration time
figure;
hold on;

% Plot each enzyme's activity
plot(uniqueRestorationTimes, mean_lnRR_invertase, 'o-', 'DisplayName', 'Invertase');
plot(uniqueRestorationTimes, mean_lnRR_urease, 's-', 'DisplayName', 'Urease');
plot(uniqueRestorationTimes, mean_lnRR_catalase, 'd-', 'DisplayName', 'Catalase');
plot(uniqueRestorationTimes, mean_lnRR_phosphatase, 'x-', 'DisplayName', 'Phosphatase');

% Customize plot
xlabel('Restoration Time (years)');
ylabel('Average Enzyme Activity (lnRR)');
title('Average Enzyme Activity Over Restoration Time');
legend('show');
grid on;
hold off;

% Save the plot
saveas(gcf, '4. Enzyme_Activity_Over_Time.png');

%% Soil Nutrient Analysis

% Define unique restoration times
uniqueRestorationTimes = unique(data.RestorationTime_years_);

% Initialize arrays to store means
mean_MAT = zeros(length(uniqueRestorationTimes), 1);
mean_MAP = zeros(length(uniqueRestorationTimes), 1);
mean_SoilDepth = zeros(length(uniqueRestorationTimes), 1);
mean_AmbientSOC = zeros(length(uniqueRestorationTimes), 1);

% Calculate means for each restoration time
for i = 1:length(uniqueRestorationTimes)
    % Get current restoration time
    currTime = uniqueRestorationTimes(i);
    
    % Extract data for the current restoration time
    subset = data(data.RestorationTime_years_ == currTime, :);
    
    % Calculate means for each soil-related metric
    mean_MAT(i) = mean(subset.MAT_C_, 'omitnan');
    mean_MAP(i) = mean(subset.MAP_mm_, 'omitnan');
    mean_SoilDepth(i) = mean(subset.SoilDepth_cm_, 'omitnan');
    mean_AmbientSOC(i) = mean(subset.AmbientSOC_gKg_1_, 'omitnan');
end

% Plot soil nutrient analysis over restoration time
figure;
hold on;

% Plot each soil metric
plot(uniqueRestorationTimes, mean_MAT, 'o-', 'DisplayName', 'MAT (°C)');
plot(uniqueRestorationTimes, mean_MAP, 's-', 'DisplayName', 'MAP (mm)');
plot(uniqueRestorationTimes, mean_SoilDepth, 'd-', 'DisplayName', 'Soil Depth (cm)');
plot(uniqueRestorationTimes, mean_AmbientSOC, 'x-', 'DisplayName', 'Ambient SOC (g/kg)');

% Customize plot
xlabel('Restoration Time (years)');
ylabel('Average Soil Metric');
title('Soil Nutrient Analysis Over Restoration Time');
legend('show');
grid on;
hold off;

% Save the plot
saveas(gcf, '5. Soil_Nutrient_Analysis_Over_Time.png');

%% Correlation Matrix Additional Metrics

% Extract relevant metrics for correlation analysis
metrics = data{:, {'lnRR_AN', 'lnRR_AP', 'lnRR_MBC', 'lnRR_MBN', 'lnRR_MBP', ...
                    'lnRR_invertase', 'lnRR_urease', 'lnRR_catalase', 'lnRR_phosphatase'}};

% Calculate the correlation matrix
corrMatrix = corr(metrics, 'Rows', 'complete');

% Define variable names for the heatmap
varNames = {'lnRR_AN', 'lnRR_AP', 'lnRR_MBC', 'lnRR_MBN', 'lnRR_MBP', ...
             'lnRR_invertase', 'lnRR_urease', 'lnRR_catalase', 'lnRR_phosphatase'};

% Create the heatmap
figure;
heatmap(corrMatrix, 'Title', 'Correlation Matrix of Additional Metrics', ...
        'XDisplayLabels', varNames, 'YDisplayLabels', varNames, ...
        'ColorLimits', [-1 1], 'Colormap', jet);

% Save the heatmap as a PNG file
saveas(gcf, '6. Correlation_Matrix_Additional_Metrics.png');

%% PCA Analysis

% Encode categorical variables
climateDummy = dummyvar(categorical(data.Climate)); % Convert Climate to dummy variables
restorationYears = data.RestorationTime_years_; % Extract Restoration Time

% Extract all relevant metrics for PCA
metrics = data{:, {'MAT_C_', 'MAP_mm_', 'SoilDepth_cm_', 'AmbientSOC_gKg_1_', ...
                    'lnRR_SOC', 'lnRR_TN', 'lnRR_TP', 'lnRR_AN', 'lnRR_AP', ...
                    'lnRR_MBC', 'lnRR_MBN', 'lnRR_MBP', 'lnRR_invertase', ...
                    'lnRR_urease', 'lnRR_catalase', 'lnRR_phosphatase'}};

% Combine all data for PCA
combinedData = [metrics, climateDummy, restorationYears];

% Perform PCA
[coeff, score, latent, tsquared, explained, mu] = pca(combinedData);

% Create a biplot
figure;
biplot(coeff(:,1:2), 'Scores', score(:,1:2), 'VarLabels', [ ...
    {'MAT_C_', 'MAP_mm_', 'SoilDepth_cm_', 'AmbientSOC_gKg_1_', ...
     'lnRR_SOC', 'lnRR_TN', 'lnRR_TP', 'lnRR_AN', 'lnRR_AP', ...
     'lnRR_MBC', 'lnRR_MBN', 'lnRR_MBP', 'lnRR_invertase', ...
     'lnRR_urease', 'lnRR_catalase', 'lnRR_phosphatase'}, ...
    strcat('Climate_', string(1:size(climateDummy,2))), ...
    {'RestorationTime_years_'}]);

xlabel('Principal Component 1');
ylabel('Principal Component 2');
title('PCA Biplot Including All Metrics, Climate, and Restoration Time');

% Save the biplot as a PNG file
saveas(gcf, '7. PCA_Biplot_All_Metrics_Climate_RestorationTime.png');

%% Multivariate Line Plot

% Define grouping variable
[G, groupNames] = findgroups(data.RestorationTime_years_);

% Calculate means for each metric
mean_lnRR_AN = splitapply(@mean, data.lnRR_AN, G);
mean_lnRR_AP = splitapply(@mean, data.lnRR_AP, G);
mean_lnRR_MBC = splitapply(@mean, data.lnRR_MBC, G);
mean_lnRR_MBN = splitapply(@mean, data.lnRR_MBN, G);
mean_lnRR_MBP = splitapply(@mean, data.lnRR_MBP, G);
mean_lnRR_invertase = splitapply(@mean, data.lnRR_invertase, G);
mean_lnRR_urease = splitapply(@mean, data.lnRR_urease, G);
mean_lnRR_catalase = splitapply(@mean, data.lnRR_catalase, G);
mean_lnRR_phosphatase = splitapply(@mean, data.lnRR_phosphatase, G);

% Create the multivariate line plot
figure;
hold on;

% Plot each metric with a different color
plot(groupNames, mean_lnRR_AN, '-o', 'DisplayName', 'lnRR_AN', 'Color', [0 0 1]); % Blue
plot(groupNames, mean_lnRR_AP, '-s', 'DisplayName', 'lnRR_AP', 'Color', [0 1 0]); % Green
plot(groupNames, mean_lnRR_MBC, '-^', 'DisplayName', 'lnRR_MBC', 'Color', [1 0 0]); % Red
plot(groupNames, mean_lnRR_MBN, '-d', 'DisplayName', 'lnRR_MBN', 'Color', [1 0 1]); % Magenta
plot(groupNames, mean_lnRR_MBP, '-p', 'DisplayName', 'lnRR_MBP', 'Color', [0 1 1]); % Cyan
plot(groupNames, mean_lnRR_invertase, '-h', 'DisplayName', 'lnRR_invertase', 'Color', [0.5 0.5 0.5]); % Gray
plot(groupNames, mean_lnRR_urease, '-x', 'DisplayName', 'lnRR_urease', 'Color', [0.5 0 0.5]); % Purple
plot(groupNames, mean_lnRR_catalase, '-+', 'DisplayName', 'lnRR_catalase', 'Color', [0.5 0.5 0]); % Olive
plot(groupNames, mean_lnRR_phosphatase, '-*', 'DisplayName', 'lnRR_phosphatase', 'Color', [1 0.5 0]); % Orange

% Customize the plot
xlabel('Restoration Time (years)');
ylabel('Mean Values');
title('Multivariate Line Plot of Various Metrics Over Restoration Time');
legend('show');
grid on;
hold off;

% Save the figure
saveas(gcf, '8. Multivariate_Line_Plot_AdditionalMetrics_Over_Restoration_Time.png');