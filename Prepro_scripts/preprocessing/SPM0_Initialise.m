function SPM0_Initialise(indir, outdir, names, varargin)
%SPM0_INITIALISE

%--------------------------------------------------------------------------
% Initialise inputs
p = inputParser;
p.addRequired('indir', @ischar)
p.addRequired('outdir', @ischar)
p.addRequired('names', @isstruct)

% TODO : MATCH BIDS SPECIFICATION
p.addParameter('datdir', 'rs', @ischar)
p.addParameter('rawdir', 'rs_rawdata', @ischar)

p.parse(indir, outdir, names, varargin{:})
Arg = p.Results;


%% Loop to copy raw_data to new folder per subject
for sbji = 1:size(names, 1)
    srcfile = dir(fullfile(indir, names(sbji).name, Arg.rawdir, 'f*.nii'));
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
spm('Defaults','fMRI');
spm_jobman('initcfg');

end