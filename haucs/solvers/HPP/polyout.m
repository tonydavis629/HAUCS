P1=polyshape([0 0 740 740],[0 370 370 0]);
P2=polyshape([0 0 740 740],[370 745 745 370]);
P3=polyshape([740 740 740 1320],[0 370 745 745]);

% polyout=union(P1,P2);

plot(P1);
hold on;
plot(P2);
hold on;
plot(P3)