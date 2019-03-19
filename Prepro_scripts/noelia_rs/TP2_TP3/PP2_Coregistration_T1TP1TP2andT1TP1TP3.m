% SPM12 BATCH COREGISTRATION AC for multi-suject multi-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%----------------------------------------------------------------

% NB: The mean was reoriented to AC before coregistration and saved with the prefix ro

clear all
data_path='F:\TBI\data\'; %Set up path
cd(data_path)
aux=ls(data_path);
names=aux(27:57,1:5);
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'};
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID036';'ID037';'ID039';'ID040'};% ID of subjects with no visible lesions

%% Coregistration no lesioned patients TP2-TP3
% Loop for subjects
for suje=10
    sub_path1=fullfile(data_path, (char(noles(suje,:))), [(char(noles(suje,:))) '_1']);
    sub_path2=fullfile(data_path, (char(noles(suje,:))), [(char(noles(suje,:))) '_2']);
    sub_path3=fullfile(data_path, (char(noles(suje,:))), [(char(noles(suje,:))) '_3']);
    cd (sub_path1)
    roT1_TP1 = spm_select('FPList', fullfile(sub_path1, 'T1_rs'), '^ro.*\.nii$');
    cd(sub_path2)
    roT1_TP2 = spm_select('FPList', fullfile(sub_path2, 'T1_rs'), '^ro.*\.nii$');
    if suje~=13
        cd(sub_path3)
        roT1_TP3 = spm_select('FPList', fullfile(sub_path3, 'T1_rs'), '^ro.*\.nii$');
    end
    clear matlabbatch
    % Coregistration
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {roT1_TP1};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {roT1_TP2};
    matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'coreg';
    if suje~=13
        matlabbatch{2}.spm.spatial.coreg.estwrite.ref = {roT1_TP1};
        matlabbatch{2}.spm.spatial.coreg.estwrite.source = {roT1_TP3};
        matlabbatch{2}.spm.spatial.coreg.estwrite.other = {''};
        matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
        matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
        matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.interp = 4;
        matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.prefix = 'coreg';
    end
    clear roT1_TP1 roT1_TP2 roT1_TP3
    spm_jobman('interactive',matlabbatch)
end

%% Coregistration lesioned patients TP2-TP3
for suje=3:size(les,1)
    sub_path1=fullfile(data_path, (char(les(suje,:))), [(char(les(suje,:))) '_1']);
    sub_path2=fullfile(data_path, (char(les(suje,:))), [(char(les(suje,:))) '_2']);
    sub_path3=fullfile(data_path, (char(les(suje,:))), [(char(les(suje,:))) '_3']);
    cd (sub_path1)
    roT1_TP1 = spm_select('FPList', fullfile(sub_path1, 'T1_rs'), '^ro.*\.nii$');
    cd(sub_path2)
    roT1_TP2 = spm_select('FPList', fullfile(sub_path2, 'T1_rs'), '^ro.*\.nii$');
    if suje~=12 && suje~=14
        cd(sub_path3)
        roT1_TP3 = spm_select('FPList', fullfile(sub_path3, 'T1_rs'), '^ro.*\.nii$');
    end
    clear matlabbatch
    % Coregistration
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {roT1_TP1};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {roT1_TP2};
    matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'coreg';
    if suje~=12 && suje~=14
        matlabbatch{2}.spm.spatial.coreg.estwrite.ref = {roT1_TP1};
        matlabbatch{2}.spm.spatial.coreg.estwrite.source = {roT1_TP3};
        matlabbatch{2}.spm.spatial.coreg.estwrite.other = {''};
        matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
        matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
        matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.interp = 4;
        matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.prefix = 'coreg';
    end
    clear roT1_TP1 roT1_TP2 roT1_TP3
    spm_jobman('run',matlabbatch)
end
