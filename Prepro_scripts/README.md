# README

## DONE

BN_conn_batch.m provides a functionalised version of batched SPM preprocessing and 1st level CONN analysis. It allows subject filtering and provides a basis for flexibly calling various batch commands on this set of subjects. See function help for parameter details.

## TODO

### Plot the adjacency matrix from the output in conn.

Detailed explanation of outputs from conn in the forum:
https://www.nitrc.org/forum/message.php?msg_id=18633

Importantly, the results/preprocessing/ROI_Subject*_Condition*.mat file contains the denoised time series and the results/firstlevel/SBC_01/resultsROI_Subjectxxx_Conditionxxx.mat file contains the Z Fisher transformed correlation coefficients (from each source to each target).
