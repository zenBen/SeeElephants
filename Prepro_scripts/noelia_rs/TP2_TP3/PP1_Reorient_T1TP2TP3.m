% SPM12 BATCH REORIENTATION AC for multi-suject multi-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%----------------------------------------------------------------
clear all
data_path='F:\TBI\data\'; %Set up path
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'}; % ID of subjects with lesions
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID036';'ID037';'ID039';'ID040'};% ID of subjects with no visible lesions
all=vertcat(les,noles);

%% Loop for subjects
for suje=18%[19:20 22:23 25:29]
    % Unzip files
    sub_path2=fullfile(data_path, char((all(suje,:))), [char((all(suje,:))) '_2']);
    cd(fullfile(sub_path2,'T1_rs'))
    T1tp2_gz=ls('*.nii.gz');
    gunzip(T1tp2_gz);
    T1tp2_nii=ls('*.nii');
    matrix2=load(fullfile(sub_path2,'reorient.mat'));
    if suje~=25 && suje~=28 && suje~=29
        sub_path3=fullfile(data_path, (names(suje,:)), [(names(suje,:)) '_3']);
        cd(fullfile(sub_path3,'T1_rs'))
        T1tp3_gz=ls('*.nii.gz');
        gunzip(T1tp3_gz);
        T1tp3_nii=ls('*.nii');
        matrix3=load(fullfile(sub_path3,'reorient.mat'));
    end
    clear matlabbatch
    % Reorient images to AC TP2
    matlabbatch{1}.spm.util.reorient.srcfiles = {fullfile(sub_path2, 'T1_rs',T1tp2_nii)};
    matlabbatch{1}.spm.util.reorient.transform.transM =matrix2.M;
    matlabbatch{1}.spm.util.reorient.prefix = 'ro';
    % Reorient images to AC TP3
    if suje~=25 && suje~=28 && suje~=29
        matlabbatch{2}.spm.util.reorient.srcfiles = {T1tp3_nii};
        matlabbatch{2}.spm.util.reorient.transform.transM =matrix3.M;
        matlabbatch{2}.spm.util.reorient.prefix = 'ro';
    end
    spm_jobman('run',matlabbatch)
end
