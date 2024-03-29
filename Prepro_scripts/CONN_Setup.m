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


% TODO - PROVIDE COMPLETE PARAMETER SPECIFICATION FOR CONN
%   FIXME - Options: enabled analyses
%   FIXME - ROIs, Conditions, Covars 1st 2nd, Advanced Options

% TODO : MATCH BIDS SPECIFICATION IN FILE-FINDING DEFAULTS: REGEX, STD DIRS
% TODO : nscans - typically found from functionals?

% TODO : FIX DIMENSIONS FIELDS OF MASKS

% TODO - HANDLE Setup.rois.dataset>0 I.E. HOW TO FIND FILES FOR XTRA DATASETS:
%        "one or several additional functional datasets (e.g. vdm files for 
%         susceptibility distorition, alternative functional files for ROI-
%         level timeseries extraction, etc.", ALSO SESSION-SPECIFIC GM, WM, CSF
% TODO : FIX ROI EXTRA PARAMETERS?

% TODO : CHECK CONDITIONS SPECIFICATION WHEN NCOND ~= NSESSIONS
% TODO : HANDLE importfile OPTION FOR CONN CONDITIONS FIELD!!

% TODO : L1 COVARIATES - ANY MORE THAN MOTION AND OUTLIERS??

% TODO : ARE PREPROCESSING PARAMETERS NEEDED?



%% Initialise defaults
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('names', @isstruct)
p.addRequired('batch', @isstruct)

p.addParameter('save', true, @islogical)
p.addParameter('new', 1, @isscalar)

% Basic settings
p.addParameter('nsubjects', size(names, 1), @isscalar)
p.addParameter('nsessions', size(names, 2), @isscalar)
p.addParameter('RT', 1.5, @isscalar)

% Data and anatomy directories to prepend regex in calls to spm_select()
p.addParameter('dtdir', 'rs', @ischar)
p.addParameter('T1dir', 'anat', @ischar)

% Data files: functional, structural, masks, and their parameters
p.addParameter('structural_sessionspecific', false, @islogical)
p.addParameter('functional', '^swroraLASA.*\.nii$', @(x) ischar(x) || iscellstr(x))
p.addParameter('structural', '^wrofLASA.*\.nii$', @(x) ischar(x) || iscellstr(x))
p.addParameter('grey_rgx', '^wc1cor.*\.nii$', @(x) ischar(x) || iscellstr(x))
p.addParameter('white_rgx', '^wc2cor.*\.nii$', @(x) ischar(x) || iscellstr(x))
p.addParameter('csf_rgx', '^wc3cor.*\.nii$', @(x) ischar(x) || iscellstr(x))
% p.addParameter('grey_dim', 1, @isnumeric)
% p.addParameter('white_dim', 1, @isnumeric)
% p.addParameter('csf_dim', 1, @isnumeric)

% ROIs
p.addParameter('roi_names', {''}, @(x) ischar(x) || iscellstr(x))
p.addParameter('roi_files', {''}, @(x) ischar(x) || iscellstr(x))
% dimensions    : rois.dimensions{nroi} number of ROI dimensions - # temporal components to extract from ROI [1] (set 
%                 to 1 to extract the average timeseries within ROI voxels; set to a number greater than 1 to extract 
%                 additional PCA timeseries within ROI voxels 
p.addParameter('roi_dim', 1, @isnumeric)
% FIXME : ARE ANY ROI PARAMS BELOW HERE NEEDED??
% weighted      : rois.weighted(nroi) 1/0 to use weighted average/PCA computation when extracting temporal components 
%                 from each ROI (BOLD signals are weighted by the ROI mask value at each voxel)
p.addParameter('roi_weight', 1, @isnumeric)
% multiplelabels: rois.multiplelabels(nroi) 1/0 to indicate roi file contains multiple labels/ROIs (default: set to 
%                 1 if there exist an associated .txt or .xls file with the same filename and in the same folder as 
%                 the roi file)
p.addParameter('roi_multilabel', 1, @isnumeric)
% mask          : rois.mask(nroi) 1/0 to mask with grey matter voxels [0] 
p.addParameter('roi_mask', 0, @isnumeric)
% regresscovariates: rois.regresscovariates(nroi) 1/0 to regress known first-level covariates before computing PCA 
%                 decomposition of BOLD signal within ROI [1 if dimensions>1; 0 otherwise] 
p.addParameter('roi_regresscovar', 1, @isnumeric)
% dataset       : rois.dataset(nroi) index n to Secondary Dataset #n identifying the version of functional data 
%                 coregistered  to this ROI to extract BOLD timeseries from [1] (set to 0 to extract BOLD signal 
%                 from Primary Dataset instead; secondary datasets may be identified by their index or by their 
%                 label -see 'functional_label' preprocessing step)
p.addParameter('roi_dataset', 1, @isnumeric)

