function batch = CONN_dynAnalysis(batch, varargin)
%% CONN_DYN_ANALYSIS 1st level dynamic connectivity analysis batch spec
% 
%--------------------------------------------------------------------------


%% Initialise defaults
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('batch', @isstruct)

p.addParameter('save', true, @islogical)


p.parse(batch, varargin{:});
Arg = p.Results;


%% Create batch fields for level 1 dynamic connectivity analysis


%% Add other top-level fields of batch.dynAnalysis based on unmatched parameters
Unmatch_names = fieldnames(p.Unmatched);
for i = 1:numel(Unmatch_names)
    batch.dynAnalysis.(Unmatch_names{i}) = p.Unmatched.(Unmatch_names{i});
end


%% Save batch if required
if Arg.save 
    if isfield(batch, 'filename')
        save(batch.filename, 'batch')
    else
        error 'No save location defined in batch structure'
    end
end

end