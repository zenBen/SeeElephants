function batch = CONN_Setup(names, batch, varargin)
%% CONN_SETUP
% 
% INPUT
%   names           [m n] struct array, MATLAB-format structure of files
%                   NOTE: m = number of *subjects*, n = number of *sessions*
%                   To build a multi-session analysis, you must provide exact
%                   paths to each recording for each subject. This is easily
%                   done using build_dataset() once for each session, and
%                   horizontally concatenating the results
%   batch           struct, batch structure to pass to CONN
% 
% VARARGIN
% TODO : FILL IN ALL PARAMETERS HERE
%   nsessions     scalar, default = 1
%   nconditions   scalar, default = 1
%   cond_names    cell string array, cell of condition name strings
%   RT            scalar, Repetition-Time (in seconds), default = 1.5
%   dtdir         string, name of data directory, default = "rs"
%   T1dir         string, name of T1 directory, default = "anat"
% 
% 
% CALLS     spm_select()
% 
%--------------------------------------------------------------------------

% TODO - HANDLE Setup.rois.dataset>0 I.E. HOW TO FIND FILES FOR XTRA DATASETS:
%        "one or several additional functional datasets (e.g. vdm files for 
%         susceptibility distorition, alternative functional files for ROI-
%         level timeseries extraction, etc.", ALSO SESSION-SPECIFIC GM, WM, CSF
% TODO - PROVIDE COMPLETE PARAMETER SPECIFICATION FOR CONN
% TODO : DOES CONN HAVE OTHER WAYS OF TAKING 1st / 2nd LEVEL COVARS??
% TODO : SPECIFY MORE GENERIC OR ELSE NULL DEFAULTS FOR COVARIATES
% TODO : MATCH BIDS SPECIFICATION IN FILE-FINDING DEFAULTS: REGEX, STD DIRS
% TODO : BUILD COVARIATE FILE-READING FUNCTIONALITY
% TODO : nscans - typically found from functionals?
% TODO : HANDLE importfile OPTION FOR CONN CONDITIONS FIELD!!


%% Initialise defaults
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('names', @isstruct)
p.addRequired('batch', @isstruct)

p.addParameter('save', true, @islogical)

% Basic settings
p.addParameter('RT', 1.5, @isscalar)
p.addParameter('nsubjects', size(names, 1), @isscalar)
p.addParameter('nsessions', size(names, 2), @isscalar)

% Data and anatomy directories to prepend regex in calls to spm_select()
p.addParameter('dtdir', 'rs', @ischar)
p.addParameter('T1dir', 'anat', @ischar)

% Data files: functional, structural, masks, and their parameters
p.addParameter('structural_sessionspecific', false, @islogical)
p.addParameter('functional', '^swroraLASA.*\.nii$', @ischar)
p.addParameter('structural', '^wrofLASA.*\.nii$', @ischar)
p.addParameter('grey_rgx', '^wc1cor.*\.nii$', @ischar)
p.addParameter('white_rgx', '^wc2cor.*\.nii$', @ischar)
p.addParameter('csf_rgx', '^wc3cor.*\.nii$', @ischar)
p.addParameter('grey_dim', 1, @isscalar)
p.addParameter('white_dim', 3, @isscalar)
p.addParameter('csf_dim', 3, @isscalar)

% FIXME : ROIs - these are complex structures with embedded nifti - need
%                another function to build them?
% names         : rois.names{nroi} char array of ROI name [defaults to ROI filename]
% files         : rois.files{nroi}{nsub}{nses} char array of roi file (rois.files{nroi}{nsub} char array of roi file, 
%                 to use the same roi for all sessions; or rois.files{nroi} char array of roi file, to use the same 
%                 roi for all subjects)
% dimensions    : rois.dimensions{nroi} number of ROI dimensions - # temporal components to extract from ROI [1] (set 
%                 to 1 to extract the average timeseries within ROI voxels; set to a number greater than 1 to extract 
%                 additional PCA timeseries within ROI voxels 
% weighted      : rois.weighted(nroi) 1/0 to use weighted average/PCA computation when extracting temporal components 
%                 from each ROI (BOLD signals are weighted by the ROI mask value at each voxel)
% multiplelabels: rois.multiplelabels(nroi) 1/0 to indicate roi file contains multiple labels/ROIs (default: set to 
%                 1 if there exist an associated .txt or .xls file with the same filename and in the same folder as 
%                 the roi file)
% mask          : rois.mask(nroi) 1/0 to mask with grey matter voxels [0] 
% regresscovariates: rois.regresscovariates(nroi) 1/0 to regress known first-level covariates before computing PCA 
%                 decomposition of BOLD signal within ROI [1 if dimensions>1; 0 otherwise] 
% dataset       : rois.dataset(nroi) index n to Secondary Dataset #n identifying the version of functional data 
%                 coregistered  to this ROI to extract BOLD timeseries from [1] (set to 0 to extract BOLD signal 
%                 from Primary Dataset instead; secondary datasets may be identified by their index or by their 
%                 label -see 'functional_label' preprocessing step)

