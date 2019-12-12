%% Define our CONN project on disk
% conndir = '/media/bcowley/CBRU_NMM/TBI/CONN/BN_testi';
conndir = '/home/local/bcowley/Benslab/project_METHODMAN/BN_CONN';
cd(conndir)
connprj = 'TBI_testi_1';


%% Find data and SPM preprocess
rawdir = '~/some/input/data';
rawdat = build_dataset(rawdir);
SPM_prepro_wrapper(rawdat, conndir, {'rea' 'reo' 'nor' 'smo'})


%% Make parameter structs for each CONN stage
setup = struct('functional', '^swrora.*\.nii$'...
            , 'T1dir', 'T1_rs'...
            , 'structural_sessionspecific', true...
            , 'groups_file', {fullfile(conndir, 'data', 'groups.csv')});
setup.cond_names = {'pre' 'post'};
setup.structural = {'^wro.*\.nii$', '^wcoregro.*\.nii$'};
setup.covar_files = {'^rp_a.*\.txt$', '^art_regression_outliers_swrora.*\.mat$'};

denoise = struct(...
    'some_arg', {'some_value'});

level1 = struct(...
    'some_arg', 'some_other_value');


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
crit = 1;
switch crit
    case 1
        gbas = build_dataset(fullfile(conndir, 'data')...
            , 'filt', 'ID'...
            , 'guard_str_match', false);
    case 2
        gbas = build_dataset(fullfile(conndir, 'data')...
            , 'filt', '~ROI'...
            , 'guard_str_match', false...
            , 'getfile', false);
    case 3
        gbas = build_dataset(fullfile(conndir, 'data'), 'filt', {'09' '13'});
    case 4
        gbas = build_dataset({conndir conndir}, 'subdir', 'data'...
            , 'filt', {'29' '35'});
end

g1s1 = build_dataset(fullfile(gbas(1).folder, {gbas.name}), 'filt', '_1');
g1s2 = build_dataset(fullfile(gbas(1).folder, {gbas.name}), 'filt', {'_2' '_3'});
grp1 = [g1s1 g1s2];



%% build and run batch from given struct of files (here CONN name is default)
BN_conn_batch(grp1, fullfile(conndir, 'Output'), 'Setup', setup)

% build batch from given struct of files, don't run (CONN name is default)
BN_conn_batch(grp1, fullfile(conndir, 'Output')...
    , 'do_batch', false...
    , 'Setup', setup)

% build batch from given struct of files, don't run, open in GUI
BN_conn_batch(grp1, fullfile(conndir, 'Output')...
    , 'do_batch', false...
    , 'GUI', true...
    , 'Setup', setup)