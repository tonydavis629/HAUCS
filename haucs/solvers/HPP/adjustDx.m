% Compute distance between 2 rows

function [dx_opt] = adjustDx(dx, h)
nl = ceil(h/dx);
dx_opt = h/nl;
end