% Offline checks; run from repository root.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);
addpath(fullfile(root,'Functions'));
for k=1:20
    start=[k/10 0 -k/4]; finish=[k 2 k/2]; plane=[0 1 0]; normal=[0 1 0];
    actual=corner_vision(start,finish,plane,normal);
    expected=ray_plane_intersect_y(start,finish,plane,normal);
    assert(isequaln(actual,expected));
    assert(norm(actual-(start+0.5*(finish-start)))<1e-12);
end
fixtures=dir(fullfile(root,'Data','**','*.mat'));
assert(~isempty(fixtures));
for k=1:numel(fixtures)
    entries=whos('-file',fullfile(fixtures(k).folder,fixtures(k).name));
    assert(~isempty(entries));
end
fprintf('PASS CornerVision: 20 ray intersections; %d MAT fixture headers readable\n',numel(fixtures));
