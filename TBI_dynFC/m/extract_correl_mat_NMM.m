%% EXTRACT AND PLOT ADJACENCY MATRIX FROM STATIC FC rsMRI
% Copyright (May 2019) Noelia Martinez-Molina                         
%===========================================================
clearvars 
%% Create data structure
data_path='C:\Users\CBRU\TBI\Connectivity_matrix\results\secondlevel';
corr_info = [];
corr_info.dir= data_path;       
corr_info.corr_anal = 'SBC_01';                               % analysis name
corr_info.corr_group= 'AllSubjects';                            % group
corr_info.corr_ses= 'pre(-1).post(1)';                                   % contrast for sessions
corr_info.corr_folder= [ corr_info.dir '\' corr_info.corr_anal '\' corr_info.corr_group '\' corr_info.corr_ses '\' ];
%% Import correlation data
% Load ROI mat
load([corr_info.corr_folder 'ROI.mat']);                   
%% Loop on each ROI to import beta values
numROI  = size(ROI, 2);
corr_name= ROI(1).names(1:numROI);
corr_h= [];   % Beta value
corr_F= [];   % T/F value
corr_p= [];   % One-tailed p value
for i = 1:numROI  
    corr_h= [ corr_h ; ROI(i).h(1:numROI) ];
    corr_F= [ corr_F ; ROI(i).F(1:numROI) ];
    corr_p= [ corr_p ; ROI(i).p(1:numROI) ];
       % Split network name (ex DMN.MPFC >> MPFC)
    split = strsplit(corr_name{i}, '.');
    corr_name(i)= cellstr(split(end));
end
%% Export to CSV for plotting using imagesc
for j=1:numROI
    slash_find(1,j) =strfind(corr_name (1,j), '(');
end
char_corr_name=char(corr_name);
for jj=1:numROI
    if ~isempty(slash_find{1,jj}) && size(slash_find{1,jj},2)==1
        corr_name2{1,jj} =char_corr_name(jj, 1:slash_find{1,jj}-2);
    elseif ~isempty(slash_find{1,jj}) && size(slash_find{1,jj},2)==2
        corr_name2{1,jj} =char_corr_name(jj, 1:slash_find{1,jj}(2)-2);
    else
        corr_name2{1,jj} =char_corr_name(jj,:);
    end
end
corr_name3  = strrep(corr_name2, '(', '_');
corr_name4  = strrep(corr_name3, ')', '');
corr_name5  = strrep(corr_name4, '-', '_');
corr_name6=deblank(corr_name5);
corr_name7  = strrep(corr_name6, ' ', '_');
corr_name8  = strrep(corr_name7, '__', '_');
corr_name8{1,142}='Lateral_L2';corr_name8{1,143}='Lateral_R2';

T_h= array2table(corr_h, 'RowNames', corr_name8, 'VariableNames', corr_name8);
T_F= array2table(corr_F, 'RowNames', corr_name8, 'VariableNames', corr_name8);
T_p= array2table(corr_p, 'RowNames', corr_name8, 'VariableNames', corr_name8);


%% Plot connectivity matrix (beta values)
close all
fig=figure;
%Display imaged with scaled colors
%clim = [ -0.5 1 ]; %set color limits
corr_h_tril=tril(corr_h,-1); % Lower triangular part of matrix

im=imagesc(corr_h_tril(1:10, 1:10));

vals = unique(corr_h_tril(1:10, 1:10));
colormap_range = 64;
[n,xout] = hist(corr_h_tril(1:10, 1:10), colormap_range);   % hist intensities according to the colormap range
[val, ind] = sort(abs(xout)); % sort according to values closest to zero
j = jet;
j(ind(1),:) = [ 1 1 1 ]; % also see comment below

im.AlphaData = 0.9; %transparency
colormap(j)
colorbar
% Title and axis
title([corr_info.corr_anal ' - ' corr_info.corr_group ' - ' corr_info.corr_ses ], 'FontSize', 12);
set(gca, 'XTick', (1:10));
set(gca, 'YTick', (1:10));
set(gca, 'Ticklength', [0 0])
box off, grid off
% Axis label
set(gca, 'XTickLabel', (corr_name8 (1:10)), 'XTickLabelRotation', 90);
set(gca, 'YTickLabel', (corr_name8 (1:10)));

%%
saveplot = [ corr_info.corr_folder  '_' corr_info.corr_anal '_' corr_info.corr_group '_' corr_info.corr_ses '.tiff' ];
print(saveplot, '-dpng', '-r1200');



