function p_groups=group_nodes(nodes,numdiv)
    %Input
    %nodes : node locations in [x,y] coordinates
    %numdiv : number of groups to divide the nodes into
    %Output
    %p_groups : cell array of polygon vertices which outline each group of nodes
    [idx,C] = kmeans(nodes,numdiv);
    %find length(nodes)/numdiv closest nodes to C
    pts_clus = ceil(length(nodes)/numdiv);
%     kidx = knnsearch(nodes,C,"K",pts_clus);
% %     dups = zeros(size(kidx));
%     for i=size(kidx,1):-1:1
%         for j=size(kidx,2):-1:1
%             dupcheck = kidx(i,j);
%             if dupcheck == any(kidx(:,:))
%                 kidx(i,j) = nan;
%             end
%         end
%     end
%     kidx_unq = unique(kidx,'stable');
%     [idx,C] = kmeans(nodes,numdiv, 'Options','UseParallel');
    nodecopy = nodes(:,:);
%     kidx = [];
%     for m=1:pts_clus
%         k = dsearchn(nodecopy,C);
%         kidx = [kidx, k];
%         nodecopy(k,:)=nan;
%     end

%     for i=size(kidx,1):-1:1
%         for j=size(kidx,2):-1:1
%             dupcheck = kidx(i,j);
%             if dupcheck == any(kidx(:,:))
%                 kidx(i,j) = nan;
%             end
%         end
%     end
    
    %clean up the left over nodes
%     while ~isempty(nodecopy)
%         D = pdist2(nodecopy,C);
%         [x,y]=find(D==min(min(D))); 
%         kidx{clus,node}
%         nodecopy(x,:)=[];
%     end
    idx = [];
    for i=1:size(nodes,1)
        D = pdist2(nodes(i,:),C);%find the distance between node and all clusters
        x = find(D==min(min(D)));%find the cluster with the minimum distance
        if sum(idx==x)<=pts_clus% if the cluster is not full
            idx = [idx, x];%assign the node to that cluster
        else
            assigned = false;
            while assigned == false
                D(x) = inf;
                x = find(D==min(min(D)));
                if sum(idx==x)<=pts_clus %doesn't check
                    idx = [idx,x];
                    assigned = true;
                end
            end
        end
        % if the cluster is full 
        % while node is not assigned
        % try next closest
        %if node is assigned, mark assigned
    end
%     nodeclus = nodeclus(~cellfun(@isempty,nodeclus));

    for i=1:length(C)
%         idx_filt = rmmissing(kidx(i,:))'; %remove the nan
%         group{i} = [nodes(idx_filt,1),nodes(idx_filt,2)];
        group{i} = [nodes(idx==i,1),nodes(idx==i,2)];
        k{i} = boundary(nodes(idx==i,1),nodes(idx==i,2),1);
        p_groups{i}.x = group{i}(k{i},1);
        p_groups{i}.y = group{i}(k{i},2);
    end

end
