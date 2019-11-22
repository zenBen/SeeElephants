function batch = CONN_Results(batch, varargin)
%% CONN_LEVEL2 
% 
%--------------------------------------------------------------------------


%% Initialise defaults
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('batch', @isstruct)

p.addParameter('save', true, @islogical)

% Level 2 params


p.parse(batch, varargin{:});
Arg = p.Results;


%% Create batch fields for level 2 analysis



%% Add other top-level fields of batch.Results based on unmatched parameters
Unmatch_names = fieldnames(p.Unmatched);
for i = 1:numel(Unmatch_names)
    batch.Results.(Unmatch_names{i}) = p.Unmatched.(Unmatch_names{i});
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