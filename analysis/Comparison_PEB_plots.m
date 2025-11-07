% Produce comparison plots of overlayed modulatory connectivity parameters 
% of the reversal learning and perceptual decision uncertainty models to negative (left) 
% and positive (right) feedback as reported in the Hudson et al. 
% manuscript (Figure 3c)
% -----------------------------------------------------------------------
% This script relies on an adapted version of spm_plot_ci(E,C,x,j,s) - see 
% under custom
%
% Copyright (C) 2008-2015 Wellcome Trust Centre for Neuroimaging, adapted
% to generate 95% CI
%
% spm_plot_ci(E,C,x,j,s) allows you to plot mean and conditional 
% confidence intervals
%
% FORMAT spm_plot_ci(E,C,x,j,s)
% E - expectation (structure or array)
% C - variance or covariance (structure or array)
% x - domain
% j - rows of E to plot
% s - string to specify plot type:e.g. '--r' or 'exp'
%
% If E is a row vector with two elements, confidence regions will be
% plotted; otherwise, bar charts with confidence intervals are provided
% -----------------------------------------------------------------------
% 
clear
close all

addpath ../custom/

% Extract model parameters
% Reversal learning model (reference)
load('./BMA_search_AB_Reversal.mat');
    pholder = [0.00000000000001; 0.00000000000001; 0.00000000000001]; % placeholders to ensure that results are positioned correctly as these results do not survive at Pp > .95
    rBMA = BMA;
    rE = [rBMA.Ep(21:23); pholder(1:2); rBMA.Ep(16:19)]; % negative and positive modulatory connectivity
    rBMA.Cp = diag(rBMA.Cp);
    rC = [rBMA.Cp(21:23); pholder(1:2); rBMA.Cp(16:19)];
    rj = find([rBMA.Pp(21:23); pholder(1:2); rBMA.Pp(16:19)]); % pull the index of connectivity
    x = '';
    s = '--r';
    ref_line_col = [101 99 96]/256;
    comp_bar_col = [220 191 182]/256;

% Perceptual decision uncertainty model (comparison)
load('./BMA_search_AB_Perceptual.mat');
    cBMA = BMA;
    cE = [cBMA.Ep(21:25); cBMA.Ep(16:17); pholder(1:2)]; % negative and positive modulatory connectivity
    cBMA.Cp = diag(cBMA.Cp);
    cC = [cBMA.Cp(21:25); cBMA.Cp(16:17); pholder(1:2)];
    cj = 1:length(cC);
    ep_names = {'Hb-VTA';'Hb-DRN';'VTA-dACC';'DRN-mPFC';'dACC-Hb';'Hb-VTA';'Hb-DRN';'VTA-dACC';'DRN-mPFC'};

all_Pp = [cBMA.Pp(21:25); cBMA.Pp(16:17); pholder(1:2); rBMA.Pp(rj)];
all_Pp_flipped = flip(all_Pp,1);

% Use custom spm_plot_ci.m to plot the reversal learning model
figure('Position', [200 200 1500 700]),
spm_plot_ci(rE,rC,x,rj,s);
hold on

% Overlay perceptual decision uncertainty model 
spm_plot_ci(cE,cC,x,cj,s);

% Find and adjust covariance line
    covar_lines = findobj(gca, 'Type', 'line');

        % Reference model
        for i = 1:length(cj)
            set(covar_lines(i), 'LineWidth', 2, 'Color', comp_bar_col * 0.8,... 
                'Marker', '_', 'LineStyle', '-');
        end

        % Comparison model
        for i = length(cj)+1:length(cj)+length(rj)
            set(covar_lines(i), 'LineWidth', 2, 'Color', ref_line_col,...
                'Marker', '_', 'LineStyle', '-');
        end
    % Find and adjust posterior expectation bar
    ep_bars = findobj(gca, 'Type', 'bar');

        % Reference model
        set(ep_bars(2), 'BarWidth', 0.4, 'EdgeColor', 'none',...
            'FaceAlpha', 1)
        % Comparison model
        set(ep_bars(1), 'BarWidth', 0.8, 'FaceColor', comp_bar_col,...
            'EdgeColor', 'none', 'FaceAlpha', 0.6)

% Add legends and labels
legend([ep_bars(2), ep_bars(1)], {'Reversal', 'Perceptual'}, 'FontSize', 15);

xlim([0 10.5]);%(length(rj)+1.5)
xlabel('Modulatory connectivity', 'FontSize', 20, 'FontWeight','bold');
xlabelHandle = get(gca, 'XLabel');
xlabelPosition = get(xlabelHandle, 'Position');
xlabelPosition(2) = xlabelPosition(2) - 0.3;
set(xlabelHandle, 'Position', xlabelPosition);
set(gca,'XTickLabel',ep_names,'fontsize', 14,'XTickLabelRotation', 0);

ylabel('Posterior expectation', 'FontSize', 20, 'FontWeight','bold');
set(gca,'YTickLabel',get(gca, 'YTickLabel'),'fontsize', 14);
set(findall(gca, '-property', 'FontName'), 'FontName', 'Helvetica');

% Additional visualisation features
line([5.5 5.5], [-10 5], 'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'HandleVisibility', 'off');

hold off

saveas(figure(1), './Reversal_Perceptual_EpCp.png');
