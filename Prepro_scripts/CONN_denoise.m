function batch = CONN_denoise(batch, varargin)
%% CONN_DENOISE
% 
% 
%--------------------------------------------------------------------------


%% Initialise defaults
p = inputParser;
p.addRequired('batch', @isstruct)

p.addParameter('save', true, @islogical)

% Preprocessing
p.addParameter('pp_confoundname'...
    , {'White', 'CSF', 'motion','outliers', 'rest'}, @iscellstr)
p.addParameter('pp_confounddim', {3,3,6,3,2}, @iscell)
p.addParameter('pp_confoundderiv', {0,0,1,0,0}, @iscell)
p.addParameter('pp_done', 1, @isscalar)
p.addParameter('pp_ovw', 'No', @ischar)

%band-pass filter (values in Hz)
p.addParameter('denoise_filt', [0.01, 0.1], @isnumeric)
p.addParameter('denoise_done', 1, @isscalar)

p.parse(batch, varargin{:});
Arg = p.Results;


%% Create batch fields for denoising
% Setup preprocessing
batch.Preprocessing.confounds.names = Arg.pp_confoundname;
batch.Preprocessing.confounds.dimensions = Arg.pp_confounddim;
batch.Preprocessing.confounds.deriv = Arg.pp_confoundderiv;
batch.Preprocessing.done = Arg.pp_done;
batch.Preprocessing.overwrite = Arg.pp_ovw;
% Setup denoising
batch.Denoising.filter = Arg.denoise_filt; %band-pass filter (values in Hz)
batch.Denoising.done = Arg.denoise_done;


%% Save batch if required
if Arg.save 
    if isfield(batch, 'filename')
        save(batch.filename, 'batch')
    else
        error 'No save location defined in batch structure'
    end
end

end