% Experiment conditions
p.addParameter('cond_names', {''}, @(x) iscellstr(x) || ischar(x))
p.addParameter('cond_onset', 0, @isnumeric)
p.addParameter('cond_dur', inf, @isnumeric)
p.addParameter('cond_param', 0, @isnumeric)
p.addParameter('cond_filter', [0.01 0.1], @(x) isnumeric(x) || iscell(x))

% 1ST level covariates
p.addParameter('covar_names', {'motion' 'outliers'}, @iscellstr)
p.addParameter('covar_files', {'' ''}, @iscellstr)

% 2nd level covariates
p.addParameter('effects_file', '', @(x) iscellstr(x) || ischar(x))
p.addParameter('effect_names', {''}, @iscellstr) %#ok<*ISCLSTR>
p.addParameter('effects', {}, @iscell)
p.addParameter('effect_descrip', {}, @iscell)
p.addParameter('groups_file', '', @(x) iscellstr(x) || ischar(x))
p.addParameter('group_names', {''}, @iscellstr)
p.addParameter('groups', ones(size(names, 1), 1), @isnumeric)
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


%% Create top-level batch.Setup fields
batch.Setup.isnew = Arg.new;
batch.Setup.nsubjects = Arg.nsubjects;
batch.Setup.nsessions = Arg.nsessions;
batch.Setup.RT = one2many(Arg.RT, 1, Arg.nsubjects);
batch.Setup.structural_sessionspecific = Arg.structural_sessionspecific;


%% DEFINE ROIs
if any(strlength(Arg.roi_files))
%     error 'ROI files must be defined - no defaults are possible'
    Arg.roi_files = Arg.roi_files(:); %set in column order
    nroi = size(Arg.roi_files, 1);
    for ri = 1:nroi

        if size(Arg.roi_files, 2) == Arg.nsubjects    % ROI files per subject?
            for sbi = 1:size(Arg.roi_files, 2)

                if size(Arg.roi_files, 3) == Arg.nsessions % ROI files per session?
                    for ssi = 1:size(Arg.roi_files, 3)
                        batch.Setup.rois.files{ri}{sbi}{ssi} =...
                                                    Arg.roi_files{ri}{sbi}{ssi};
                    end
                else
                    batch.Setup.rois.files{ri}{sbi} = Arg.roi_files{ri}{sbi};
                end
            end
        else
            batch.Setup.rois.files{ri} = Arg.roi_files{ri};
        end
    end

    % names : rois.names{nroi} char array of ROI name [defaults to ROI filename]
    if any(strlength(Arg.roi_names))
        if numel(Arg.roi_names) ~= nroi
            error('CONN_Setup:ROIs', 'Mismatch: %d ROI names vs %d ROI files'...
                , numel(Arg.roi_names), nroi)
        end
        for ri = 1:nroi
            batch.Setup.rois.names{ri} = Arg.roi_names{ri};
        end
    end
    % dimensions    : rois.dimensions{nroi} number of ROI dimensions
    Arg.roi_dim = one2many(Arg.roi_dim, 1, nroi); 
    for ri = 1:nroi
        batch.Setup.rois.dimensions{ri} = Arg.roi_dim(ri);
    end
    % weighted      : rois.weighted(nroi) 1/0 to use weighted avg/PCA computation
    batch.Setup.rois.weighted = one2many(Arg.roi_weight, 1, nroi);
    % multiplelabels: rois.multiplelabels(nroi) 1/0 roi file has multi labels/ROIs
    batch.Setup.rois.multiplelabels = one2many(Arg.roi_multilabel, 1, nroi);
    % mask          : rois.mask(nroi) 1/0 to mask with grey matter voxels [0]
    batch.Setup.rois.mask = one2many(Arg.roi_mask, 1, nroi);
    % regresscovariates: rois.regresscovariates(nroi) 1/0 to regress known first-level covariates before computing PCA 
    %                 decomposition of BOLD signal within ROI [1 if dimensions>1; 0 otherwise] 
    batch.Setup.rois.regresscovariates = one2many(Arg.roi_regresscovar, 1, nroi);
    % dataset       : rois.dataset(nroi) index n to Secondary Dataset
    batch.Setup.rois.dataset = one2many(Arg.roi_dataset, 1, nroi);
