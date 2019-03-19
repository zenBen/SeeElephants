function SPM0_Initialise(indir, outdir, names, varargin)
%SPM0_INITIALISE

%--------------------------------------------------------------------------
% Initialise inputs
p = inputParser;
p.addRequired('indir', @isstr);
p.addRequired('outdir', @isstr);
p.addRequired('names', @isstruct);

p.addParameter('datdir', 'rs', @isstr);
p.addParameter('rawdir', 'rs_rawdata', @isstr);

p.parse(indir, outdir, names, varargin{:});
Arg = p.Results;


%% Loop to copy raw_data to new folder per subject
for suje = 1:size(names, 1)
    %NOTE, NOELIA'S PATHS HAD THIS ENDING: % , [(names(suje).name) '_1']);
    srcfile = dir(fullfile(indir, names(suje).name, Arg.rawdir, 'f*.nii'));
    sub_path = fullfile(outdir, names(suje).name, Arg.datdir);
    if ~isdir(sub_path)
        mkdir(sub_path)
    end
    for sf = 1:length(srcfile)
        if ~exist(fullfile(sub_path, srcfile(sf).name), 'file')
            copyfile(fullfile(srcfile(sf).folder, srcfile(sf).name), sub_path)
        end
    end
    [srcfile.folder] = deal(sub_path);
    names(suje).sources = srcfile;
end

%----------------------------------------------------
% Initialise SPM
spm('Defaults','fMRI');
spm_jobman('initcfg');

end