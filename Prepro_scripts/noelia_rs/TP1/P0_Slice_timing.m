% SPM12 BATCH SLICE-TIMING for multi-subject single-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%-----------------------------------------------------------------------
clear all
data_path='C:\Users\CBRU\TBI\data\'; %Set up path
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'}; % ID of subjects with lesions
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID036';'ID037';'ID039';'ID040'};% ID of subjects with no visible lesions
all=vertcat(les,noles);

%% Initialise SPM
spm('Defaults','fMRI');
spm_jobman('initcfg');

%% Loop for subjects
for suje=25:length(names)
    % Unzip files
    sub_path=fullfile(data_path, char((all(suje,:))), [char((all(suje,:))) '_1']);
    cd (sub_path)
    rs1_name=ls('*rs*'); cd(rs1_name(2,1:2)); gz_rs1=ls('*.nii.gz'); gunzip(gz_rs1);
    % Split 4D NIftI files intro 3D volumes
    V_rs1 = spm_select('FPList', fullfile(sub_path, rs1_name(2,1:2)), '^.*\.nii$');
    Vo_rs1 = spm_file_split(V_rs1);
    rs1_ims=extractfield(Vo_rs1, 'fname')';
    clear matlabbatch
    % Slice-timing
    matlabbatch{1}.spm.temporal.st.scans = {rs1_ims};
    matlabbatch{1}.spm.temporal.st.nslices = 31;
    matlabbatch{1}.spm.temporal.st.tr = 2;
    matlabbatch{1}.spm.temporal.st.ta = 1.93548387096774;
    matlabbatch{1}.spm.temporal.st.so = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31];
    matlabbatch{1}.spm.temporal.st.refslice = 15;
    matlabbatch{1}.spm.temporal.st.prefix = 'a';
    spm_jobman('run',matlabbatch)
end
