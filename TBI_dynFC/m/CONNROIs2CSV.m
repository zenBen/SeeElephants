% cd '/media/ben/CBRU_NMM/TBI/CONN/Pre_post/conn_TBI_N25_2sessions/results/preprocessing/';
% cd /home/local/bcowley/Benslab/project_TBI
ind = './data/data';
fs = dir(fullfile(ind, 'ROI*0.mat'));
oud = './SeeElephants/TBI_dynFC/data';
% rois = [169, 104, 107; ...
%         177, 21, 18];
name_rois = {'RIFG_10' 'HipL_6' 'NAccR_6';
        'CingAntR_6' 'STGL_6' 'TPR_6'};

%%
for i = 1:numel(fs)

    roi = load(fullfile(fs(i).folder, fs(i).name));
    
    roi1_rifg = roi.data{contains(roi.names, name_rois{1, 1})};
    roi2_lhpc = roi.data{contains(roi.names, name_rois{1, 2})};
    roi2_rnac = roi.data{contains(roi.names, name_rois{1, 3})};
    
    roi1_racc = roi.data{contains(roi.names, name_rois{2, 1})};
    roi2_lstg = roi.data{contains(roi.names, name_rois{2, 2})};
    roi2_rtpo = roi.data{contains(roi.names, name_rois{2, 3})};
    
    T = table(roi1_rifg...
            , roi2_lhpc...
            , roi2_rnac...
            , roi1_racc...
            , roi2_lstg...
            , roi2_rtpo);
    [~, f, ~] = fileparts(fs(i).name);
    writetable(T, fullfile(oud, [f '_mock.csv']));
    clear roi*
end