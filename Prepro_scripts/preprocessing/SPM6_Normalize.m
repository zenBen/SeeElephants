function SPM6_Normalize(subjects, varargin)
%SPM6_NORMALIZE

%--------------------------------------------------------------------------
% Initialise inputs and pathnames
p = inputParser;
p.addRequired('subjects', @isstruct);

p.addParameter('datdir', 'rs', @isstr);
p.addParameter('T1dir', fullfile('T1', 'oldseg_norm'), @isstr);

p.parse(subjects, varargin{:});
Arg = p.Results;


%% Loop for subjects
for suje = 1:size(subjects, 1)
    sub_path = fullfile(subjects(suje).folder, subjects(suje).name);%, [names(suje).name '_1']);

    rorREST = spm_select('FPList'...
                        , fullfile(sub_path, Arg.datdir), '^rorf.*\.nii$');  
    matrix = spm_select('FPList'...
                        , fullfile(sub_path, Arg.T1dir), 'seg_sn.*\.mat$');  

    % Normalization resting
    matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {matrix};
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = cellstr(rorREST);
    matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
    matlabbatch{1}.spm.spatial.normalise.write.roptions.bb =...
                                                        [-78 -112 -65 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
    matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
  
   spm_jobman('run', matlabbatch)
   clear matlabbatch rorRS matrix
   
end


