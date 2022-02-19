

% Line pass through pi and pa
% pa means p adjacent to pi
function dist = distPoint2Line(Pi,Pa,Pj)
    xi = Pi(1);
    yi = Pi(2);
    
    xa = Pa(1);
    ya = Pa(2);
    
    xj = Pj(1);
    yj = Pj(2);
    
    dist = abs( (ya-yi)*xj -(xa-xi)*yj + xa*yi-xi*ya  )/ sqrt((ya-yi)*(ya-yi) + (xa-xi)*(xa-xi));
end