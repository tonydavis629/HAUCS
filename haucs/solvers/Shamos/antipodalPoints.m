
function A = antipodalPoints(P)
    % Find an initial antipodal pair by locating the vertex opposite p1
    [n, ~] = size(P);
    i = 1;
    j = 2;
    A =[];

    while angleAP(P, n, j) < pi
        j = increment(j,n);
    end
    A = [A; i j];

    while j<=n
        %if (angleAP(P, i, j) <= angleAP(P, j, i))
        diff = pi-angleAP(P,i,j);
        if (diff>0)
            j = j+1;
        else
            if (diff<0)
                i = i+1;
            else
                if(i+1<j)
                    A = [A;increment(i,n) j];
                end
                if(j+1<=n)
                    A = [A;i increment(j,n)];
                end                
                i = i+1;
                j = j+1;
            end
        end
        if(j<=n && i<j)
            A = [A; i j];
        end
    end
end

function i_next = increment(i,n)
    i_next = mod(i,n)+1;
end