% Experiment conditions
p.addParameter('cond_names', {''}, @(x) iscellstr(x) || ischar(x)) %#ok<*ISCLSTR>
p.addParameter('cond_onset', 0, @isnumeric)
p.addParameter('cond_dur', inf, @isnumeric)
p.addParameter('cond_param', 0, @isnumeric)
p.addParameter('cond_filter', [0.01 0.1], @(x) isnumeric(x) || iscell(x))

% 1ST level covariates
p.addParameter('covar_names', {'motion', 'outliers'}, @iscellstr)
p.addParameter('covar_files', {'^rp_a.*\.txt$', '^rs_swrora.*\.mat$'}, @iscellstr)

% 2nd level covariates
% effect_names  : subjects.effect_names{neffect} char array of second-level covariate name
% effects       : subjects.effects{neffect} vector of size [nsubjects,1] defining second-level effects
% group_names   : subjects.group_names{ngroup} char array of second-level group name
% groups        : subjects.group vector of size [nsubjects,1] (with values from 1 to ngroup) defining subject groups
% descrip       : (optional) subjects.descrip{neffect/ngroup} char array of effect/group description (long name; for display only)
p.addParameter('effects_file', '', @(x) iscellstr(x) || ischar(x))
p.addParameter('effect_names', {''}, @iscellstr)
p.addParameter('effects', {zeros(size(names, 1), 1)}, @iscell)
p.addParameter('effect_descrip', {}, @iscell)
p.addParameter('groups_file', '', @(x) iscellstr(x) || ischar(x))
p.addParameter('group_names', {''}, @iscellstr)
p.addParameter('groups', {}, @iscell)
p.addParameter('group_descrip', {}, @iscell)

% FIXME : Extra file-specification options
%  spmfiles        : Optionally, spmfiles{nsub} is a char array pointing to the 'SPM.mat' source file to extract Setup 
%                     information from for each subject (use alternatively spmfiles{nsub}{nses} for session-specific 
%                     SPM.mat files) 
%  unwarp_functionals: (for Setup.preprocessing.steps=='realign&unwarp&fieldmap') unwarp_functionals{nsub}{nses} char 
%                     array of voxel-displacement volumes (vdm* file; explicitly entering these volumes here superceeds CONN's 
%                     default option to search for/use vdm* files in same directory as functional data) 
%  fmap_functionals: (for Setup.preprocessing.steps=='vdm_create') fmap_functionals{nsub}{nses} char 
%                     array of fieldmap sequence files (magnitude1+phasediff or real1+imag1+real2+imag2 or fieldmap (Hz) volumes)
%  coregsource_functionals: (for Setup.preprocessing.steps=='functional_coregister/segment/normalize') 
%                     coregsource_functionals{nsub} char array of source volume for coregistration/normalization/
%                     segmentation (used only when preprocessing "coregtomean" field is set to 2, user-defined source 
%                     volumes are used in this case instead of either the first functional volume (coregtomean=0) or the 
%                     mean functional volume (coregtomean=1) for coregistration/normalization/segmentation) 

% Preprocessing
p.addParameter('steps', 'default_ss', @ischar)
p.addParameter('reorient', diag(ones(1, 4)), @isnumeric)

p.parse(names, batch, varargin{:});
Arg = p.Results;


