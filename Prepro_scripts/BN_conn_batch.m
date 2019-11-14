function BN_conn_batch(names, outdir, varargin)
%BN_CONN_BATCH batch preprocessing for multi-subject single-session data
%
% Description: 
%
% Syntax:
%   BN_conn_batch(names, outdir, varargin)
%
% Input:
%   'names'     struct array, subject-wise data folders in Matlab struct
%                   OR
%               string, path to data files but no filtering supported
%                   OR
%               cell string array, many paths to data (with no filtering)
% 
%   'outdir'    Directory to write processed files
%
% varargin:
%   'connfname' string, name of the conn output file,
%               default = "conn_batch_DDMMYYYYHHMMSS"
% 
%   'do_batch'  logical, run conn_batch() on batch struct, default = true
%   'prompt'    logical, prompt for path to data files, default = false
%   'GUI'       logical, call the CONN GUI after batch, default = false
% 
%   setup       scalar struct, arguments for CONN_setup in struct form
%   denoise     scalar struct, arguments for CONN_denoise in struct form
%   level1      scalar struct, arguments for CONN_level1 in struct form
%
% Output:
%   none
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


%% Initialise -----------------------------------
p = inputParser;

% Define project location, subjects, and name
p.addRequired('names', @(x) isstruct(x) || ischar(x) || iscellstr(x))
p.addRequired('outdir', @ischar)

p.addParameter('connfname'...
    , fullfile(outdir, ['conn_batch_' datestr(now, 30) '.mat']), @ischar)

p.addParameter('do_batch', true, @islogical)
p.addParameter('prompt', false, @islogical)
p.addParameter('GUI', false, @islogical)

p.addParameter('setup', struct(), @isstruct)
p.addParameter('denoise', struct(), @isstruct)
p.addParameter('level1', struct(), @isstruct)

p.parse(names, outdir, varargin{:})
Arg = p.Results;


%% Check if names = files, or path to read from given directory?
if Arg.prompt && isempty(names)
    names = inputdlg('Absolute or relative path to data:', 'Data Path', 1);
end
if ischar(names) || iscellstr(names) %#ok<*ISCLSTR>
    names = build_fileset(names);
end


%% PREPARE & CONDUCT connectivity analyses
batch = CONN_setup(names, Arg.connfname, Arg.setup); % CONN Setup

if ~isempty(fieldnames(Arg.denoise))
    batch = CONN_denoise(batch, Arg.denoise); % CONN Denoising
end

if ~isempty(fieldnames(Arg.level1))
    batch = CONN_level1(batch, Arg.level1); % CONN Analysis (1st-Level)
end


%% CALL THE CONN BATCH ->
if Arg.do_batch
    conn_batch(batch);
end


%% CONN GUI IF REQUESTED
if Arg.GUI
    conn('load', batch.filename)
    conn gui_results
end

end % BN_conn_batch
