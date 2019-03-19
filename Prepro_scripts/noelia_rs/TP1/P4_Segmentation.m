% SPM12 BATCH T1 SEGMENTATION for multi-suject single-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%--------------------------------------------------------------------

%NB:roCFM_mask was saved as a VOI on T1_rs to have the same dimensions and orientation as the T1. 

clear all
data_path='C:\Users\CBRU\TBI\data\'; %Set up path 
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'}; % ID of subjects with lesions
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID036';'ID037';'ID039';'ID040'};% ID of subjects with no visible lesions

%% Loop for patients
for g=1
    if g==1 % Patients with lesions
        for suje=2:length(les)
            sub_path=fullfile(data_path, char((les(suje,:))), [char((les(suje,:))) '_1']);
            cd (sub_path)
            roT1_1 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^ro.*\.nii$');
            roCFM_mask_1 = spm_select('FPList', fullfile(sub_path, '\Lesions_rs\'), 'roCFM_mask.nii$');
            clear matlabbatch
            % Segmentation T1 with CFM
            matlabbatch{1}.spm.tools.oldseg.data = {roT1_1};
            matlabbatch{1}.spm.tools.oldseg.output.GM = [0 0 1];
            matlabbatch{1}.spm.tools.oldseg.output.WM = [0 0 1];
            matlabbatch{1}.spm.tools.oldseg.output.CSF = [0 0 1];
            matlabbatch{1}.spm.tools.oldseg.output.biascor = 0;
            matlabbatch{1}.spm.tools.oldseg.output.cleanup = 0;
            matlabbatch{1}.spm.tools.oldseg.opts.tpm = {
                'C:\Program Files\spm12\tpm\TPM.nii,1'
                'C:\Program Files\spm12\tpm\TPM.nii,2'
                'C:\Program Files\spm12\tpm\TPM.nii,3'
                };
            matlabbatch{1}.spm.tools.oldseg.opts.ngaus = [2
                2
                2
                4];
            matlabbatch{1}.spm.tools.oldseg.opts.regtype = 'mni';
            matlabbatch{1}.spm.tools.oldseg.opts.warpreg = 1;
            matlabbatch{1}.spm.tools.oldseg.opts.warpco = 25;
            matlabbatch{1}.spm.tools.oldseg.opts.biasreg = 0.01;%medium regularisation
            matlabbatch{1}.spm.tools.oldseg.opts.biasfwhm = 60;
            matlabbatch{1}.spm.tools.oldseg.opts.samp = 3;
            matlabbatch{1}.spm.tools.oldseg.opts.msk = {roCFM_mask_1};
            spm_jobman('run',matlabbatch)
            clear roT1_1 roCFM_mask_1 matlabbatch
        end
    else % Patients with no visible lesions
        for suje=1:length(noles)
            sub_path=fullfile(data_path, (char(noles(suje,:))), [(char(noles(suje,:))) '_1']);
            roT1_1 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^ro.*\.nii$');
            clear matlabbatch
            % Segmentation T1
            matlabbatch{1}.spm.tools.oldseg.data = {roT1_1};
            matlabbatch{1}.spm.tools.oldseg.output.GM = [0 0 1];
            matlabbatch{1}.spm.tools.oldseg.output.WM = [0 0 1];
            matlabbatch{1}.spm.tools.oldseg.output.CSF = [0 0 1];
            matlabbatch{1}.spm.tools.oldseg.output.biascor = 0;
            matlabbatch{1}.spm.tools.oldseg.output.cleanup = 0;
            matlabbatch{1}.spm.tools.oldseg.opts.tpm = {
                'C:\Program Files\spm12\tpm\TPM.nii,1'
                'C:\Program Files\spm12\tpm\TPM.nii,2'
                'C:\Program Files\spm12\tpm\TPM.nii,3'
                };
            matlabbatch{1}.spm.tools.oldseg.opts.ngaus = [2
                2
                2
                4];
            matlabbatch{1}.spm.tools.oldseg.opts.regtype = 'mni';
            matlabbatch{1}.spm.tools.oldseg.opts.warpreg = 1;
            matlabbatch{1}.spm.tools.oldseg.opts.warpco = 25;
            matlabbatch{1}.spm.tools.oldseg.opts.biasreg = 0.01;%medium regularisation
            matlabbatch{1}.spm.tools.oldseg.opts.biasfwhm = 60;
            matlabbatch{1}.spm.tools.oldseg.opts.samp = 3;
            matlabbatch{1}.spm.tools.oldseg.opts.msk = {''};
            spm_jobman('run',matlabbatch)
            clear roT1_1 matlabbatch
        end
    end
end



