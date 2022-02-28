% Modeling Wind using Rayleigh Distribution

load optimal_path_1.mat;
load optimal_path_2.mat;
load optimal_path_3.mat;
% assigning Optimal paths
X1=optimal_path_1;
X2=optimal_path_2;
X3=optimal_path_3;
 Lp = 0.5;  % Length of each part between two waypoints.

 % Define polygon
P1=[0 0;0 370;740 370; 740 0]; P1shifted=[0 370;740 370;740 0;0 0];
P2=[0 370;0 745;740 745;740 370]; P2shifted=[0 745;740 745;740 370;0 370];
P3=[740 0;740 370;740 745;1320 745]; P3shifted=[740 370;740 745;1320 745;740 0];

X1_start=-5; Y1_start=0; X1_end=740; Y1_end=370; Home_1=[740 370];
X2_start=0;Y2_start=746;X2_end=0;Y2_end=750;
X3_start=742;Y3_start=0;X3_end=1321;Y3_end=746;
 
  
  %Distance between waypoints in path
        D1=zeros(1000,2); xy1=zeros(102,2);      % UAV 1
        for i=1:17  
           p = X1(i,:);
           q = X1(i+1,:);
           dc1=sqrt(((q(1,1)-p(1,1))^2)+((q(1,2)-p(1,2))^2)); 
          n=5; %n=dc1/Lp; 
           t = linspace(0,1,n+1)';
           %xy= (1-t).*p + t.*q;
            for j=i
%                 xy(j:j+5,:)= (1-t).*p + t.*q;
%                 D1(j:j+5,:)=xy(j:j+5,:);
                if j==1
                    xy1(1:6,:)=(1-t).*p + t.*q;
                elseif j==2
                    xy1(7:12,:)=(1-t).*p + t.*q;
                elseif j==3
                    xy1(13:18,:)=(1-t).*p + t.*q;
                elseif j==4
                    xy1(19:24,:)=(1-t).*p + t.*q;
                elseif j==5
                    xy1(25:30,:)=(1-t).*p + t.*q;
                elseif j==6
                    xy1(31:36,:)=(1-t).*p + t.*q;
                elseif j==7
                    xy1(37:42,:)=(1-t).*p + t.*q;
                elseif j==8
                    xy1(43:48,:)=(1-t).*p + t.*q;
                elseif j==9
                    xy1(49:54,:)=(1-t).*p + t.*q;
                elseif j==10
                    xy1(55:60,:)=(1-t).*p + t.*q;
                elseif j==11
                    xy1(61:66,:)=(1-t).*p + t.*q;
                elseif j==12
                    xy1(67:72,:)=(1-t).*p + t.*q;
                elseif j==13
                    xy1(73:78,:)=(1-t).*p + t.*q;
                elseif j==14
                    xy1(79:84,:)=(1-t).*p + t.*q;
                elseif j==15
                    xy1(85:90,:)=(1-t).*p + t.*q; 
                elseif j==16
                    xy1(91:96,:)=(1-t).*p + t.*q;
                elseif j==17
                    xy1(97:102,:)=(1-t).*p + t.*q;
                end
                    
            end
           
         
        end
%        plot(xy1(:,1),xy1(:,2),'b-o')
%         hold on;

x = (0:1:115);
p = raylpdf(x,5);
W=zeros(2,115);
for i=1:116
    W(:,i)=[x(:,i);p(:,i)];
end
figure(1);
plot(x,p);

% Assignment
 Pos_1 = zeros(101,2);
  Kp=[1 0;0 1];    Ks=[1 0;0 1];   time=1;

for j=1:101  
    
    S1 = xy1(j,1)-xy1(j+1,1);
    S2 = xy1(j,2)-xy1(j+1,2);    
    S=[S1; S2];    
    Vq = -Kp*S - W - (Ks* sign(S)) + [10,20]';
    Vq_1 = Vq + W;
     s=Vq_1.*time;
     Pos_1(j,:)=[xy1(j,1); xy1(j,2)] + s(:,j);
    
end


figure(2);
axis equal;
line([P1(:,1)';P1shifted(:,1)'],[P1(:,2)';P1shifted(:,2)'],'Color','k');
hold on;
plot(xy1(:,1), xy1(:,2), 'g-o');
scatter(X1_start, Y1_start, 25, 'filled');
scatter(X1_end, Y1_end, 25, 'filled');
hold on;
plot(Pos_1(:,1), Pos_1(:,2), 'b-o');
hold on
scatter(X1_start, Y1_start, 25, 'filled');
hold on
scatter(X1_end, Y1_end, 25, 'filled');
hold on
scatter(800, 400, 25, 'filled');
hold off

