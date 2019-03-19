% SPM12 BATCH NORMALIZATION for multi-suject single-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%-----------------------------------------------------------------
clear all
data_path='C:\Users\CBRU\TBI\data\'; %Set up path
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'}; % ID of subjects with lesions
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID036';'ID037';'ID039';'ID040'};% ID of subjects with no visible lesions
all=vertcat(les,noles);

%% Loop for subjects
for suje=1%:length(all)
    sub_path=fullfile(data_path, char((all(suje,:))), [char((all(suje,:))) '_1']);
    cd (sub_path)
    rs_tp1 = spm_select('FPList', fullfile(sub_path, 'rs'), '^ror.*\.nii$');
    matrix=spm_select('FPList', fullfile(sub_path, 'T1_rs'), 'seg_sn.*\.mat$');
    clear matlabbatch
    % Normalization rs
    matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {matrix};
    for i=1:length(rs_tp1)
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample(i,1) = {rs_tp1(i,:)};
    end
    matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
    matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -65
        78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [1 1 1];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
    matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
    spm_jobman('run',matlabbatch);
    clear rs_tp1 matrix matlabbatch
end