%% Find all fMRI files: functional, structural, GM, WM, CSF
% Select functional volumes
FUNC_FILE = cell(Arg.nsubjects, Arg.nsessions);
for sbi = 1:Arg.nsubjects
    for ssi = 1:Arg.nsessions
        pi = fullfile(names(sbi, ssi).folder, names(sbi, ssi).name);
        FUNC_FILE{sbi}{ssi} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.dtdir), Arg.functional));
    end
end
% FIXME - IS NEEDED?? FUNC_FILE = cell(Arg.nsubjects, 1);
% for sbi = 1:Arg.nsubjects
%     pi = fullfile(names(sbi).folder, names(sbi).name);
%     FUNC_FILE{sbi} = cellstr(spm_select('FPList'...
%                             , fullfile(pi, Arg.dtdir), Arg.functional));
% end

% Selects mask / anatomical volumes
if Arg.structural_sessionspecific
    STRUC_FILE = cell(Arg.nsubjects, Arg.nsessions);
    GMM_FILE = cell(Arg.nsubjects, Arg.nsessions);
    WMM_FILE = cell(Arg.nsubjects, Arg.nsessions);
    CSFM_FILE = cell(Arg.nsubjects, Arg.nsessions);
    for sbi = 1:Arg.nsubjects
        for ssi = 1:Arg.nsessions
            pi = fullfile(names(sbi, ssi).folder, names(sbi, ssi).name);
            STRUC_FILE{sbi}{ssi} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.structural));
            GMM_FILE{sbi}{ssi} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.grey_rgx));
            WMM_FILE{sbi}{ssi} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.white_rgx));
            CSFM_FILE{sbi}{ssi} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.csf_rgx));
        end
    end
else
    STRUC_FILE = cell(Arg.nsubjects, 1);
    GMM_FILE = cell(Arg.nsubjects, 1);
    WMM_FILE = cell(Arg.nsubjects, 1);
    CSFM_FILE = cell(Arg.nsubjects, 1);
    for sbi = 1:Arg.nsubjects
        pi = fullfile(names(sbi).folder, names(sbi).name);
        STRUC_FILE{sbi} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.structural));
        GMM_FILE{sbi} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.grey_rgx));
        WMM_FILE{sbi} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.white_rgx));
        CSFM_FILE{sbi} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.T1dir), Arg.csf_rgx));
    end

end



%% Create top-level batch.Setup fields
if isscalar(Arg.RT)
    batch.Setup.RT = repmat(Arg.RT, 1, Arg.nsubjects);
end
batch.Setup.nsubjects = Arg.nsubjects;
batch.Setup.nsessions = Arg.nsessions;

batch.Setup.structural_sessionspecific = Arg.structural_sessionspecific;

batch.Setup.reorient = Arg.reorient;
batch.Setup.analyses = Arg.analyses;
batch.Setup.voxelmask = Arg.voxelmask;
batch.Setup.voxelresolution = Arg.voxelresolution;
batch.Setup.outputfiles = Arg.outputfiles;


%% GET FILES
% Define functional files (as found above)
for sbi = 1:Arg.nsubjects
    for ssi = 1:Arg.nsessions
        batch.Setup.functionals{sbi}{ssi} = FUNC_FILE{sbi}{ssi};
    end
end

% Define structural files (as found above)
% Define grey, white, & CSF mask files (as found above)
if Arg.structural_sessionspecific
    for sbi = 1:Arg.nsubjects
        for ssi = 1:Arg.nsessions
            batch.Setup.structurals{sbi}{ssi} = STRUC_FILE{sbi}{ssi};
            batch.Setup.masks.Grey.files{sbi}{ssi} = GMM_FILE{sbi}{ssi};
            batch.Setup.masks.White.files{sbi}{ssi} = WMM_FILE{sbi}{ssi};
            batch.Setup.masks.CSF.files{sbi}{ssi} = CSFM_FILE{sbi}{ssi};
        end
    end
else
    batch.Setup.structurals = STRUC_FILE;
    batch.Setup.masks.Grey.files = GMM_FILE;
    batch.Setup.masks.White.files = WMM_FILE;
    batch.Setup.masks.CSF.files = CSFM_FILE;
end
% Define grey, white, & CSF mask dimensions
batch.Setup.masks.Grey.dimensions = Arg.grey_dim;
batch.Setup.masks.White.dimensions = Arg.white_dim;
batch.Setup.masks.CSF.dimensions = Arg.csf_dim;


