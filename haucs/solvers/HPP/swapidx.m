function newidx = swapidx(C,nodes,idx,i)
    %Input
    %Clusters
    %nodes
    % group i
    %Idx
    %Output
    %Idx with more even distribution

    newidx = idx(:,:);
    %find dist from small C to all points
    %take closest point not already in C
    dist_mat = pdist2(C,nodes);
    dist_mat(:,idx==i)=inf;
    %find idx of min
    [~,pond]=find(dist_mat==min(min(dist_mat)));
    newidx(pond)=i;
    %idx(1) is new cluster idx(2) is the idx number
end