end


%% DEFINE CONDITIONS
if ischar(Arg.cond_names)
    Arg.cond_names = {Arg.cond_names};
end
if ~any(strlength(Arg.cond_names))
    error 'Condition names must be defined: no defaults are possible'
end
nconditions = numel(Arg.cond_names);
batch.Setup.conditions.names = Arg.cond_names;
Arg.cond_onset = one2many(Arg.cond_onset, 1, nconditions);
Arg.cond_dur = one2many(Arg.cond_dur, 1, nconditions);
tmp = [nconditions, Arg.nsubjects, Arg.nsessions];
batch.Setup.conditions.onsets = sbf_empty_nests(tmp);
batch.Setup.conditions.durations = sbf_empty_nests(tmp);
for ci = 1:nconditions
    for sbi = 1:Arg.nsubjects
%FIXME - WHAT ABOUT WHEN NCONDITIONS ~= NSESSIONS?!
%         for ssi = 1:Arg.nsessions
            batch.Setup.conditions.onsets{ci}{sbi}{ci} = Arg.cond_onset(ci);
            batch.Setup.conditions.durations{ci}{sbi}{ci} = Arg.cond_dur(ci);
%         end
    end
end
batch.Setup.conditions.param = one2many(Arg.cond_param, 1, nconditions);
if ~iscell(Arg.cond_filter) || isscalar(Arg.cond_filter)
    Arg.cond_filter = repmat({Arg.cond_filter}, 1, nconditions);
end
batch.Setup.conditions.filter = Arg.cond_filter;

    function EN = sbf_empty_nests(ns)
        EN = cell(1, ns(1));
        if ~isscalar(ns)
            [EN{:}] = deal(sbf_empty_nests(ns(2:end)));
        end
    end


%% Define 1st level covariates
batch.Setup.covariates.names = Arg.covar_names;
if ~any(strlength(Arg.covar_files))
    error 'Covariate file-index regex must be defined: no defaults are known!'
end
    
if Arg.structural_sessionspecific
    for covi = 1:numel(Arg.covar_names)
        for sbi = 1:Arg.nsubjects
            for ssi = 1:Arg.nsessions
                pi = fullfile(...
                    names(sbi, ssi).folder, names(sbi, ssi).name, Arg.dtdir);
                batch.Setup.covariates.files{covi}{sbi}{ssi} = cellstr(...
                    spm_select('FPList', pi, Arg.covar_files{ssi, covi}));
            end
        end
    end
else
    for covi = 1:numel(Arg.covar_names)
        for sbi = 1:Arg.nsubjects
            pi = fullfile(names(sbi).folder, names(sbi).name, Arg.dtdir);
            batch.Setup.covariates.files{covi}{sbi}{1} =...
                cellstr(spm_select('FPList', pi, Arg.covar_files{covi}));
        end
    end
