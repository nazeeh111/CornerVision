function varargout = corner_vision(varargin)
% CornerVision: Recover the scene around a corner.
% Passes arguments and outputs directly to ray_plane_intersect_y.
root = fileparts(mfilename('fullpath'));
previousPath = path;
cleanup = onCleanup(@() path(previousPath)); %#ok<NASGU>
addpath(root);
addpath(fullfile(root, 'Functions'));
[varargout{1:nargout}] = ray_plane_intersect_y(varargin{:});
end
