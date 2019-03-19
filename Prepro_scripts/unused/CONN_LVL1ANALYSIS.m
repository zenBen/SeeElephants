% function batch = CONN_LVL1ANALYSIS(batch)
%% CONN Analysis (1st-Level) 

% Sequential number identifying each set of independent first-level analyses
batch.Analysis.analysis_number = 1;
%1=ROI-to-ROI analysis, 2= seed-to-voxel analysis, 3= both;
batch.Analysis.type = 3;
% connectivity measure: 1 = 'correlation (bivariate)', 2 = 'correlation 
% (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)'
batch.Analysis.measure = 1;
% within-condition weight used {1 = 'none', 2 = 'hrf', 3 = 'hanning';
batch.Analysis.weight = 2;
% batch.Analysis.sources.names = {'pSTGR', 'IFGR'}; %(defaults to all ROIs)
% batch.Analysis.sources.dimensions = {1,1};
% batch.Analysis.sources.deriv = {0,0};
batch.Analysis.done = 1;
batch.Analysis.overwrite = 'No';