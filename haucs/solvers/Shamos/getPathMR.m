

function [Path] = getPathMR(M, dx, dir)
% Returns a path for a given CONVEX polygon 
% Generate lines
gap_y = 0;

% polygon limits
l_limit = min(M(:,1));
r_limit = max(M(:,1));
down_limit = min(M(:,2));
up_limit = max(M(:,2));

% extend the lines beyond the polygon
y1 = down_limit - gap_y;
y2 = up_limit + gap_y;

% x1 = l_limit + dx/2;
x1 = l_limit;
x2 = x1;

%dir = 1;


  
%%

i = 1; 
lines = 0;

enterWP = [0 0];
exitWP = [0 0];
lastWP = [0 0];

% while(x1 < (r_limit + dx/2)) 
while(x1 < (r_limit)) 
   
    LineXY = [x1 y1 x2 y2];
    lines = lines +1;
    
    
    out = lineSegmentIntersect(M,LineXY);
    intersections = [out.intMatrixX(:) out.intMatrixY(:)];
    intersections( ~any(intersections,2), : ) = [];  
    n = size(intersections,1);  
    
   
    if (n == 1)
        p1 = intersections(1,:);
        Path(i,:) = p1;
        lastWP = p1;
        i = i + 1;
    end
    
  
    if (n > 1)
        
        if(n>2)
           [B, kkk] = sort(intersections(:,2)); 
           ordered = [intersections(kkk) B];
           p1 = ordered(1,:);
           p2 = ordered(n,:);
        else
            p1 = intersections(1,:);
            p2 = intersections(2,:);
        end
            
      
        if (dir == 1) 
            
            
            if (p2(1,2)<p1(1,2))
                enterWP = p2; 
                exitWP = p1;
            else
                enterWP = p1;
                exitWP = p2;
            end
            
           
            if(lines > 1)
                dif = enterWP(1,2) - lastWP(1,2);
                if(dif < 0) 
                    intermediateWP = [lastWP(1,1) enterWP(1,2)];
                    Path(i-1,:) = intermediateWP;
                else
                   
                    intermediateWP = [enterWP(1,1) lastWP(1,2)];
                    enterWP = intermediateWP;
                end
            end
            
           
            Path(i,:) = enterWP;
            i = i+1;
            Path(i,:) = exitWP;
            i = i+1;
            
        else 
           
           if (p2(1,2)<p1(1,2)) 
               enterWP = p1;
               exitWP = p2;
           else
               enterWP = p2;
               exitWP = p1;
           end
           
           if(lines > 1)
            
                dif = enterWP(1,2) - lastWP(1,2);
                if(dif > 0) 
                  
                    intermediateWP = [lastWP(1,1) enterWP(1,2)];
                    Path(i-1,:) = intermediateWP;
                else
                    
                    intermediateWP = [enterWP(1,1) lastWP(1,2)];
                    enterWP = intermediateWP;      
                end
            end
            Path(i,:) = enterWP;
            i = i+1;
            Path(i,:) = exitWP;
            i = i+1;

        end
        
        dir = dir * -1;
        lastWP = exitWP;
    end
    
  
    if (n==0)
        
        LineFOV = [x1-dx/2 y1 x2-dx/2 y2];
       
        out = lineSegmentIntersect(M, LineFOV);
        intersections = [out.intMatrixX(:) out.intMatrixY(:)];
        intersections( ~any(intersections,2), : ) = [];  
        n = size(intersections,1);
      
        if(n > 1)
            
            if(n>2)
               [B, kkk] = sort(intersections(:,2)); 
               ordered = [intersections(kkk) B];
               p1 = ordered(1,:);
               p2 = ordered(n,:);
            else
                p1 = intersections(1,:);
                p2 = intersections(2,:);
            end

         
            p1(1,1) = p1(1,1) + dx/2;
            p2(1,1) = p2(1,1) + dx/2;

           
            if (dir == 1) 

               
                if (p2(1,2)<p1(1,2))
                    enterWP = p2;
                    exitWP = p1; 
                else
                    enterWP = p1;
                    exitWP = p2;
                end

                
                if(lines > 1)
                    dif = enterWP(1,2) - lastWP(1,2);
                    if(dif < 0) 
                       
                        intermediateWP = [lastWP(1,1) enterWP(1,2)];
                        Path(i-1,:) = intermediateWP;
                    else
                       
                        intermediateWP = [enterWP(1,1) lastWP(1,2)];
                        enterWP = intermediateWP;
                    end
                end

               
                Path(i,:) = enterWP;
                i = i+1;
                Path(i,:) = exitWP;
                i = i+1;

            else 
             
               if (p2(1,2)<p1(1,2)) 
                   enterWP = p1;
                   exitWP = p2;
               else
                   enterWP = p2;
                   exitWP = p1;
               end

               if(lines > 1)
                  
                    dif = enterWP(1,2) - lastWP(1,2);
                    if(dif > 0) 
                      
                        intermediateWP = [lastWP(1,1) enterWP(1,2)];
                        Path(i-1,:) = intermediateWP;
                    else
                      
                        intermediateWP = [enterWP(1,1) lastWP(1,2)];
                        enterWP = intermediateWP;      
                    end
                end
                Path(i,:) = enterWP;
                i = i+1;
                Path(i,:) = exitWP;
                i = i+1;

            end

            dir = dir * -1;
            lastWP = exitWP;
        end
    end
    
   
    x1 = x1 + dx;
    x2 = x1;
end


end