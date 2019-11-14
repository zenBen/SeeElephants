%% Define our CONN project on disk
conndir = '~/Benslab/project_TBI';
connprj = 'TBI_testi_1';


%% Find data and SPM preprocess
rawdir = '~/some/input/data';
rawdat = build_dataset(rawdir);
SPM_prepro_wrapper(rawdat, conndir, {'rea' 'reo' 'nor' 'smo'})


%% Make parameter structs for each CONN stage
setup = struct('func_rgx', '^swrora.*\.nii$'...
            , 'struc_rgx', '^wcoregro.*\.nii$'...
            , 'T1dir', 'T1_rs');
        
denoise = struct(...
    'some_arg', {some_value});

level1 = struct(...
    'some_arg', some_other_value);


%% Find data and CONN batch it
% build and run batch from prompted directory - no filtering supported
BN_conn_batch('', fullfile(conndir, 'Output')...
    , 'prompt', true...
    , 'setup', setup...
    , 'connfname', connprj)

% build and run batch from given directory - no filtering supported
BN_conn_batch(fullfile(conndir, 'data'), fullfile(conndir, 'Output')...
    , 'setup', setup...
    , 'connfname', connprj)

% build datasets yourself, all types of filtering supported
grp0 = build_dataset(fullfile(conndir, 'data'), 'filt', 'ID', 'guard_str_match', false);

grp1 = build_dataset(fullfile(conndir, 'data'), 'filt', '~ROI', 'guard_str_match', false);

grp2 = build_dataset(conndir, 'subdir', 'data', 'filt', {'09' '13'});

grp3 = build_dataset({conndir conndir}, 'subdir', 'data', 'filt', {'29' '35'});

% build and run batch from given struct of files (here CONN name is default)
BN_conn_batch(grp1, fullfile(conndir, 'Output')...
    , 'setup', setup)

% build batch from given struct of files, don't run (CONN name is default)
BN_conn_batch(grp1, fullfile(conndir, 'Output')...
    , 'do_batch', false...
    , 'setup', setup)

% build batch from given struct of files, don't run, open in GUI
BN_conn_batch(grp1, fullfile(conndir, 'Output')...
    , 'do_batch', false...
    , 'GUI', true...
    , 'setup', setup)