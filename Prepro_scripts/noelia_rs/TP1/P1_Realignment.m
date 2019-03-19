% SPM12 BATCH REALIGNMENT for multi-subject single-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%-----------------------------------------------------------------------
clear all
data_path='C:\Users\CBRU\TBI\data\'; %Set up path
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'}; % ID of subjects with lesions
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID036';'ID037';'ID039';'ID040'};% ID of subjects with no visible lesions
all=vertcat(les,noles);

%% Loop for subjects
for suje=[9:20 22:23 25:31]
    sub_path=fullfile(data_path, char((all(suje,:))), [char((all(suje,:))) '_1']);
    rs_tp1 = spm_select('FPList', fullfile(sub_path,'rs'), '^a.*\.nii$');
    clear matlabbatch
    % Spatial realignment
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {cellstr(rs_tp1)}';
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    clear rs_tp1
    spm_jobman('run',matlabbatch);
end


