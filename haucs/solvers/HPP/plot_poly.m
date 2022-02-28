
function plot_poly(nodes, vertices)
    hold on
    plot(vertices(:,1),vertices(:,2),'-')
    scatter(nodes(:,1),nodes(:,2),'.')
    hold off
end