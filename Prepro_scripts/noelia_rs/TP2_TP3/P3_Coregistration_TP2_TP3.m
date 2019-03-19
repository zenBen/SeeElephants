% SPM12 BATCH COREGISTRATION for multi-subject  single-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%----------------------------------------------------------------------
clear all
data_path='C:\Users\CBRU\TBI\data\';
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'};
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID036';'ID037';'ID039';'ID040'};

%% TP2 MEAN-T1 Coregistration
% Loop for lesion group
for g=1
    if g==1 % Patients with lesions
        for suje=2:length(les)
            sub_path=fullfile(data_path, (char(les(suje,:))), [(char(les(suje,:))) '_2']);
            cd (sub_path)
            rs=ls('*rs*');
            roMEAN_tp2 = spm_select('FPList', fullfile(sub_path, rs(3,1:2)), '^romean.*\.nii$');
            roT1_tp2 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^coregro.*\.nii$');
            roCFM = spm_select('FPList', fullfile(sub_path, '\Lesions_rs\'), 'roCFM.nii$');
            roCFM_mask = spm_select('FPList', fullfile(sub_path, '\Lesions_rs\'), 'roCFM_mask.nii$');
            clear matlabbatch
            % Coregistration
            matlabbatch{1}.spm.spatial.coreg.estimate.ref = {roMEAN_tp2};
            matlabbatch{1}.spm.spatial.coreg.estimate.source = {roT1_tp2};
            matlabbatch{1}.spm.spatial.coreg.estimate.other = {
                roCFM
                roCFM_mask
                 };
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
            spm_jobman('run',matlabbatch)
            clear roMEAN_tp2 roT1_tp2 roCFM rs matlabbatch
        end
    else % Patients with no visible lesions
        for suje=10%:length(noles)
            sub_path=fullfile(data_path, (char(noles(suje,:))), [(char(noles(suje,:))) '_2']);
            cd (sub_path)
            rs=ls('*rs*');
            roMEAN_tp2 = spm_select('FPList', fullfile(sub_path, rs(2,1:2)), '^ro_mean.*\.nii$');
            roT1_tp2 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^coregro.*\.nii$');
            clear matlabbatch
            % Coregistration
            matlabbatch{1}.spm.spatial.coreg.estimate.ref = {roMEAN_tp2};
            matlabbatch{1}.spm.spatial.coreg.estimate.source = {roT1_tp2};
            matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
            spm_jobman('run',matlabbatch)
            clear roMEAN_tp2 roT1_tp2 rs matlabbatch
        end
    end
end

%% TP3 MEAN-T1 COREGISTRATION
% Loop for lesion group
for g=1
    if g==1 % Patients with lesions
        for suje=2:length(les)
            if suje ~=12 && suje~=14
            sub_path=fullfile(data_path, (char(les(suje,:))), [(char(les(suje,:))) '_3']);
            cd (sub_path)
            rs=ls('*rs*');
            roMEAN_tp3 = spm_select('FPList', fullfile(sub_path, rs(3,1:2)), '^romean.*\.nii$');
            roT1_tp3 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^coregro.*\.nii$');
            roCFM = spm_select('FPList', fullfile(sub_path, '\Lesions_rs\'), 'roCFM.nii$');
            roCFM_mask = spm_select('FPList', fullfile(sub_path, '\Lesions_rs\'), 'roCFM_mask.nii$');
            clear matlabbatch
            % Coregistration
            matlabbatch{1}.spm.spatial.coreg.estimate.ref = {roMEAN_tp3};
            matlabbatch{1}.spm.spatial.coreg.estimate.source = {roT1_tp3};
            matlabbatch{1}.spm.spatial.coreg.estimate.other = {
                roCFM
                roCFM_mask};
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
            spm_jobman('run',matlabbatch)
            clear roMEAN_tp3 roT1_tp3 roCFM rs matlabbatch
            end
        end
    else %% Patients with no visible lesions
        for suje=10:length(noles)
            if suje~=13
            sub_path=fullfile(data_path, (char(noles(suje,:))), [(char(noles(suje,:))) '_3']);
            cd (sub_path)
            rs=ls('*rs*');
            roMEAN_tp3 = spm_select('FPList', fullfile(sub_path, rs(2,1:2)), '^ro_mean.*\.nii$');
            roT1_tp3 = spm_select('FPList', fullfile(sub_path, 'T1_rs'), '^coregro.*\.nii$');
            clear matlabbatch
            %% Coregistration
            matlabbatch{1}.spm.spatial.coreg.estimate.ref = {roMEAN_tp3};
            matlabbatch{1}.spm.spatial.coreg.estimate.source = {roT1_tp3};
            matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
            spm_jobman('run',matlabbatch)
            clear roMEAN_tp3 roT1_tp3 rs matlabbatch
            end
        end
    end
end




