tic

num_drones = 5;
makeplot = false;

total_cost_all=zeros(size(ponds,1),1);
max_path_cost_all = zeros(size(ponds,1),1);

for iter=1:size(ponds,1)
%     disp(iter)
% for iter=23:1:23
      
    ponds_scl = squeeze(ponds(iter,:,:)) .* 1000; %scale the pond locations from 0-1 to 0-1000
    vrtscl = vertices{iter} .* 1000;
    depotscl = depot(iter,:) * 1000;
    
    M = vrtscl;
    Mshifted = circshift(M,-1);
    
    % x_start=-1;
    % y_start=0;
    % x_end=-1;
    % y_end=0;
    
    dx=spacing(iter)*1000;
    transl_spd = 10;
    rot_spd = pi/4;
    
    x_start = depot(iter,1)*1000;
    y_start = depot(iter,2)*1000;
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
            xlabel('East (x)');
            ylabel('North (y)');
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
        path = [depotscl; path; depotscl];
        paths_list{i} = path; 
        
        
    
    end
    
    total_cost = 0;
    max_path_cost = 0;
    for i=1:length(paths_list)
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
    
    total_cost_all(iter)=total_cost;
    max_path_cost_all(iter) = max_path_cost;

end

time = toc;
avg_total_cost = mean(total_cost_all);
avg_max_path = mean(max_path_cost_all);
avg_time = time / length(ponds);

fprintf('avg_total_cost = %f\n',avg_total_cost)
fprintf('avg_max_path = %f\n',avg_max_path)
fprintf('avg_time = %f\n',avg_time)



