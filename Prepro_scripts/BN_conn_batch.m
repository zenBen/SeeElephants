function batch = BN_conn_batch(names, outdir, varargin)
%BN_CONN_BATCH batch preprocessing for multi-subject single-session data
%
% Description: create a CONN batch struct and run it or open it in CONN GUI
%   CONN documents fields from the below list:
%    filename   conn_*.mat project file (defaults to currently open project)
%    subjects   Subset of subjects to run (defaults to all)
%    parallel   Parallelization options (defaults to local / no parallel)
%    Setup      Information/processes for experiment Setup and Preprocessing
%    Denoising  Information/processes regarding Denoising step
%    Analysis   Information/processes regarding first-level analyses
%    Results    Information/processes regarding second-level analyses/results
%    QA         Information/processes regarding Quality Assurance plots
%
% Syntax:
%   BN_conn_batch(names, outdir, varargin)
%
% Input:
%   names       struct array, subject-wise data folders in Matlab struct
%                   OR
%               string, path to data files but no filtering supported
%                   OR
%               cell string array, many paths to data (with no filtering)
% 
%   outdir      Directory to write processed files
%
% varargin:
%   filename    string, name of the conn output file,
%               default = "conn_batch_DDMMYYYYHHMMSS.mat"
% 
%   do_batch    logical, run conn_batch() on batch struct, default = true
%   prompt      logical, prompt for path to data files, default = false
%   GUI         logical, call the CONN GUI after batch, default = false
% 
%   Setup       scalar struct, arguments for CONN_setup in struct form
%               default = empty, CONN_setup is not called
%   Denoising   scalar struct, arguments for CONN_denoise in struct form
%               default = empty, CONN_denoise is not called
%   Analysis    scalar struct, arguments for CONN_level1 in struct form
%               default = empty, CONN_level1 is not called
%   Results     scalar struct, arguments for CONN_level2 in struct form
%               default = empty, CONN_level2 is not called
%   QA          scalar struct, arguments for CONN_qa in struct form
%               default = empty, CONN_qa is not called
%
% Output:
%   batch       struct, the structure for batching CONN analysis
%
% NOTE
%
% CALLS    build_fileset(), conn, conn_batch()
%
% REFERENCE:
%
% Version History:
%  13.06.2018 Created (Benjamin Cowley, Helsinki)
%  13.11.2019 version 2 (Benjamin Cowley, Helsinki)
%
% Copyright(c) 2019:
%  Benjamin Cowley (Ben.Cowley@helsinki.fi),
%  Noelia Martinez-Molina (noelia.martinezmolina@helsinki.fi)
%
% This code is released under the MIT License
% http://opensource.org/licenses/mit-license.php
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% TODO : DOES CONN WORK IF WE RUN SETUP, DENOISE, 1ST+2ND LVL IN ONE GO?
% TODO : SHOULD WE REQUIRE A FIXED BIDS-LIKE DIRECTORY ORGANISATION?
% TODO : CAN I DEFINE SEPARATE RESULTS FOLDERS FOR EACH RUN?
% TODO : HOW TO SPECIFY/DICTATE THE STORAGE OF ROIs?
% TODO : FIX DOCS OF PARAMS
% TODO : FIND REGEX PARAMS THAT CONSTRAIN TO MATCH START OF FILENAMES


%% Initialise -----------------------------------
p = inputParser;
p.KeepUnmatched = true;

% Define project location, subjects, and name
p.addRequired('names', @(x) isstruct(x) || ischar(x) || iscellstr(x))
p.addRequired('outdir', @ischar)

p.addParameter('filename', ['conn_batch_' datestr(now, 30) '.mat'], @ischar)

p.addParameter('do_batch', true, @islogical)
p.addParameter('prompt', false, @islogical)
p.addParameter('GUI', false, @islogical)

p.addParameter('Setup', struct(), @isstruct)
cnn_stgs = {'Denoising' 
            'Analysis' 
            'vvAnalysis' 
            'dynAnalysis'
            'Results' 
            'vvResults' 
            'QA'};
cellfun(@(x) p.addParameter(x, struct(), @isstruct), cnn_stgs)

p.parse(names, outdir, varargin{:})
Arg = p.Results;


%% Check if names = files, or path to read from given directory?
if Arg.prompt && isempty(names)
    names = inputdlg('Absolute or relative path to data:', 'Data Path', 1);
end
if ischar(names) || iscellstr(names) %#ok<*ISCLSTR>
    names = build_dataset(names);
end


%% Create batch
[~, batch.name, ~] = fileparts(Arg.filename);
batch.filename = fullfile(outdir, Arg.filename);
batch.gui = Arg.GUI;
% Add other top-level fields of batch based on unmatched parameters
Unmatch_names = fieldnames(p.Unmatched);
for i = 1:numel(Unmatch_names)
    batch.(Unmatch_names{i}) = p.Unmatched.(Unmatch_names{i});
end


%% PREPARE connectivity analyses
if ~isempty(fieldnames(Arg.Setup)) % CONN Setup
    batch = CONN_Setup(names, batch, Arg.Setup); 
end

for i = 1:numel(cnn_stgs)
    if ~isempty(fieldnames(Arg.(cnn_stgs{i})))
        CONN_stage_i = str2func(['CONN_' cnn_stgs{i}]);
        batch = CONN_stage_i(batch, Arg.(cnn_stgs{i})); % CONN stage i
    end

end


%% RUN CONN BATCH ->
if Arg.do_batch %switch on processing steps
    f = fieldnames(batch);
    idx = ismember(f, ['Setup'; cnn_stgs]);
    for i = find(idx), batch.(f{i}).done = 1; end
end
conn_batch(batch) %build and save CONN_x structure


%% CONN GUI IF REQUESTED
if Arg.GUI
    conn
    conn('load', batch.filename)
    conn gui_setup
end

end % BN_conn_batch
