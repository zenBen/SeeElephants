%% Define our CONN project on disk
% conndir = '/media/bcowley/CBRU_NMM/TBI/CONN/';
conndir = '/home/local/bcowley/Benslab/METHODMAN/project_BN_CONN/';
cd(conndir)
connprj = 'Test_Friday';
datadir = 'testdata';

% Find data and SPM preprocess - THIS IS JUST AN EXAMPLE
% rawdir = '~/some/input/data';
% rawdat = build_dataset(rawdir);
% SPM_prepro_wrapper(rawdat, conndir, {'rea' 'reo' 'nor' 'smo'})


%% Make parameter structs for each CONN stage
setup = struct('functional', '^swrora.*\.nii$'...
            , 'T1dir', 'T1_rs'...
            , 'structural_sessionspecific', true);
setup.cond_names = {'pre' 'post'};
setup.structural = {'^wro.*\.nii$' '^wcoregro.*\.nii$';
                    '^wcoregro.*\.nii$' '^wcoregro.*\.nii$'};
setup.covar_files = {'^rp_a.*\.txt$' '^art_regression_outliers_swrora.*\.mat$';
                    '^rp_a.*\.txt$' '^art_regression_outliers_and_mov.*\.mat$'};
setup.grey_rgx = {'^wc1ro.*\.nii$' '^wc1cor.*\.nii$';
                  '^wc1cor.*\.nii$' '^wc1cor.*\.nii$'};
setup.white_rgx = {'^wc2ro.*\.nii$' '^wc2cor.*\.nii$';
                   '^wc2cor.*\.nii$' '^wc2cor.*\.nii$'};
setup.csf_rgx = {'^wc3ro.*\.nii$' '^wc3cor.*\.nii$';
                 '^wc3cor.*\.nii$' '^wc3cor.*\.nii$'};
setup.groups_file = fullfile(conndir, datadir, 'groups.csv');
% setup.effects_file = fullfile(conndir, 'data', {'effects1.csv' 'effects2.csv'});

tmp = dirflt(fullfile(conndir, datadir, 'ROI'), 'getdir', false);
setup.roi_files = fullfile(tmp(1).folder, {tmp.name});
setup.roi_names = {'testi1' 'testi2'};
setup.roi_mask = [1 1];

denoise = struct(...
    'some_arg', {'some_value'});

level1 = struct(...
    'some_arg', 'some_other_value');

% https://www.nitrc.org/forum/message.php?msg_id=17111
% https://www.nitrc.org/forum/message.php?msg_id=17121


%% NOELIA - build datasets yourself - for the 2 group, 3 session data
% filter by exact list of subjects, with session 1 and 2 as '_1', '_2'
gbas = build_dataset(fullfile(conndir, datadir), 'getfile', false, 'filt', [13 29]);
g_s1 = build_dataset(fullfile(gbas(1).folder, {gbas.name}), 'filt', '_1');
g_s2 = build_dataset(fullfile(gbas(1).folder, {gbas.name}), 'filt', '_2');
grp1 = [g_s1 g_s2];
%% filter by exact list of subjects, with session 1 and 2 as '_1', '_3'
gbas = build_dataset(fullfile(conndir, datadir), 'getfile', false, 'filt', [9 35]);
g_s1 = build_dataset(fullfile(gbas(1).folder, {gbas.name}), 'filt', '_1');
g_s2 = build_dataset(fullfile(gbas(1).folder, {gbas.name}), 'filt', '_3');
grp2 = [g_s1 g_s2];

sbj = [grp1; grp2];
% NOTE: THIS COULD OBVIOUSLY BE STREAMLINED, BUT THAT'S HOW IT IS FOR NOW


%% build and run batch from given struct of files (here CONN name is default)
% batch = BN_conn_batch(sbj, fullfile(conndir, 'Output'), 'Setup', setup);
% 
% % build batch from given struct of files, don't run (CONN name is default)
% batch = BN_conn_batch(sbj, fullfile(conndir, 'Output')...
%     , 'do_batch', false...
%     , 'Setup', setup...
%     , 'Denoising', denoise);

% build batch from given struct of files, don't run, open in GUI
batch = BN_conn_batch(sbj, fullfile(conndir, 'Output')...
    , 'do_batch', false...
    , 'GUI', true...
    , 'Setup', setup);


%% Find data and CONN batch it
% build and run batch from prompted directory - no filtering supported
BN_conn_batch('', fullfile(conndir, 'Output')...
    , 'prompt', true...
    , 'Setup', setup...
    , 'filename', connprj...
    , 'ispending', 1 ...
    , 'Analysis', level1)

% build and run batch from given directory - no filtering supported
BN_conn_batch(fullfile(conndir, 'data'), fullfile(conndir, 'Output')...
    , 'Setup', setup...
    , 'filename', connprj)


%% build datasets yourself, all types of filtering supported
% this section designed for test dataset with subjects 09 13 29 35,
% session 1 as '_1' but session 2 as either '_2' or  '_3'
crit = 1;
switch crit
    case 1
        gbas = build_dataset(fullfile(conndir, 'data')...
            , 'filt', 'ID'...
            , 'guard_str_match', false);
    case 2
        gbas = build_dataset(fullfile(conndir, 'data')...
            , 'filt', {'~ROI' '~Output'}...
            , 'guard_str_match', false...
            , 'getfile', false);
    case 3
        gbas = build_dataset(fullfile(conndir, 'data'), 'filt', {'09' '13'});
    case 4
        gbas = build_dataset({conndir conndir}, 'subdir', 'data'...
            , 'filt', {'29' '35'});
end

g_s1 = build_dataset(fullfile(gbas(1).folder, {gbas.name}), 'filt', '_1');
g_s2 = build_dataset(fullfile(gbas(1).folder, {gbas.name}), 'filt', {'_2' '_3'});
grp1 = [g_s1 g_s2];
