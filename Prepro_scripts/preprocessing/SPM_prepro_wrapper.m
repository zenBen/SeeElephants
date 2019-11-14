function SPM_prepro_wrapper(names, outdir, varargin)
%SPM_PREPRO_WRAPPER
% 
% INPUT
%   names
%   outdir
% VARARGIN
%   'prep_steps'     numeric, numbers of the preprocessing steps to call,
%                    default = [1 4 6 7]
% 
% CALLS SPM1_Realignment(), SPM4_Reorient(), SPM6_Normalize(), SPM7_Smmothing()
%------------------------------------------------------------------------


%% Initialise inputs
pp = [1 4 6 7];
p = inputParser;
p.addRequired('names', @isstruct)
p.addRequired('outdir', @ischar)

% TODO : MATCH BIDS SPECIFICATION FOR FILE STORAGE LOCATIONS
p.addParameter('datdir', 'rs', @ischar)
p.addParameter('rawdir', 'rs_rawdata', @ischar)
p.addParameter('prep_steps', pp, @(x) isnumeric(x) || iscellstr(x))%#ok<ISCLSTR>

p.parse(names, outdir, varargin{:})
Arg = p.Results;

outdir = fullfile(abspath(outdir), 'data');


%% Loop to copy raw_data to new folder per subject
for sbji = 1:size(names, 1)
    srcfile = dir(...
        fullfile(names(sbji).folder, names(sbji).name, Arg.rawdir, 'f*.nii'));
    sub_path = fullfile(outdir, names(sbji).name, Arg.datdir);
    if ~isfolder(sub_path)
        mkdir(sub_path)
    end
    for sf = 1:length(srcfile)
        if ~exist(fullfile(sub_path, srcfile(sf).name), 'file')
            copyfile(fullfile(srcfile(sf).folder, srcfile(sf).name), sub_path)
        end
    end
    [srcfile.folder] = deal(sub_path);
    names(sbji).sources = srcfile;
end

%----------------------------------------------------
% Initialise SPM
spm('Defaults', 'fMRI')
spm_jobman('initcfg')


%% Perform requested preprocessing steps
if iscellstr(Arg.prep_steps)
    preps = {'realignment' 'reorient' 'normalize' 'smooth'};
    idx = startsWith(preps, Arg.prep_steps, 'IgnoreCase', true);
    Arg.prep_steps = pp(idx);
end
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
for sbji = 1:size(names, 1)
    for rawi = 1:length(names(sbji).sources)
        rwdt = fullfile(names(sbji).sources(rawi).folder...
                        , names(sbji).sources(rawi).name);
        if exist(rwdt, 'file'), delete(rwdt); end
    end
end


end