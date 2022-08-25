% load manually input ponds for live testing. Must be normalized first.
ponds = load("C:\\Users\\anthonydavis2020\\Documents\\github\\HAUCS\\haucs\\ILnormcoords.txt");
ponds = ponds(2:end,:);
depot = ponds(1,:);
dist_mat = pdist2(ponds,ponds);
spacing = 2*min(squareform(dist_mat)); %.65; % find minimum spacing between ponds
vert_pts = convhull(ponds);
% plot(ponds(vert_pts,1),ponds(vert_pts,2))
vertices = ponds(vert_pts,:);


tic

num_drones = 3;
makeplot = true;

total_cost_all=zeros(size(ponds,1),1);
max_path_cost_all = zeros(size(ponds,1),1);
all_vehroute = cell(size(ponds,1),1);


  
ponds_scl = ponds .* 1000; %scale the pond locations from 0-1 to 0-1000
vrtscl = vertices .* 1000;
depotscl = depot .* 1000;

M = vrtscl;
Mshifted = circshift(M,-1);

% x_start=-1;
% y_start=0;
% x_end=-1;
% y_end=0;

dx=spacing*1000;
transl_spd = 10;
rot_spd = pi/4;

x_start = depot(1)*1000;
y_start = depot(2)*1000;
x_end = x_start;
y_end = y_start;

p.x=(M(:,1))';
p.y=(M(:,2))';

if makeplot == true
    clf
    plot_poly(ponds_scl,vrtscl)
    hold on
    daspect([1 1 1]);
    figure(1)
end

p_groups = group_nodes(ponds_scl,num_drones);

% plot([p.x p.x(1)],[p.y p.y(1)],'b-');

%%

% hold off

nodeidx_list = cell(num_drones,1);
paths_list = cell(num_drones,1);

for i=1:1:size(p_groups,2)
    if makeplot == true
        plot([p_groups{i}.x],[p_groups{i}.y],'bo-');
    end
           
    M = [p_groups{i}.x, p_groups{i}.y];
    Mshifted = circshift(M,-1);
    tic;
    % Compute Antipodal pairs
    A = antipodalPoints(M);
    [m, ~] = size(A);
    sz = 25; c = linspace(1,10,m); 
    
    min_cost = Inf;
    optimal_path = [];
    best_antipodal_pair = 0;
    Cost = zeros(m,1);
    for k=1:m 
        Path = bestPathForAntipodalPair(M, A(k,:), dx);
        
        %check if the path should be inverted
        FullPath1 = [x_start y_start; Path;  x_end y_end];
        FullPath2 = [x_start y_start; flipud(Path); x_end y_end];
        
        cost1 = timeCost2D(FullPath1, transl_spd, rot_spd, [x_start y_start 0]);
        
        cost2 =  timeCost2D(FullPath2, transl_spd, rot_spd, [x_start y_start 0]);
        
        if (cost1 < cost2)
            FullPath = FullPath1;
            Cost(k) = cost1;
        else
            FullPath = FullPath2;
            Cost(k) = cost2;
        end
    
        if Cost(k)<min_cost
            min_cost = Cost(k);
            optimal_path = FullPath;
            best_antipodal_pair = k;
        end 
    end

    
    k = best_antipodal_pair;
    
    if makeplot == true
        axis equal;
        line([M(:,1)';Mshifted(:,1)'],[M(:,2)';Mshifted(:,2)'],'Color','k');
        title('Coverage path plan');
        xlabel('North (y)');
        ylabel('East (x)');
        hold on;
        
%             scatter( M(A(i,1),1), M(A(i,1),2), sz, c(i), 'filled' );
%             scatter( M(A(i,2),1), M(A(i,2),2), sz, c(i), 'filled' );
        
        plot(optimal_path(2:end-1,1), optimal_path(2:end-1,2), '-o');
        scatter(x_start, y_start, 25, 'filled');
        scatter(x_end, y_end, 25, 'filled');
    %     txt1 = ['cost = ', num2str(min_cost)];
    %     text(x_start,y_start,txt1);
%         hold off;
    end

    optimal_pathc = optimal_path(2:end-1,:);%do not include depot start and end
    nodeidx = inpolygon(ponds_scl(:,1),ponds_scl(:,2),p_groups{i}.x,p_groups{i}.y);
    nodegroup = ponds_scl(nodeidx,:);

    path = find_nodepath(optimal_pathc,nodegroup,dx);
    [~,nodeidx]=ismember(path,ponds_scl,'rows');
    nodeidx_list{i} = nodeidx; %match idx
    path = [depotscl; path; depotscl];
    paths_list{i} = path; 
%       
    
    

end

total_cost = 0;
max_path_cost = 0;
vehroute = [];
for i=1:length(paths_list)
    if i ~= length(paths_list)
        vehroute = [vehroute; 0; nodeidx_list{i}];
    elseif i == length(paths_list)
        vehroute = [vehroute; 0; nodeidx_list{i}; 0;];
    end
    path_cost = 0;
    for j=1:(length(paths_list{i})-1)
        fir=paths_list{i}(j,:);
        sec=paths_list{i}(j+1,:);
        dist = pdist2(fir,sec);
        path_cost = path_cost + dist;
    end
    total_cost = total_cost + path_cost;
    if path_cost > max_path_cost
        max_path_cost = path_cost;
    end
end

all_vehroute = vehroute.';
total_cost_all=total_cost;
max_path_cost_all = max_path_cost;


time = toc;
avg_total_cost = mean(total_cost_all);
avg_max_path = mean(max_path_cost_all);

fprintf('avg_total_cost = %f\n',avg_total_cost)
fprintf('avg_max_path = %f\n',avg_max_path)
fprintf('time = %f\n',time)

% routes = cell2mat(all_vehroute);
mat2np(all_vehroute,'C:\\Users\\anthonydavis2020\\Documents\\github\\HAUCS\\haucs\\HPProutes.pkl','int8')


