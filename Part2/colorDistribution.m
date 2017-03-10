load('Ysamples_comb.mat')
load('Rsamples_comb.mat')
load('Gsamples_1.mat')

figure
scatter3(Ysamples_comb(:,1), Ysamples_comb(:,2), Ysamples_comb(:,3), '.')
title('Color Distribution Yellow Buoy')
xlabel('Red')
ylabel('Green')
zlabel('Blue')
figure
scatter3(Rsamples_comb(:,1), Rsamples_comb(:,2), Rsamples_comb(:,3), '.')
title('Color Distribution Red Buoy')
xlabel('Red')
ylabel('Green')
zlabel('Blue')
figure
scatter3(Gsamples_1(:,1), Gsamples_1(:,2), Gsamples_1(:,3), '.')
title('Color Distribution Green Buoy')
xlabel('Red')
ylabel('Green')
zlabel('Blue')