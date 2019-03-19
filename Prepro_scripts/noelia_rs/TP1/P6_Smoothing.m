% SPM12 BATCH SMOOTHING for multi-suject single-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%-------------------------------------------------------------

clear all
data_path='F:\TBI\data\'; %Set up path
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'}; % ID of subjects with lesions
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID036';'ID037';'ID039';'ID040'};% ID of subjects with no visible lesions
all=vertcat(les,noles);

%% Loop for subjects
for suje=22:length(all)
    %% Smoothing rs
    sub_path=fullfile(data_path, char((all(suje,:))), [char((all(suje,:))) '_1']);
    cd (sub_path)
    rs_tp1 = spm_select('FPList', fullfile(sub_path, 'rs'), '^wror.*\.nii$');
    for i=1:length(rs_tp1)
        matlabbatch{1}.spm.spatial.smooth.data (i,1) = {rs_tp1(i,:)};
    end
    matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    spm_jobman('run',matlabbatch);
    clear rs_tp1 matlabbatch
end