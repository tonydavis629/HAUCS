% 
% for i=1:length(ponds)
% instance = ponds(i)
clf

ponds_scl = squeeze(ponds(1,:,:)) .* 1000; %scale the pond locations from 0-1 to 0-1000
vrtscl = vertices{1} .* 1000;
depotscl = depot(1) * 1000;

M = vrtscl;
Mshifted = circshift(M,-1);

x_start=-1;
y_start=0;
x_end=-1;
y_end=0;

dx=spacing(1)*1000;
transl_spd = 10;
rot_spd = pi/4;

% x_start = depot(i,1);
% y_start = depot(i,2);
% x_end = x_start;
% y_end = y_start;

p.x=(M(:,1))';
p.y=(M(:,2))';

num_drones = 3;

p_groups = group_nodes(ponds_scl,num_drones);
plot_poly(ponds_scl,vrtscl)
% plot([p.x p.x(1)],[p.y p.y(1)],'b-');

%%
hold on
% hold off
daspect([1 1 1]);
figure(1)

for i=1:1:size(p_groups,2)
    if not(isempty(p_groups{i}))
        plot([p_groups{i}.x],[p_groups{i}.y],'bo-');
               
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
        
        time = toc;
        
        axis equal;
        line([M(:,1)';Mshifted(:,1)'],[M(:,2)';Mshifted(:,2)'],'Color','k');
        title('Coverage path plan');
        xlabel('East (x)');
        ylabel('North (y)');
        hold on;
        k = best_antipodal_pair;
        scatter( M(A(i,1),1), M(A(i,1),2), sz, c(i), 'filled' );
        scatter( M(A(i,2),1), M(A(i,2),2), sz, c(i), 'filled' );
        
        plot(optimal_path(:,1), optimal_path(:,2), '-o');
        scatter(x_start, y_start, 25, 'filled');
        scatter(x_end, y_end, 25, 'filled');
        txt1 = ['cost = ', num2str(min_cost)];
        text(x_start,y_start,txt1);
        hold off;


    end
hold on

end
% hold off
daspect([1 1 1]);



    
