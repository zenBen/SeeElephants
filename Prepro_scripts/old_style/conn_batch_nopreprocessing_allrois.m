clear all
%% BATCH RESTING_STATE LASA PROJECT
data_path='C:\Users\CBRU\Aphasia_project\preprocessing\';
project_path='E:\NBEHBC\';
aux= ls(data_path);
names=aux(3:end,1:5);
%% Defining INPUTS
for s=1:16
sub_path=fullfile(data_path,(names(s,:)),[(names(s,:)) '_1\']);
% Selects functional / anatomical volumes
FUNCTIONAL_FILE {s,1}=cellstr(spm_select('FPList',fullfile(sub_path, 'rs'), '^swrorfLASA.*\.nii$'));
STRUCTURAL_FILE {s,1}=cellstr(spm_select('FPList',fullfile(sub_path, 'T1\oldseg_norm'), '^wrofLASA.*\.nii$'));
end
nsubjects=16;
nsessions=1;
nconditions=1;
TR=1.5; %(seconds)
%% PREPARES connectivity analyses
clear batch;
batch.filename=fullfile(project_path,'conn_roi2roi_sbc_rs_noprep.mat');
%% CONN Setup
batch.Setup.RT=TR;
batch.Setup.nsubjects=16;
batch.Setup.acquisitiontype=1;
batch.Setup.analyses=[1,2];
batch.Setup.voxelmask=1;
batch.Setup.voxelresolution=1;
batch.Setup.outputfiles=[0,1,1];
for nsub=1:nsubjects
    for nses=1:nsessions
        batch.Setup.functionals{nsub}{nses}=FUNCTIONAL_FILE{nsub};
    end
end
for nsub=1:nsubjects
    batch.Setup.structurals{nsub}=STRUCTURAL_FILE;
end
for nsub=1:nsubjects
    sub_path=fullfile(data_path,(names(nsub,:)),[(names(nsub,:)) '_1\']);
    batch.Setup.masks.Grey.files{nsub}=cellstr(spm_select('FPList',fullfile(sub_path,'T1\oldseg_norm'),'^wc1rofLASA.*\.nii$'));
    batch.Setup.masks.Grey.dimensions=1;
    batch.Setup.masks.White.files{nsub}=cellstr(spm_select('FPList',fullfile(sub_path,'T1\oldseg_norm'),'^wc2rofLASA.*\.nii$'));
    batch.Setup.masks.White.dimensions=3;
    batch.Setup.masks.CSF.files{nsub}=cellstr(spm_select('FPList',fullfile(sub_path,'T1\oldseg_norm'),'^c3rofLASA.*\.nii$'));
    batch.Setup.masks.CSF.dimensions=3;
end
for ncond=1:nconditions
    for nsub=1:nsubjects
        for nses=1:nsessions
            batch.Setup.conditions.names{ncond}='rest';
            batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0;
            batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;
        end
    end
end
batch.Setup.covariates.names={'motion','outliers'};
for nsub=1:nsubjects
      sub_path=fullfile(data_path,(names(nsub,:)),[(names(nsub,:)) '_1\']);
batch.Setup.covariates.files{1}{nsub}{1}=cellstr(spm_select('FPList',fullfile(sub_path,'rs'), '^rp.*\.txt$'));
batch.Setup.covariates.files{2}{nsub}{1}=cellstr(spm_select('FPList',fullfile(sub_path,'rs'), '^art_regression_outliers_wrorf.*\.mat$'));
end
batch.Setup.subjects.names={'group_BL','BDEA'};
batch.Setup.subjects.effects{1}=[1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1];
%batch.Setup.subjects.effects{2}=[3;4;3;1;4;5;4;4;3;5;1;5;3;4;4;4];
batch.Setup.subjects.effects{2}=[-0.56;0.44;-0.56;-2.56;0.44;1.44;0.44;0.44;-0.56;1.44;-2.56;1.44;-0.56;0.44;0.44;0.44;]; %decentered values
batch.Setup.done=1;
batch.Setup.overwrite='No';
batch.Setup.isnew='0';
%% CONN Denoising 
batch.Preprocessing.confounds.names={'White', 'CSF', 'motion','outliers', 'rest'};
batch.Preprocessing.confounds.dimensions={3,3,6,3,2};
batch.Preprocessing.confounds.deriv={0,0,1,0,0};
batch.Preprocessing.done=1;
batch.Preprocessing.overwrite='No';
batch.Denoising.filter=[0.01, 0.1];          % frequency filter (band-pass values, in Hz)
batch.Denoising.done=1;
%% CONN Analysis (1st-Level)
batch.Analysis.analysis_number=1; % Sequential number identifying each set of independent first-level analyses {1=
batch.Analysis.type=3; %1=ROI-to-ROI analysis, 2= seed-to-voxel analysis, 3= both;
batch.Analysis.measure=1;               % connectivity measure used {1 = 'correlation (bivariate)', 2 = 'correlation (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)';
batch.Analysis.weight=2;                % within-condition weight used {1 = 'none', 2 = 'hrf', 3 = 'hanning';
% batch.Analysis.sources={'pSTGR','pSTGL','IFGopR','IFGopL'};              % (defaults to all ROIs)
batch.Analysis.done=1;
batch.Analysis.overwrite='No';
conn_batch(batch);