end


%% Define 2nd level covariates
l2type = {'group' 'effect'};
batch.Setup.subjects = cell2struct({{} {}}, strcat(l2type, '_descrip'), 2);
for l2t = l2type
    l2file = Arg.([l2t{:} 's_file']);
    l2desc = [l2t{:} '_descrip'];
    l2name = [l2t{:} '_names'];
    l2vals = [l2t{:} 's'];
    if ~isempty(l2file)
        if iscell(l2file)
            l2 = readtable(l2file{1}, 'ReadRowN', 1);
            if numel(l2file) > 1
                for l2i = 2:numel(l2file)
                    tmp = readtable(l2file{l2i}, 'ReadRowN', 1);
                    l2 = join(l2, tmp, 'Keys', 'RowNames');
                end
            end
        else
            l2 = readtable(l2file, 'ReadRowNames', true);
        end
        % assign L2 covariate names
        batch.Setup.subjects.(l2name) = l2.Properties.VariableNames;
        n = size(l2, 2);
        % assign L2 covariate descriptions (and cut from table)
        dsci = ismember(lower(l2.Properties.RowNames), 'description');
        if any(dsci)
            batch.Setup.subjects.(l2desc)(end+1:end+n) = l2{dsci, :};
            l2(dsci, :) = [];
        else
            batch.Setup.subjects.(l2desc)(end+1:end+n) = cell(1, n);
        end
        for sbi = 1:size(l2, 1)
            if strcmp(l2t, 'group')
                batch.Setup.subjects.(l2vals)(sbi) = find(l2{sbi, :});
            else
                batch.Setup.subjects.(l2vals){sbi} = ...
                                    str2double(table2cell(l2(sbi, :)));
            end
        end
    else
        n = length(Arg.(l2name));
        if any(strlength(Arg.(l2name)))
            batch.Setup.subjects.(l2name) = Arg.(l2name);
        end
        if ~isempty(Arg.(l2vals))
            batch.Setup.subjects.(l2vals) = Arg.(l2vals);
        end
        if ~isempty(Arg.(l2desc))
            batch.Setup.subjects.(l2desc){end+1:end+n} = Arg.(l2desc);
        else
            batch.Setup.subjects.(l2desc)(end+1:end+n) = cell(1, n);
        end
    end
end


%% Setup preprocessing
% batch.Setup.preprocessing.steps = Arg.steps;


%% Find all fMRI files: functional, structural, GM, WM, CSF
% Select functional volumes
FUNC_FILE = cell(Arg.nsubjects, Arg.nsessions);
for sbi = 1:Arg.nsubjects
    for ssi = 1:Arg.nsessions
        pi = fullfile(names(sbi, ssi).folder, names(sbi, ssi).name);
        FUNC_FILE{sbi, ssi} = cellstr(spm_select('FPList'...
                                , fullfile(pi, Arg.dtdir), Arg.functional));
    end
end

% Selects mask / anatomical volumes
STRUC_FILE = sbf_get_structurals(Arg.structural);
GMM_FILE = sbf_get_structurals(Arg.grey_rgx);
WMM_FILE = sbf_get_structurals(Arg.white_rgx);
CSFM_FILE = sbf_get_structurals(Arg.csf_rgx);

