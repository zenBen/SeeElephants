function batch = CONN_vvResults(batch, varargin)
%% CONN_VV_RESULTS 2nd level voxel-to-voxel
% 
%--------------------------------------------------------------------------


%% Initialise defaults
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('batch', @isstruct)

p.addParameter('save', true, @islogical)

% Level 2 v2v params


p.parse(batch, varargin{:});
Arg = p.Results;


%% Create batch fields for level 2 v2v analysis



%% Add other top-level fields of batch.Results based on unmatched parameters
Unmatch_names = fieldnames(p.Unmatched);
for i = 1:numel(Unmatch_names)
    batch.vvResults.(Unmatch_names{i}) = p.Unmatched.(Unmatch_names{i});
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