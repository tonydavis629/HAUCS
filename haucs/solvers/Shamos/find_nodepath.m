% for path in optimal_paths
    % for step in n
    %   pond <- compare dsearchn step and ponds 
function pathplan = find_nodepath(path,nodes,dx)
%paths_list is a cell array of optimal paths
%nodes is the pond locations
%path is a cell array of ordered nodes to visit
    
%     for i=1:length(paths_list)
%         nodelist=zeros(length(paths_list{i}));
%         idxlist=zeros(length(paths_list{i}));
%         k = 0;
%         for j=1:length(paths_list{i})
%             pathpt = paths_list{i}(j,:);
%             idx = knnsearch(nodes,pathpt);
%             if ~any(idxlist(:) == idx)
%                 nodelist(k) = nodes(idx,:);
%                 idxlist(k) = idx;
%                 k = k + 1;
%             end
%         end
%         path{i} = nodelist;
%     end

%     search_dst = dx;
%     while ~isempty(nodes) %while nodes are still unassigned
%         for i=1:length(paths_list) % for each set of paths
%             nodelist=zeros(length(paths_list{i}));
%             k = 0;
%             for j=1:length(paths_list{i})
%                 pathpt = paths_list{i}(j,:);
%                 idx = knnsearch(nodes,pathpt);
%                 if ~any(idxlist(:) == idx)
%                     nodelist(k) = nodes(idx,:);
%                     idxlist(k) = idx;
%                     k = k + 1;
%                 end
%             end
%             path{i} = nodelist;
%         end
%         search_dist = search_dist + dx;
%     end

% calculate dist from all lines to all nodes
% assign node to path with smallest dist

% 
%     for j=1:length(path)-1
%         v1 = path(j);
%         v2 = path(j+1);
%         dist_mat{j} = point_to_line(nodes, v1, v2);
%     end
%     while ~isempty(nodes)
%         % step through each leg
%         % assign those below threshold to that leg
%         nodes(idx)=[];
%     end
%     figure
%     hold on
%     plot(nodes(:,1),nodes(:,2),'o')

    vx = zeros(4,2);
    assigned = zeros(size(nodes,1),1);
    node_leg = cell(1,length(path)-1);
    for j=1:length(path)-1 % for j leg in path
        v1 = path(j,:);
        v2 = path(j+1,:);
%         plot([v1(1),v2(1)],[v1(2),v2(2)],'r.')
        dir = (v2-v1)/norm(v2-v1);%find the direction of the line
        if isnan(dir)
            continue
        end

        [th,~]=cart2pol(dir(1),dir(2));
        [tlx,tly] = pol2cart(2*pi/3+th,dx);
        tl = [tlx,tly];
        [blx,bly] = pol2cart(4*pi/3+th,dx);
        bl = [blx,bly];
        [toprx,topry] = pol2cart(pi/3+th,dx);
        tr = [toprx,topry];
        [brx,bry] = pol2cart(-pi/3+th,dx);
        br = [brx,bry];

        vx(1,:) = tl + v1; %define a rectangle width dx around the leg of the path
        vx(2,:) = bl  + v1;
        vx(3,:) = br + v2; 
        vx(4,:) = tr + v2;
%         vx = convhull(vx);
%         plot(vx(:,1),vx(:,2),'g*')

        in_path = inpolygon(nodes(:,1),nodes(:,2),vx(:,1),vx(:,2));
        in_unass = in_path & ~assigned; %nodes in path and unassigned
        n_in_path = nodes(in_unass,:); 

        if th<0
            th = th + 2*pi;
        end
        if 7*pi/4 <= th || th < pi/4
            %order lowest x to highest x
            ordered=sortrows(n_in_path);
        elseif pi/4 <= th && th < 3*pi/4
            %order lowest y to highest y
            ordered=sortrows(n_in_path,2);
        elseif 3*pi/4 <= th && th < 5*pi/4
            %order highest x to lowset x
            ordered=sortrows(n_in_path,1,'descend');
        elseif 5*pi/4 <= th && th < 7*pi/4
            %order highest y to lowest y
            ordered=sortrows(n_in_path,2, 'descend');
        end
        node_leg{j} = ordered;
        assigned(in_path==1)=1;
    end
    if ~all(assigned)
        node_leg{j+1} = nodes(assigned==0,:); % if any nodes were not assigned, assign to the end.
    end
    node_leg=node_leg(~cellfun('isempty',node_leg)); %remove empty cells
    pathplan = cat(1, node_leg{:});

end