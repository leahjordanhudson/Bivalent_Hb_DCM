%% Parametric Empirical Bayes (PEB), reversal learning model
% This script reproduces the effective connectivity results
% reported in the Hudson et al. manuscript (Figure 3a, Supplementary Table 3).

% -----------------------------------------------------------------------
% Please ensure that your SPM12 folder (r7771) is listed in your MATLAB set
% path. These results were obtained using Matlab R2023a. Note that values
% may slightly differ from the manuscript depending on OS and Matlab 
% version.
% -----------------------------------------------------------------------

% This section runs a PEB model quantifying the between-subject commonality
% in connectivity parameters across the sample. The design matrix included
% an intercept term (single column of ones) denoting the overall mean
% connectivity.

clear
close all

% Load GCM & design matrix 
load('../data/GCM_Reversal.mat');
load('../dm/M_Reversal.mat');

X = dm.X;
K = width(X);
X(:,2:K)=X(:,2:K)-mean(X(:,2:K)); % all covariates are mean-centered
X_labels = dm.labels;

M = struct();
M.Q = 'fields';
M.X = X;
M.Xnames = X_labels;

% Hierarchical (PEB) inversion of DCMs using BMR and Variational Laplace
[PEB, RCM] = spm_dcm_peb(DCM, M, {'A','B'});

% Hierarchial (PEB) model comparison and averaging
BMA = spm_dcm_peb_bmc(PEB);
save('./BMA_search_AB_Reversal.mat', 'BMA');

% Review BMA results
% -----------------------------------------------------------------------
% Second-level effect - Mean (Table 1)
%   Threshold: Free energy, Strong evidence (Pp>.95)
%   Display as matrix: 
%     1) A-matrix (endogenous connectivity)
%     2) B-matrix (modulatory connectivity; Input ER OR UP)
% -----------------------------------------------------------------------
spm_dcm_peb_review(BMA, DCM);
