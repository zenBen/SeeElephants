% SPM12 BATCH NORMALIZATION for multi-suject multi-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%----------------------------------------------------------------

clear all
% data_path = 'D:\Noelia\TBI\CONN\'; %Set up path
data_path = '/media/bcowley/CBRU_NMM/TBI/CONN';
les = {'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';...
    'ID029';'ID030';'ID031';'ID032';'ID034';'ID035';'ID038'}; %subjs w lesions
noles = {'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';...
    'ID019';'ID020';'ID026';'ID036';'ID037';'ID039';'ID040'}; %no visible lesions
all = vertcat(les,noles);
N24 = {'ID001';'ID002';'ID003';'ID006';'ID007';'ID013';'ID014';'ID016';...
    'ID017';'ID020';'ID026';'ID029';'ID031';'ID032';'ID036';'ID005';...
    'ID008';'ID009';'ID010';'ID012';'ID015';'ID019';'ID030';'ID035'};


%% Normalization rs TP2
% Loop for subjects
% for suje=10
%     if suje~=28 && suje~=29
%     sub_path=fullfile(data_path, char((all(suje,:))), [char((all(suje,:))) '_2']);
%     cd (sub_path)
%     rs_tp2 = spm_select('FPList', fullfile(sub_path, 'rs'), '^ror.*\.nii$');
%     matrix=spm_select('FPList', fullfile(sub_path, 'T1_rs'), 'seg_sn.*\.mat$');
%     clear matlabbatch
%     matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {matrix};
%     for i=1:length(rs_tp2)
%     matlabbatch{1}.spm.spatial.normalise.write.subj.resample(i,1) = {rs_tp2(i,:)};
%     end
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -65
%         78 76 85];
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [1 1 1];
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
%     spm_jobman('run',matlabbatch);
%     clear rs_tp2 matrix matlabbatch
%     end
% end

%% Normalization T1, GM, Wm & CSF TP2
for suje=1:length(N24)
    sub_path=fullfile(data_path, char((N24(suje,:))), [char((N24(suje,:))) '_2']);
    cd (sub_path)
%     T1_tp2=spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^coreg.*\.nii$');
    c1_tp2 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^c1.*\.nii$');
    c2_tp2 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^c2.*\.nii$');
    c3_tp2 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^c3.*\.nii$');
    matrix=spm_select('FPList', fullfile(sub_path, 'T1_rs'), 'seg_sn.*\.mat$');
    clear matlabbatch
    % Normalization GM
    matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {matrix};
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample= {
%         T1_tp2
        c1_tp2
        c2_tp2
        c3_tp2};
    matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
    matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -65
        78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [1 1 1];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
    matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
    spm_jobman('run',matlabbatch);
    clear c1_tp2 c2_tp2 c3_tp2 matrix matlabbatch
end

%% Normalization rs TP3
% Loop for subjects
% for suje=10
%     if suje~=12 && suje~=14 && suje~=27 && suje~=28 && suje~=29
%     sub_path=fullfile(data_path, char((all(suje,:))), [char((all(suje,:))) '_3']);
%     cd (sub_path)
%     rs_tp3 = spm_select('FPList', fullfile(sub_path, 'rs'), '^ror.*\.nii$');
%     matrix=spm_select('FPList', fullfile(sub_path, 'T1_rs'), 'seg_sn.*\.mat$');
%     matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {matrix};
%     for ii=1:length(rs_tp3)
%     matlabbatch{1}.spm.spatial.normalise.write.subj.resample(ii,1) = {rs_tp3(ii,:)};
%     end
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -65
%         78 76 85];
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [1 1 1];
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
%     matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
%     spm_jobman('run',matlabbatch);
%     clear rs_tp3 matrix matlabbatch
%     end
% end

%% Normalization T1,GM, Wm & CSF TP3
for suje=1:length(N24)
    sub_path=fullfile(data_path, char((N24(suje,:))), [char((N24(suje,:))) '_3']);
    cd (sub_path)
%     T1_tp3=spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^coreg.*\.nii$');
    c1_tp3 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^c1.*\.nii$');
    c2_tp3 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^c2.*\.nii$');
    c3_tp3 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^c3.*\.nii$');
    matrix=spm_select('FPList', fullfile(sub_path, 'T1_rs'), 'seg_sn.*\.mat$');
    clear matlabbatch
    % Normalization GM
    matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {matrix};
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample= {
%         T1_tp3
        c1_tp3
        c2_tp3
        c3_tp3};
    matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
    matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -65
        78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [1 1 1];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
    matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
    spm_jobman('run',matlabbatch);
    clear c1_tp3 c2_tp3 c3_tp3 matrix matlabbatch
end