%% Define conditions
if ischar(Arg.cond_names)
    Arg.cond_names = {Arg.cond_names};
end
if isempty(cell2mat(Arg.cond_names))
    error 'Condition names must be defined: no defaults are possible'
end
nconditions = numel(Arg.cond_names);
batch.Setup.conditions.names = Arg.cond_names;
if isscalar(Arg.cond_onset)
    Arg.cond_onset = repmat(Arg.cond_onset, 1, nconditions);
end
if isscalar(Arg.cond_dur)
    Arg.cond_dur = repmat(Arg.cond_dur, 1, nconditions);
end
if isscalar(Arg.cond_param)
    Arg.cond_param = repmat(Arg.cond_param, 1, nconditions);
end
if ~iscell(Arg.cond_filter) || isscalar(Arg.cond_filter)
    Arg.cond_filter = repmat({Arg.cond_filter}, 1, nconditions);
end
for ci = 1:nconditions
    for sbi = 1:Arg.nsubjects
        for ssi = 1:Arg.nsessions
            batch.Setup.conditions.onsets{ci}{sbi}{ssi} = Arg.cond_onset(ci);
            batch.Setup.conditions.durations{ci}{sbi}{ssi} = Arg.cond_dur(ci);
        end
    end
end


%% Define 1st level covariates
batch.Setup.l1covariates.names = Arg.covarname;
if Arg.structural_sessionspecific
    for sbi = 1:Arg.nsubjects
        for covi = 1:numel(Arg.covarname)
            for ssi = 1:Arg.nsessions
                pi = fullfile(names(sbi, ssi).folder, names(sbi, ssi).name);
                batch.Setup.l1covariates.files{sbi}{covi}{ssi}{1} = cellstr(...
                    spm_select(...
                    'FPList', fullfile(pi, Arg.dtdir), Arg.covarf_rgx{covi}));
            end
        end
    end
else
    for sbi = 1:Arg.nsubjects
        for covi = 1:numel(Arg.covarname)
            pi = fullfile(names(sbi).folder, names(sbi).name);
            batch.Setup.l1covariates.files{sbi}{covi}{1} = cellstr(...
                spm_select(...
                'FPList', fullfile(pi, Arg.dtdir), Arg.covarf_rgx{covi}));
        end
    end
end


%% Define 2nd level covariates
% CONN_x.Setup.l2covariates you would need to add at least 2 more covariates 
% as discussed. One for patients and another for controls. You can check how 
% this is specified in the mat file. Here patients and controls covariates 
% are in rows 109-110 in CONN_x.Setup.l2covariates.names
% FIXME : CHECK THIS WORKS!!
if ~isempty(Arg.effects_file)
    if iscell(Arg.effects_file)
        l2 = readtable(Arg.effects_file{1}, 'ReadRowN', 1);
        if numel(Arg.effects_file) > 1
            for l2i = 2:numel(Arg.effects_file)
                l2 = join(l2, readtable(Arg.effects_file{l2i}, 'ReadRowN', 1));
            end
        end
    else
        l2 = readtable(Arg.effects_file, 'ReadRowNames', true);
    end
    dsci = ismember(l2.RowNames, 'description');
    if any(dsci)
        batch.Setup.subjects.descrip = l2(dsci, :);
        l2(dsci, :) = [];
    end
    batch.Setup.subjects.effect_names = l2.VariableNames;
    batch.Setup.subjects.effects = table2cell(l2);
else
    batch.Setup.subjects.descrip = Arg.effect_descrip;
    batch.Setup.subjects.effect_names = Arg.effect_names;
    batch.Setup.subjects.effects = Arg.effects;
end
% FIXME : REPEAT FOR GROUPS!


%% Setup preprocessing
batch.Setup.preprocessing.steps = Arg.steps;


%% Add other top-level fields of batch.Setup based on unmatched parameters
Unmatch_names = fieldnames(p.Unmatched);
for i = 1:numel(Unmatch_names)
    batch.Setup.(Unmatch_names{i}) = p.Unmatched.(Unmatch_names{i});
end


%% Save batch if required
if Arg.save 
    if isfield(batch, 'filename')
        save(batch.filename, 'batch')
    else
        error 'No save location defined in batch structure'
    end
end

end