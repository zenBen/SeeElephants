function batch = CONN_setup(names, connfname, varargin)
%% CONN_SETUP
% 
% INPUT
%   names           struct array, MATLAB-format structure of files
%   connfname       string, name for your CONN project
% 
% VARARGIN
% TODO : FILL IN ALL PARAMETERS HERE
%   'num_sessions'  scalar, default = 1
%   'num_conds'     scalar, default = 1
%   'TR'            scalar, Repetition-Time (in seconds), default = 1.5
%   'dtdir'         string, name of data directory, default = "rs"
%   'T1dir'         string, name of T1 directory, default = "anat"
% 
% CALLS     spm_select()
% 
%--------------------------------------------------------------------------


% TODO - PROVIDE COMPLETE PARAMETER SPECIFICATION FOR CONN
%% Initialise defaults
p = inputParser;
p.addRequired('names', @isstruct)
p.addRequired('connfname', @ischar)

p.addParameter('save', true, @islogical)

% Basic settings
p.addParameter('num_sessions', 1, @isscalar)
p.addParameter('num_conds', 1, @isscalar)
p.addParameter('TR', 1.5, @isscalar)
p.addParameter('acq_type', 1, @isscalar)
p.addParameter('analyses', [1, 2], @isnumeric)
p.addParameter('voxelmask', 1, @isscalar)
p.addParameter('voxelres', 1, @isscalar)
p.addParameter('outputfiles', [0,1,1], @isnumeric)
p.addParameter('done', 1, @isscalar)
p.addParameter('ovw', 'No', @ischar)
p.addParameter('isnew', '0', @ischar)

% Data files: functional, structural, masks, and their parameters
% TODO : MATCH BIDS SPECIFICATION IN DEFAULTS
p.addParameter('dtdir', 'rs', @ischar)
p.addParameter('T1dir', 'anat', @ischar)
p.addParameter('func_rgx', '^swroraLASA.*\.nii$', @ischar)
p.addParameter('struc_rgx', '^wrofLASA.*\.nii$', @ischar)
p.addParameter('grey_rgx', '^wc1cor.*\.nii$', @ischar)
p.addParameter('white_rgx', '^wc2cor.*\.nii$', @ischar)
p.addParameter('csf_rgx', '^wc3cor.*\.nii$', @ischar)
p.addParameter('grey_dim', 1, @isscalar)
p.addParameter('white_dim', 3, @isscalar)
p.addParameter('csf_dim', 3, @isscalar)
% TODO : PARAMS FOR ROIs
p.addParameter('roidir', '', @ischar)

% Experiment conditions
% TODO: DEPENDS ON num_conds
p.addParameter('condname', {'rest'}, @iscellstr)
p.addParameter('condonset', 0, @isnumeric)
p.addParameter('conddur', inf, @isnumeric)

% 1ST level covariates
% TODO : SPECIFY PER SESSION
p.addParameter('covarname', {'motion', 'outliers'}, @iscellstr)
p.addParameter('covarf_rgx'...
    , {'^rp.*\.txt$', '^art_regression_outliers_swrora.*\.mat$'}, @iscellstr)

% 2nd level covariates
% TODO : BUILD COVARIATE FILE-READING FUNCTIONALITY
p.addParameter('subjname', {'group_BL', 'BDEA'}, @iscellstr)
eff2 = [-0.56;0.44;-0.56;-2.56;0.44;1.44;0.44;0.44...%decentered values:
        ;-0.56;1.44;-2.56;1.44;-0.56;0.44;0.44;0.44];
p.addParameter('subjeffects', {ones(16, 1) eff2}, @isnumeric)

p.parse(names, varargin{:});
Arg = p.Results;


%% Find all fMRI files: functional, structural, GM, WM, CSF
nsubjects = numel(names);
FUNC_FILE = cell(nsubjects, 1);
STRUC_FILE = cell(nsubjects, 1);
GMM_FILE = cell(nsubjects, 1);
WMM_FILE = cell(nsubjects, 1);
CSFM_FILE = cell(nsubjects, 1);

