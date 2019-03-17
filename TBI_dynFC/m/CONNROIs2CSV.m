ind = '/media/ben/CBRU_NMM/TBI/CONN/Pre_post/conn_TBI_N25_2sessions/results/preprocessing/';
fs = dir(fullfile(ind, 'ROI*0.mat'));
oud = '/home/ben/Benslab/project_TBI/SeeElephants/TBI_dynFC';
rois = [169, 104, 107; ...
        177, 21, 18];

for i = 1:numel(fs)

    roi = load(fullfile(fs(i).folder, fs(i).name));
    
    roi1_rifg = roi.data{169};
    roi2_lhpc = roi.data{104};
    roi2_rnac = roi.data{107};
    
    roi1_racc = roi.data{177};
    roi2_lstg = roi.data{21};
    roi2_rtpo = roi.data{18};
    
    T = table(roi1_rifg, roi2_lhpc, roi2_rnac, roi1_racc, roi2_lstg, roi2_rtpo);
    [~, f, ~] = fileparts(fs(i).name);
    writetable(T, fullfile(oud, [f '_mock.csv']));
end