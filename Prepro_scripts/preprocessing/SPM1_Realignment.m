function SPM1_Realignment(subjects, varargin)
%SPM1_REALIGNMENT This batch script analyses the Auditory fMRI dataset

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
    rs = spm_select('FPList', fullfile(sub_path, Arg.datdir), '^f.*\.nii$');

    % Spatial realignment
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {cellstr(rs(2:end, :))}';
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

    spm_jobman('run', matlabbatch);
    clear matlabbatch
end


