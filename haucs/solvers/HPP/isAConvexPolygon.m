

function isConvex = isAConvexPolygon(M)
    [m, ~] = size(M);
    sum = 0;
    isConvex = true;
    
    for i = 1:m
        j = mod(i,m)+1;
        angle_i = pi - angleAP(M, i, j);
        
        if angle_i > pi || angle_i < 0
            isConvex = false;
            
        end
    end
end
