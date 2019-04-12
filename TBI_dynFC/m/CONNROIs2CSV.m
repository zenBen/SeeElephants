% cd '/media/ben/CBRU_NMM/TBI/CONN/Pre_post/conn_TBI_N25_2sessions/results/preprocessing/';
% cd /home/local/bcowley/Benslab/project_TBI
ind = './data/data';
fs = dir(fullfile(ind, 'ROI*0.mat'));
oud = './SeeElephants/TBI_dynFC/data';
% rois = [169, 12, 184, 185; ...
%         177, 56, 186, 187];
name_rois = {'RIFG_10' 'atlas.IFG tri r' 'HipL_6' 'NAccR_6';
        'CingAntR_6' 'atlas.PaCiG r' 'STGL_6' 'TPR_6'};

%%
for i = 1:numel(fs)

    roi = load(fullfile(fs(i).folder, fs(i).name));
    
    roi1_rifg = roi.data{contains(roi.names, name_rois{1, 1})};
    roi1_atlrifg = roi.data{startsWith(roi.names, name_rois{1, 2})};
    roi2_lhpc = roi.data{contains(roi.names, name_rois{1, 3})};
    roi2_rnac = roi.data{contains(roi.names, name_rois{1, 4})};
    
    roi1_racc = roi.data{contains(roi.names, name_rois{2, 1})};
    roi1_atlrpcg = roi.data{startsWith(roi.names, name_rois{2, 2})};
    roi2_lstg = roi.data{contains(roi.names, name_rois{2, 3})};
    roi2_rtpo = roi.data{contains(roi.names, name_rois{2, 4})};
    
    T = table(roi1_rifg...
            , roi1_atlrifg...
            , roi2_lhpc...
            , roi2_rnac...
            , roi1_racc...
            , roi1_atlrpcg...
            , roi2_lstg...
            , roi2_rtpo);
    [~, f, ~] = fileparts(fs(i).name);
    writetable(T, fullfile(oud, [f '_mock.csv']));
    clear roi*
end
clear