function F = sbf_get_structurals(rgx)
    if Arg.structural_sessionspecific
        F = cell(Arg.nsubjects, Arg.nsessions);

        % Find files
        ngrp = numel(batch.Setup.subjects.group_names);
        if ngrp > 1 && ngrp == size(rgx, 1)
            % Structurals are session- and group-specific
            for sb = 1:Arg.nsubjects
                g = batch.Setup.subjects.groups(sb);
                for sn = 1:Arg.nsessions
                    ps = fullfile(...
                      names(sb, sn).folder, names(sb, sn).name, Arg.T1dir);
                    F{sb, sn} = cellstr(spm_select('FPList', ps, rgx{g, sn}));
                    if isempty(F{sb, sn})
                        warning('CONN_Setup:no_file_found'...
                            , 'No %s file for sbj %s: Check structural & group specs'...
                            , rgx{sn}, names(sb, sn).name)
                    end
                end
            end
        else
            % Structurals are session- but not group-specific
            rgx = one2many(rgx, 1, Arg.nsessions);
            for sb = 1:Arg.nsubjects
                for sn = 1:Arg.nsessions
                    ps = fullfile(...
                      names(sb, sn).folder, names(sb, sn).name, Arg.T1dir);
                    F{sb, sn} = cellstr(spm_select('FPList', ps, rgx{sn}));
                    if isempty(F{sb, sn})
                        warning('CONN_Setup:no_file_found'...
                            , 'No %s file for sbj %s: Check structural spec'...
                            , rgx{sn}, names(sb, sn).name)
                    end
                end
            end
        end
    else
        % No group/session differences in structural/mask specs
        F = cell(Arg.nsubjects, 1);
        for ix = 1:Arg.nsubjects
            pathi = fullfile(names(ix).folder, names(ix).name, Arg.T1dir);
            F{ix} = cellstr(spm_select('FPList', pathi, rgx));
        end
    end

end


%% ADD FILES TO BATCH
% Define functional files (as found above)
for sbi = 1:Arg.nsubjects
    for ssi = 1:Arg.nsessions
        batch.Setup.functionals{sbi}{ssi} = FUNC_FILE{sbi, ssi};
    end
end

% Define structural files (as found above)
% Define grey, white, & CSF mask files (as found above)
if Arg.structural_sessionspecific
    for sbi = 1:Arg.nsubjects
        for ssi = 1:Arg.nsessions
            batch.Setup.structurals{sbi}{ssi} = STRUC_FILE{sbi, ssi};
            batch.Setup.masks.Grey.files{sbi}{ssi} = GMM_FILE{sbi, ssi};
            batch.Setup.masks.White.files{sbi}{ssi} = WMM_FILE{sbi, ssi};
            batch.Setup.masks.CSF.files{sbi}{ssi} = CSFM_FILE{sbi, ssi};
        end
    end
else
    batch.Setup.structurals = STRUC_FILE;
    batch.Setup.masks.Grey.files = GMM_FILE;
    batch.Setup.masks.White.files = WMM_FILE;
    batch.Setup.masks.CSF.files = CSFM_FILE;
end

% Define grey, white, & CSF mask dimensions
% Arg.grey_dim = one2many(Arg.grey_dim, Arg.nsubjects, Arg.nsessions);
% Arg.white_dim = one2many(Arg.white_dim, Arg.nsubjects, Arg.nsessions);
% Arg.csf_dim = one2many(Arg.csf_dim, Arg.nsubjects, Arg.nsessions);
% batch.Setup.masks.Grey.dimensions = Arg.grey_dim;
% batch.Setup.masks.White.dimensions = Arg.white_dim;
% batch.Setup.masks.CSF.dimensions = Arg.csf_dim;


%% LAST: Add any unmatched parameters as top-level fields of batch.Setup
Unmatch_names = fieldnames(p.Unmatched);
for i = 1:numel(Unmatch_names)
    batch.Setup.(Unmatch_names{i}) = p.Unmatched.(Unmatch_names{i});
end


%% Save batch if required
if Arg.save 
    if isfield(batch, 'filename')
        [pth, ~, ~] = fileparts(batch.filename);
        if ~isfolder(pth), mkdir(pth); end
        save(batch.filename, 'batch')
    else
        error 'No save location defined in batch structure'
    end
end

    function mat = one2many(testi, r, c)
        if ischar(testi)
            mat = repmat({testi}, r, c);
        elseif isscalar(testi)
            mat = repmat(testi, r, c);
        else
            mat = testi;
        end
    end

end