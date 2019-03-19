function SPM7_Smoothing(subjects, varargin)
%SPM7_SMOOTHING

%--------------------------------------------------------------------------
% Initialise inputs and pathnames
p = inputParser;
p.addRequired('subjects', @isstruct);

p.addParameter('datdir', 'rs', @isstr);

p.parse(subjects, varargin{:});
Arg = p.Results;


%% Loop for subjects
for suje = 1:size(subjects, 1)
    sub_path = fullfile(subjects(suje).folder, subjects(suje).name);%, [names(suje).name '_1']);

    wrorREST = spm_select('FPList'...
        , fullfile(sub_path, Arg.datdir), '^wrorf.*\.nii$');

     % Smoothing resting 8mm
    matlabbatch{1}.spm.spatial.smooth.data = cellstr(wrorREST);
    matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';

    spm_jobman ('run', matlabbatch)
    clear matlabbatch wrorREST
end

