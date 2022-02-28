function angle = angleAP(P, i, j)
    [n, ~]= size(P);
    
    i_next = mod(i,n)+1; 
    y = P(i_next,2) - P(i,2);
    x = P(i_next,1) - P(i,1);
    alpha_i = atan2(y,x);
    
    
    j_next = mod(j,n)+1;
    y = P(j_next,2) - P(j,2);
    x = P(j_next,1) - P(j,1);
    alpha_j = atan2(y,x);

    angle = clockWiseDist(alpha_i, alpha_j);

end

% clock wise distance from a to b
function angle = clockWiseDist(a , b)
   if a<0
       if b<0
           if(a<b)
               angle = 2*pi + (a-b);
           else
               angle = a - b;
           end
       else
           a = 2*pi + a;
           angle = a-b;
       end
   else
       if b<0
           angle = a - b;
       else
           if(a<b)
               angle = 2*pi-(a-b);
           else
               angle = a-b;
           end
       end
   end
end