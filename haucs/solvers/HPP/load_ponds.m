% load manually input ponds for live testing. Must be normalized first.
ponds = load("C:\Users\anthonydavis2020\Documents\github\HAUCS\haucs\ILnormcoords.txt");
ponds = ponds(2:end,:);
depot = ponds(1,:);
dist_mat = pdist2(ponds,ponds);
spacing = min(squareform(dist_mat)); %.65; % find minimum spacing between ponds
vert_pts = convhull(ponds);
% plot(ponds(vert_pts,1),ponds(vert_pts,2))
vertices = ponds(vert_pts,:);
