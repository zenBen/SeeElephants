% function batch = CONN_SETUP(batch, names, nsubjects, nsessions, nconditions, TR, data_path, FUNCTIONAL_FILE, STRUCTURAL_FILE)

%% CONN Setup
batch.Setup.RT = Arg.TR;
batch.Setup.nsubjects = nsubjects;
batch.Setup.acquisitiontype = 1;
batch.Setup.analyses = [1,2];
batch.Setup.voxelmask = 1;
batch.Setup.voxelresolution = 1;
batch.Setup.outputfiles = [0,1,1];
for sbji = 1:nsubjects
    for ssni = 1:nsessions
        batch.Setup.functionals{sbji}{ssni} = FUNCTIONAL_FILE{sbji};
    end
end
for sbji = 1:nsubjects
    batch.Setup.structurals{sbji} = STRUCTURAL_FILE;
end
for sbji = 1:nsubjects
    pathi = fullfile(data_path, names(sbji).name); %[(names(1).name) '_1']);
    batch.Setup.masks.Grey.files{sbji} = cellstr(spm_select('FPList'...
        , fullfile(pathi, Arg.T1dir), '^wc1rofLASA.*\.nii$'));
    batch.Setup.masks.Grey.dimensions = 1;
    batch.Setup.masks.White.files{sbji} = cellstr(spm_select('FPList'...
        , fullfile(pathi, Arg.T1dir), '^wc2rofLASA.*\.nii$'));
    batch.Setup.masks.White.dimensions = 3;
    batch.Setup.masks.CSF.files{sbji} = cellstr(spm_select('FPList'...
        , fullfile(pathi, Arg.T1dir), '^c3rofLASA.*\.nii$'));
    batch.Setup.masks.CSF.dimensions = 3;
end
for cndi = 1:nconditions
    for sbji = 1:nsubjects
        for ssni = 1:nsessions
            batch.Setup.conditions.names{cndi} = 'rest';
            batch.Setup.conditions.onsets{cndi}{sbji}{ssni} = 0;
            batch.Setup.conditions.durations{cndi}{sbji}{ssni} = inf;
        end
    end
end
batch.Setup.covariates.names = {'motion', 'outliers'};
for sbji = 1:nsubjects
    pathi = fullfile(data_path, names(sbji).name); %[(names(1).name) '_1']);
    batch.Setup.covariates.files{1}{sbji}{1} = cellstr(spm_select('FPList'...
        , fullfile(pathi, Arg.dtdir), '^rp.*\.txt$'));
    batch.Setup.covariates.files{2}{sbji}{1} = cellstr(spm_select('FPList'...
        , fullfile(pathi, Arg.dtdir), '^art_regression_outliers_wrorf.*\.mat$'));
end
batch.Setup.subjects.names = {'group_BL', 'BDEA'};
batch.Setup.subjects.effects{1} = ones(16, 1);
%batch.Setup.subjects.effects{2} = [3;4;3;1;4;5;4;4;3;5;1;5;3;4;4;4];
batch.Setup.subjects.effects{2} =.... %decentered values:
            [-0.56;0.44;-0.56;-2.56;0.44;1.44;0.44;0.44...
            ;-0.56;1.44;-2.56;1.44;-0.56;0.44;0.44;0.44];
batch.Setup.done = 1;
batch.Setup.overwrite = 'No';
batch.Setup.isnew = '0';