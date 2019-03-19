% function batch = CONN_DENOISE(batch)
%% CONN Denoising
batch.Preprocessing.confounds.names =...
    {'White', 'CSF', 'motion','outliers', 'rest'};
batch.Preprocessing.confounds.dimensions = {3,3,6,3,2};
batch.Preprocessing.confounds.deriv = {0,0,1,0,0};
batch.Preprocessing.done = 1;
batch.Preprocessing.overwrite = 'No';
batch.Denoising.filter = [0.01, 0.1]; %band-pass filter (values in Hz)
batch.Denoising.done = 1;