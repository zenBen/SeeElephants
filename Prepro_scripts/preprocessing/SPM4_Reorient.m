function SPM4_Reorient(subjects, varargin)
%SPM4_REORIENT

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

    RESTING = spm_select('FPList', fullfile(sub_path, Arg.datdir), '^rf.*\.nii$');
    matrix = load(fullfile(sub_path, 'reorient.mat'));

    % Reorient images to AC
    matlabbatch{1}.spm.util.reorient.srcfiles = cellstr(RESTING);
    matlabbatch{1}.spm.util.reorient.transform.transM = matrix.reorient;
    matlabbatch{1}.spm.util.reorient.prefix = 'ro';

    spm_jobman('run', matlabbatch)
    clear matlabbatch
end
