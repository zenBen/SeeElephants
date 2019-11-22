function batch = CONN_QA(batch, varargin)
%% CONN_QA 
% 
%--------------------------------------------------------------------------


%% Initialise defaults
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('batch', @isstruct)

p.addParameter('save', true, @islogical)

% Quality Assurance params


p.parse(batch, varargin{:});
Arg = p.Results;


%% Create batch fields for quality assurance



%% Add other top-level fields of batch.QA based on unmatched parameters
Unmatch_names = fieldnames(p.Unmatched);
for i = 1:numel(Unmatch_names)
    batch.QA.(Unmatch_names{i}) = p.Unmatched.(Unmatch_names{i});
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