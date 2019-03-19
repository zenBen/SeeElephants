% SPM12 BATCH AC REORIENTATION for multi-subject  single-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%----------------------------------------------------------------------

% NB: Reorientation of T1 TP1 (baseline) and meana rs was done manually using the display function in SPM12.
% The reorientation matrix (reorient) was then saved for each subject
% (T1_rs and rs folder).

clear all
data_path='C:\Users\CBRU\TBI\data\';
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'};
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID033';'ID036';'ID037';'ID039';'ID040'};
all=vertcat(les,noles);

%% Reorient T1, realigned rs and mean rs
for suje=[1:20 22:23 25:31]
    sub_path=fullfile(data_path, char(all(suje,:)), [(char(all(suje,:))) '_1']);
    cd (sub_path)
    % Get ra rs ims
    ra_rs_tp1 = spm_select('FPList', fullfile(sub_path,'rs'), '^ra.*\.nii$');
    matrixrs=load([sub_path '\rs' '\reorient.mat']);
    % Unzip T1
    RT1_rs1_name=ls('*T1_rs*'); cd(T1_rs1_name); gz_T1_rs1=ls('*.nii.gz'); gunzip(gz_T1_rs1);
    T1_rs1 = spm_select('FPList', fullfile(sub_path, 'T1_rs\'), '^*.nii$');
    matrixt1=load([sub_path '\reorient.mat']);
    clear matlabbatch
    % Reorient to AC
    matlabbatch{1}.spm.util.reorient.srcfiles = {T1_rs1};
    matlabbatch{1}.spm.util.reorient.transform.transM = matrixt1.M;
    matlabbatch{1}.spm.util.reorient.prefix = 'ro';
    for i=1:length(ra_rs_tp1)
        matlabbatch{2}.spm.util.reorient.srcfiles (i,1) = {ra_rs_tp1(i,:)};
    end
    matlabbatch{2}.spm.util.reorient.transform.transM = matrixrs.M;
    matlabbatch{2}.spm.util.reorient.prefix = 'ro';
    spm_jobman('run',matlabbatch);
    clear T1_rs matrixt1 ra_rs_tp1 matrixrs matlabbatch
end

%% Reorient Cost Function Mask (CFM, lesioned patients)
for suje=2%11:length(les) %patient ID030 has 2 rs sessions(check with Linda?)
    sub_path=fullfile(data_path, char(les(suje,:)), [(char(les(suje,:))) '_1']);
    matrixt1=load([sub_path '\reorient.mat']);
    %     cd (sub_path); mkdir ('Lesions_rs')
    %     lesions_path=fullfile(sub_path, 'Lesions');
    %     cd (lesions_path)
    %     copyfile('CFM.nii', fullfile(sub_path, 'Lesions_rs'));
    %     copyfile('CFM_mask.nii', fullfile(sub_path, 'Lesions_rs'));
    CFM=spm_select('FPList', fullfile(sub_path, 'Lesions_rs\'), '^CFM.nii$');
    CFM_mask=spm_select('FPList', fullfile(sub_path, 'Lesions_rs\'), '^CFM_mask.nii$');
    clear matlabbatch
    % Reorient to AC
    matlabbatch{1}.spm.util.reorient.srcfiles = {CFM};
    matlabbatch{1}.spm.util.reorient.transform.transM = matrixt1.M;
    matlabbatch{1}.spm.util.reorient.prefix = 'ro';
    matlabbatch{2}.spm.util.reorient.srcfiles = {CFM_mask};
    matlabbatch{2}.spm.util.reorient.transform.transM = matrixt1.M;
    matlabbatch{2}.spm.util.reorient.prefix = 'ro';
    spm_jobman('run',matlabbatch);
    clear CFM CFM_mask matrixt1 matlabbatch
end


