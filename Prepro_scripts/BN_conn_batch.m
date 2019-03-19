function BN_conn_batch(indir, outdir, varargin)
%BN_CONN_BATCH batch preprocessing for multi-subject single-session data
%
% Description: 
%
% Syntax:
%   BN_conn_batch(indir, outdir, varargin)
%
% Input:
%   'indir'        Root directory of subject folders with files to process
%   'outdir'       Directory to write processed files
%
% varargin:
%   'subj_filt'      cell, use this to filter subjects by name, number, or both
%                    default = {}
%   'num_sessions'   scalar, default = 1
%   'num_conditions' scalar, default = 1
%   'connfname'      string, name of the conn output file,
%                    default = "conn_testi_DDMMYYYYHHMMSS"
%   'TR'             scalar, Repetition-Time (in seconds), default = 1.5
%   'dtdir'          string, name of data directory, default = "rs"
%   'T1dir'          string, name of T1 directory, default = "T1/oldseg_norm"
%   'prepro'         logical, flag preprocessing steps, default = false
%   'prep_steps'     numeric, numbers of the preprocessing steps to call,
%                    default = [1 4 6 7]
%   'prompt'         logical, prompt for data files, default = false
%   'GUI'            logical, call the CONN GUI after batch, default = false
%
% Output:
%   none
%
% NOTE
%
% CALLS    name_filter(), abspath(), dirflt(), conn, conn_batch(), spm_select()
%          SPM0_Initialise(), SPM1_Realignment(), SPM4_Reorient(),
%          SPM6_Normalize(), SPM7_Smmothing()
%
% REFERENCE:
%
% Version History:
%  13.06.2018 Created (Benjamin Cowley, Helsinki)
%
% Copyright(c) 2018:
%  Benjamin Cowley (Ben.Cowley@helsinki.fi),
%  Noelia Martinez-Molina (noelia.martinezmolina@helsinki.fi)
%
% This code is released under the MIT License
% http://opensource.org/licenses/mit-license.php
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Initialise -----------------------------------
p = inputParser;
p.addRequired('indir', @isstr);
p.addRequired('outdir', @isstr);

p.addParameter('subj_filt', {}, @iscell);
p.addParameter('num_sessions', 1, @isscalar);
p.addParameter('num_conditions', 1, @isscalar);
p.addParameter('connfname', ['conn_testi_' datestr(now, 30)], @isstr);
p.addParameter('TR', 1.5, @isscalar);
p.addParameter('dtdir', 'rs', @isstr);
p.addParameter('T1dir', fullfile('T1', 'oldseg_norm'), @isstr);
p.addParameter('prepro', false, @islogical);
p.addParameter('prep_steps', [1 4 6 7], @isnumeric);
p.addParameter('prompt', false, @islogical);
p.addParameter('GUI', false, @islogical);

p.parse(indir, outdir, varargin{:});
Arg = p.Results;


%% Set up paths and filter subjects ------------------------------------
% function spm_select() can't handle tilde-prefixed paths
indir = abspath(indir);
outdir = abspath(outdir);

% expecting a fixed directory structure for data and ROIs:
data_path = indir;%fullfile(indir, 'data');
rois_path = fullfile(indir, 'rois'); %obsolete when we use all ROIs

% Get names and Filter by subj_filt (cell array of strings or vector of inds)
names = dirflt(data_path, 'getfile', false);
if ~isempty(Arg.subj_filt)
    names = name_filter(names, Arg.subj_filt); 
end

nsubjects = numel(names);
nsessions = Arg.num_sessions;
nconditions = Arg.num_conditions;


%% Preprocess? -----------------------------------
if Arg.prepro
    % NB: Output path for SPM-processed data is set same as input path here
    SPM0_Initialise(data_path, data_path, names);
    Arg.prep_steps = sort(Arg.prep_steps);
    for i = 1:length(Arg.prep_steps)
        switch Arg.prep_steps(i)
            case 1
                SPM1_Realignment(names)
            case 4
                SPM4_Reorient(names)
            case 6
                SPM6_Normalize(names)
            case 7
                SPM7_Smoothing(names)
        end
    end
    % NB: Loop to remove raw_data from new per-subject folder 
    for suji = 1:size(names, 1)
        for rawi = 1:length(names(suji).sources)
            rwdt = fullfile(names(suji).sources(rawi).folder...
                            , names(suji).sources(rawi).name);
            if exist(rwdt, 'file'), delete(rwdt); end
        end
    end