for s = 1:nsubjects
    pi = fullfile(names(s).folder, names(s).name);
    % Selects functional / anatomical volumes
    FUNC_FILE{s} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.dtdir), Arg.func_rgx));
    STRUC_FILE{s} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.struc_rgx));
    GMM_FILE{s} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.grey_rgx));
    WMM_FILE{s} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.white_rgx));
    CSFM_FILE{s} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.csf_rgx));
end


%% Create batch fields for setup
batch.filename = connfname;
batch.Setup.RT = Arg.TR;
batch.Setup.nsubjects = nsubjects;
batch.Setup.acquisitiontype = Arg.acq_type;
batch.Setup.analyses = Arg.analyses;
batch.Setup.voxelmask = Arg.voxelmask;
batch.Setup.voxelresolution = Arg.voxelres;
batch.Setup.outputfiles = Arg.outputfiles;

batch.Setup.done = Arg.done;
batch.Setup.overwrite = Arg.ovw;
batch.Setup.isnew = Arg.isnew;

% Define functional files (as found above)
for sbji = 1:nsubjects
    for si = 1:Arg.num_sessions
        batch.Setup.functionals{sbji}{si} = FUNC_FILE{sbji};
    end
end

% Define structural files (as found above)
for sbji = 1:nsubjects
    batch.Setup.structurals{sbji} = STRUC_FILE{sbji};
end

% Define grey, white, & CSF mask files (as found above) and their dimensions
for sbji = 1:nsubjects
    batch.Setup.masks.Grey.files{sbji} = GMM_FILE{sbji};
    batch.Setup.masks.Grey.dimensions = Arg.grey_dim;
    
    batch.Setup.masks.White.files{sbji} = WMM_FILE{sbji};
    batch.Setup.masks.White.dimensions = Arg.white_dim;
    
    batch.Setup.masks.CSF.files{sbji} = CSFM_FILE{sbji};
    batch.Setup.masks.CSF.dimensions = Arg.csf_dim;
end

% Define conditions
Arg.condonset = repmat(Arg.condonset, 1, numel(Arg.condname));
Arg.conddur = repmat(Arg.conddur, 1, numel(Arg.condname));
for ci = 1:Arg.num_conds
    batch.Setup.conditions.names{ci} = Arg.condname{ci};
    % TODO : FILL ALL PARAMETERS OF CONN CONDITIONS FIELD!!
    bat
    for sbji = 1:nsubjects
        for si = 1:Arg.num_sessions
            batch.Setup.conditions.onsets{ci}{sbji}{si} = Arg.condonset(ci);
            batch.Setup.conditions.durations{ci}{sbji}{si} = Arg.conddur(ci);
        end
    end
end

% Define 1st level covariates
% TODO : DOES CONN HAVE OTHER WAYS OF TAKING 1ST LEVEL COVARS??
batch.Setup.covariates.names = Arg.covarname;
for covi = 1:numel(Arg.covarname)
    for sbji = 1:nsubjects
        pi = fullfile(names(sbji).folder, names(sbji).name);
        batch.Setup.covariates.files{covi}{sbji}{1} = cellstr(spm_select(...
            'FPList', fullfile(pi, Arg.dtdir), Arg.covarf_rgx{covi}));
    end
end

% Define 2nd level covariates
% TODO : PARSE A FILE OF 2ND LEVEL SUBJECT-WISE COVARIATES
batch.Setup.subjects.names = Arg.subjname;
batch.Setup.subjects.effects{1} = Arg.subjeffects{1};
batch.Setup.subjects.effects{2} = Arg.subjeffects{2}; 
    

%% Save batch if required
if Arg.save 
    if isfield(batch, 'filename')
        save(batch.filename, 'batch')
    else
        error 'No save location defined in batch structure'
    end
end

end