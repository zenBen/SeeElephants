% SPM12 BATCH T1 SEGMENTATION for multi-suject single-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%--------------------------------------------------------------------

%NB:roCFM_mask was saved as a VOI on T1_rs to have the same dimensions and orientation as the T1.

clear all
data_path='F:\TBI\data\'; %Set up path
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'}; % ID of subjects with lesions
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID036';'ID037';'ID039';'ID040'};% ID of subjects with no visible lesions

%% Segmentation T1 TP2
% Loop for group
for g=2
    if g==1 %% Patients with lesions
        for suje=4:length(les)
            %% Segmentation T1 with CFM
            sub_path=fullfile(data_path, char((les(suje,:))), [char((les(suje,:))) '_2']);
            cd (sub_path)
            roT1_2 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^coregro.*\.nii$');
            roCFM_mask_2 = spm_select('FPList', fullfile(sub_path, '\Lesions_rs\'), 'roCFM_mask.nii$');
            clear matlabbatch
            matlabbatch{1}.spm.tools.oldseg.data = {roT1_2};
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
            matlabbatch{1}.spm.tools.oldseg.opts.msk = {roCFM_mask_2};
            spm_jobman('run',matlabbatch)
            clear roT1_2 roCFM_mask_2 matlabbatch
        end
        
    else %% Patients with no visible lesions
        for suje=10:length(noles)
            if suje~=14 && suje~=15
                sub_path=fullfile(data_path, (char(noles(suje,:))), [(char(noles(suje,:))) '_2']);
                roT1_2 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^coregro.*\.nii$');
                clear matlabbatch
                matlabbatch{1}.spm.tools.oldseg.data = {roT1_2};
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
                clear roT1_2 matlabbatch
            end
        end
    end
end
%% Segmentation T1 TP3
% Loop for group
for g=2
    if g==1 %% Patients with lesions
        for suje=4:length(les)
            if suje ~=12 && suje~=14
                %% Segmentation T1 with CFM
                sub_path=fullfile(data_path, char((les(suje,:))), [char((les(suje,:))) '_3']);
                cd (sub_path)
                roT1_3 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^coregro.*\.nii$');
                roCFM_mask_3 = spm_select('FPList', fullfile(sub_path, '\Lesions_rs\'), 'roCFM_mask.nii$');
                clear matlabbatch
                matlabbatch{1}.spm.tools.oldseg.data = {roT1_3};
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
                matlabbatch{1}.spm.tools.oldseg.opts.msk = {roCFM_mask_3};
                spm_jobman('run',matlabbatch)
                clear roT1_3 roCFM_mask_3 matlabbatch
            end
        end
    else %% Patients with no visible lesions
        for suje=4:length(noles)
            if suje~=13 && suje~=14 && suje~=15
                sub_path=fullfile(data_path, (char(noles(suje,:))), [(char(noles(suje,:))) '_3']);
                roT1_3 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^coregro.*\.nii$');
                clear matlabbatch
                matlabbatch{1}.spm.tools.oldseg.data = {roT1_3};
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
                clear roT1_3 matlabbatch
            end
        end
    end
end