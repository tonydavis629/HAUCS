
% Best path for antipodal pairs
% A: antipodal pairs
% V: vertices of the polygon


function [Path, inclination] = bestPathForAntipodalPair(V, A, dx) 
    [n,~] = size(V);

    i = A(1,1);
    j = A(1,2);

    %if angleAP(V, i,j) < angleAP(V, j, i)
    if (angleAP(V,i,j) - pi) < 0
        b1 = j;
        a1 = i;
    else
        b1 = i;
        a1 = j;
    end

    phi = angleAP(V, b1, a1)-pi;
    gamma_b = angleAP(V, decrement(b1,n), b1);
    gamma_a = angleAP(V, decrement(a1,n), a1) - phi;
    if gamma_b < gamma_a 
        b2 = decrement(b1,n);
        a2 = a1;
    else
        b2 = decrement(a1,n);
        a2 = b1;
    end
    
    d1 = distPoint2Line(V(b1,:),V(increment(b1,n),:),V(a1,:));
    d2 = distPoint2Line(V(b2,:),V(increment(b2,n),:),V(a2,:));
    
    if d1 < d2
        b_vertex = b1;
        c_vertex = increment(b1,n);
        inclination = slopeAngle(V(b_vertex,:),V(c_vertex,:));       
             
        Pstart = V;
        Pend = circshift(V, -1);

        theta = pi/2 - inclination; % R rotation is with respect of the east; alpha rotation is with respect of the north
        
        PsR = rotatePolygon(Pstart, theta);
        PsR = PsR';
        PeR = rotatePolygon(Pend, theta);
        PeR = PeR';



        [PathRotated] = getPathMR([PsR PeR], dx, 1);

        Path = rotatePolygon(PathRotated, -theta);
        Path = Path';
    else
        b_vertex = increment(b2,n);
        c_vertex = b2;
        inclination = slopeAngle(V(b_vertex,:),V(c_vertex,:));
%        inclination * 180 / pi
%        R(k) = inclination;

        Pstart = V;
        Pend = circshift(V, -1);


        theta = -pi/2 - inclination; % R rotation is with respect of the east; alpha rotation is with respect of the north
        PsR = rotatePolygon(Pstart, theta);
        PsR = PsR';
        PeR = rotatePolygon(Pend, theta);
        PeR = PeR';

        [PathRotated] = getPathMR([PsR PeR], dx, -1);
%         plot(PathRotated(:,1), PathRotated(:,2));
%         hold off;
%         pause;
        Path = rotatePolygon(PathRotated, -theta);
        Path = Path';
    end
end

function i_next = increment(i,n)
    i_next = mod(i,n)+1;
end

function i_prev = decrement(i,n)
    i_prev = i-1;
    if i_prev <1
        i_prev = n;
    end
end

function alpha = slopeAngle(p1, p2)
    alpha = atan2(p2(2)-p1(2),p2(1)-p1(1));
end
