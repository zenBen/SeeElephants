clear all
%% BATCH RESTING_STATE LASA PROJECT
data_path='C:\Users\CBRU\NBEHBC\project\data\';
rois_path='C:\Users\CBRU\NBEHBC\project\rois\';
aux= ls(data_path);
names=aux(3:end,1:5);
nsub=1;
sub_path=fullfile(data_path,(names(nsub,:)),[(names(nsub,:)) '_1\']);
% Selects functional / anatomical volumes
FUNCTIONAL_FILE=cellstr(spm_select('FPList',fullfile(sub_path, 'rs'), '^swrorfLASA.*\.nii$'));
STRUCTURAL_FILE=cellstr(spm_select('FPList',fullfile(sub_path, 'T1'), '^rofLASA.*\.nii$'));
nses=1;
ncond=1;
TR=1.5; %(seconds)
%% PREPARES connectivity analyses
clear batch;
batch.filename=fullfile(data_path,'conn_batch_nopreprocessing.mat');
%% CONN Setup
batch.Setup.RT=TR;
batch.Setup.nsubjects=1;
batch.Setup.acquisitiontype=1;
batch.Setup.analyses=[1,2];
batch.Setup.voxelmask=1;
batch.Setup.voxelresolution=1;
batch.Setup.outputfiles=[0,1,1];
batch.Setup.functionals{1}{1}=FUNCTIONAL_FILE;
batch.Setup.structurals{1}=STRUCTURAL_FILE;
batch.Setup.rois.names={'pSTGL', 'pSTGR', 'IFGL', 'IFGR'};
batch.Setup.rois.dimensions={1,1,1,1};
batch.Setup.rois.files{1}=cellstr(fullfile(rois_path, 'pSTGR.nii'));
batch.Setup.rois.files{2}=cellstr(fullfile(rois_path, 'pSTGL.nii'));
batch.Setup.rois.files{3}=cellstr(fullfile(rois_path, 'IFGopR.nii'));
batch.Setup.rois.files{4}=cellstr(fullfile(rois_path, 'IFGopL.nii'));
batch.Setup.masks.Grey.files{nsub}=cellstr(fullfile(sub_path,'T1','c1rofLASA_ID102_1_20171215175412___GR_IR___tfl3d1_16ns_9.nii'));
batch.Setup.masks.Grey.dimensions=1;
batch.Setup.masks.White.files{nsub}=cellstr (fullfile(sub_path,'T1','c2rofLASA_ID102_1_20171215175412___GR_IR___tfl3d1_16ns_9.nii'));
batch.Setup.masks.White.dimensions=3;
batch.Setup.masks.CSF.files{nsub}=cellstr (fullfile(sub_path,'T1','c3rofLASA_ID102_1_20171215175412___GR_IR___tfl3d1_16ns_9.nii'));
batch.Setup.masks.CSF.dimensions=3;
nconditions=1;
batch.Setup.conditions.names={'rest'};
batch.Setup.conditions.onsets{ncond}{nsub}{nses}=0;
batch.Setup.conditions.durations{ncond}{nsub}{nses}=inf;
batch.Setup.covariates.names={'motion','outliers'};
batch.Setup.covariates.files{1}{1}{1}=cellstr(fullfile('C:\Users\CBRU\NBEHBC\project\data\ID102\ID102_1\rs', 'rp_fLASA_ID102_1_20171215175412___EP___epfid2d1_74_7_00001.txt'));
batch.Setup.covariates.files{2}{1}{1}=cellstr(fullfile('C:\Users\CBRU\NBEHBC\project\data\ID102\ID102_1\rs', 'art_regression_outliers_wrorfLASA_ID102_1_20171215175412___EP___epfid2d1_74_7_00001.mat'));
batch.Setup.subjects.names={'group_BL','BDEA'};
batch.Setup.subjects.effects{1}=[1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1];
batch.Setup.subjects.effects{2}=[3;4;3;1;4;5;4;4;3;5;1;5;3;4;4;4];
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
batch.Analysis.type=1; %1=ROI-to-ROI analysis, 2= seed-to-voxel analysis, 3= both;
batch.Analysis.measure=1;               % connectivity measure used {1 = 'correlation (bivariate)', 2 = 'correlation (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)';
batch.Analysis.weight=2;                % within-condition weight used {1 = 'none', 2 = 'hrf', 3 = 'hanning';
batch.Analysis.sources.names={'pSTGR', 'IFGR'};
batch.Analysis.sources.dimensions={1,1};
batch.Analysis.sources.deriv={0,0};
batch.Analysis.done=1;
batch.Analysis.overwrite='No';
conn_batch(batch);