end


%% Prompt for files, or read from given directory? ----------------------------
if Arg.prompt
    % Selects functional / anatomical volumes
    STRUCTURAL_FILE = cellstr(spm_select(1, '\.img$|\.nii$'...
        ,'Select anatomical volume', {}, data_path));
    if all(cellfun(@isempty, STRUCTURAL_FILE))
        error('BN_conn_batch:no_structural_file', 'Choose anatomy')
    end
    FUNCTIONAL_FILE = cellstr(spm_select(1, 'SPM\.mat$'...
        , 'Select first-level SPM.mat file', {}, data_path));
    if all(cellfun(@isempty, FUNCTIONAL_FILE))
        error('BN_conn_batch:no_SPM_file', 'Choose SPM')
    end
    % Selects TR (seconds)
    Arg.TR = inputdlg('Repetition-Time (seconds):', 'TR', 1, {num2str('2')});
    Arg.TR = str2double(Arg.TR{1});
else
    FUNCTIONAL_FILE = cell(nsubjects, 1);
    STRUCTURAL_FILE = cell(nsubjects, 1);

    for s = 1:nsubjects
        sub_path = fullfile(data_path, names(s).name); %[(names(1).name) '_1']);
        % Selects functional / anatomical volumes
        FUNCTIONAL_FILE{s} = cellstr(spm_select('FPList'...
            , fullfile(sub_path, Arg.dtdir), '^swrorfLASA.*\.nii$'));
        STRUCTURAL_FILE{s} = cellstr(spm_select('FPList'...
            , fullfile(sub_path, Arg.T1dir), '^wrofLASA.*\.nii$'));
    end
end


%% PREPARE & CONDUCT connectivity analyses -----------------------------------
clear batch;
batch.filename = fullfile(outdir, [Arg.connfname '.mat']);

%% CONN Setup ->
sbf_CONN_SETUP

%% CONN Denoising ->
sbf_CONN_DENOISE

%% CONN Analysis (1st-Level) ->
sbf_CONN_LVL1ANALYSIS

%% CALL THE CONN BATCH ->
conn_batch(batch);


%% CONN Display -----------------------------------
% launches conn gui to explore results
if Arg.GUI
    conn
    conn('load', batch.filename);
    conn gui_results
end


%% CONN Setup -----------------------------------
function sbf_CONN_SETUP
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
end


%% CONN Denoising  -----------------------------------
function sbf_CONN_DENOISE
    batch.Preprocessing.confounds.names =...
        {'White', 'CSF', 'motion','outliers', 'rest'};
    batch.Preprocessing.confounds.dimensions = {3,3,6,3,2};
    batch.Preprocessing.confounds.deriv = {0,0,1,0,0};
    batch.Preprocessing.done = 1;
    batch.Preprocessing.overwrite = 'No';
    batch.Denoising.filter = [0.01, 0.1]; %band-pass filter (values in Hz)
    batch.Denoising.done = 1;
end


%% CONN Analysis (1st-Level) -----------------------------------
function sbf_CONN_LVL1ANALYSIS
    % Sequential number identifying each set of independent first-level analyses
    batch.Analysis.analysis_number = 1;
    %1=ROI-to-ROI analysis, 2= seed-to-voxel analysis, 3= both;
    batch.Analysis.type = 3;
    % connectivity measure: 1 = 'correlation (bivariate)', 2 = 'correlation 
    % (semipartial)', 3 = 'regression (bivariate)', 4 = 'regression (multivariate)'
    batch.Analysis.measure = 1;
    % within-condition weight used {1 = 'none', 2 = 'hrf', 3 = 'hanning';
    batch.Analysis.weight = 2;
    % batch.Analysis.sources.names = {'pSTGR', 'IFGR'}; %(defaults to all ROIs)
    % batch.Analysis.sources.dimensions = {1,1};
    % batch.Analysis.sources.deriv = {0,0};
    batch.Analysis.done = 1;
    batch.Analysis.overwrite = 'No';
end

end % BN_conn_batch
