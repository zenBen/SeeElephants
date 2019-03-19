% SPM12 BATCH AC REORIENTATION for multi-subject multi-session data
% Copyright (c) 2018: Noelia Martinez-Molina
%----------------------------------------------------------------------
clear all
data_path='C:\Users\CBRU\TBI\data\';
les={'ID001';'ID002';'ID003';'ID007';'ID009';'ID010';'ID013';'ID018';'ID029';'ID031';'ID032';'ID034';'ID035';'ID038'};
noles={'ID005';'ID006';'ID008';'ID012';'ID014';'ID015';'ID016';'ID017';'ID019';'ID020';'ID026';'ID033';'ID036';'ID037';'ID039';'ID040'};
all=vertcat(les,noles);

%% Loop for subjects
for suje=[26:29]
    sub_path2=fullfile(data_path, char((all(suje,:))), [char((all(suje,:))) '_2']);
    cd (sub_path2)
    rs_tp2 = spm_select('FPList', fullfile(sub_path2, 'rs'), '^ra.*\.nii$');
    matrix2=load(fullfile(sub_path2,'rs', 'reorient.mat'));
    if suje~=25 && suje~=28 && suje~=29
        sub_path3=fullfile(data_path, (all(suje,:)), [(all(suje,:)) '_3']);
        cd (sub_path3)
        rs_tp3 = spm_select('FPList', fullfile(sub_path3, 'rs'), '^ra.*\.nii$');
        matrix3=load(fullfile(sub_path3,'rs', 'reorient.mat'));
    end
    clear matlabbatch
    % Reorient images to AC
    for rs2=1:145
        matlabbatch{1}.spm.util.reorient.srcfiles(rs2,1) = {rs_tp2(rs2,:)};
    end
    matlabbatch{1}.spm.util.reorient.transform.transM =matrix2.M;
    matlabbatch{1}.spm.util.reorient.prefix = 'ro';
    if suje~=25 && suje~=28 && suje~=29
        for rs3=1:145
            matlabbatch{2}.spm.util.reorient.srcfiles(rs3,1) = {rs_tp3(rs3,:)};
        end
        matlabbatch{2}.spm.util.reorient.transform.transM =matrix3.M;
        matlabbatch{2}.spm.util.reorient.prefix = 'ro';
    end
    spm_jobman('run',matlabbatch)
end