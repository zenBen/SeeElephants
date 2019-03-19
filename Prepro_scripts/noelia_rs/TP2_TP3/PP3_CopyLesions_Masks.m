%%% Copy Lesion Masks from T1 Timepoint 1
clear all
data_path='F:\TBI\data\'; %Set up path
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'};

for suje=1:length(les)
    sub_path1=fullfile(data_path, (char(les(suje,:))), [(char(les(suje,:))) '_1']);
    lesion_path1=fullfile(sub_path1, 'Lesions_rs');
    sub_path2=fullfile(data_path, (char(les(suje,:))), [(char(les(suje,:))) '_2']);
    sub_path3=fullfile(data_path, (char(les(suje,:))), [(char(les(suje,:))) '_3']);
    cd(sub_path2)
    [status, message, messageid] = rmdir('Lesions', 's');
    if ~exist('Lesions_rs')
    mkdir Lesions_rs
    end
    copyfile(fullfile(lesion_path1,'CFM.nii'), 'Lesions_rs');
    copyfile(fullfile(lesion_path1,'CFM_mask.nii'),'Lesions_rs');
    copyfile(fullfile(lesion_path1,'roCFM.nii'), 'Lesions_rs');
    copyfile(fullfile(lesion_path1,'roCFM_mask.nii'), 'Lesions_rs');
    if suje~=12 && suje~=14
        cd(sub_path3)
        [status, message, messageid] = rmdir('Lesions', 's');
        if ~exist('Lesions_rs')
            mkdir Lesions_rs
        end
        copyfile(fullfile(lesion_path1,'CFM.nii'), 'Lesions_rs');
        copyfile(fullfile(lesion_path1,'CFM_mask.nii'),'Lesions_rs');
        copyfile(fullfile(lesion_path1,'roCFM.nii'), 'Lesions_rs');
        copyfile(fullfile(lesion_path1,'roCFM_mask.nii'), 'Lesions_rs');
    end
end