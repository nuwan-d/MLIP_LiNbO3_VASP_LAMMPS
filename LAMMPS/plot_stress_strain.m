close all;
clear all;
clc;


[fid] = fopen('ave-stress-strain.txt');
 
% Skip the first 2 lines
fgetl(fid);
fgetl(fid);

[data_local,count1] = fscanf(fid, '%f %f %f %f %f %f %f %f',[8,inf]);
    
fclose(fid);

data_local = data_local';

%% Averaging

sample_size = 2;

for i=1:floor(size(data_local,1)/sample_size)

    data_local_avg(i,:) = mean(data_local((i-1)*sample_size+1:(i)*sample_size,:));

end

true_strain = atan(data_local_avg(:,2));

time = (data_local_avg(:,1) - data_local_avg(1,1)).*0.0002;

data_to_store = [true_strain, data_local_avg(:,4)];


%% Plotting 

figure
plot(true_strain(:,1), data_local_avg(:,4),'-r','LineWidth',2)

xlabel('Strain','FontName','Arial','fontsize',12) % ,'fontweight','b'
ylabel('Stress (GPa)','FontName','Arial','fontsize',12)
grid off
axis([0 0.12 0 18])
set(gca,'LineWidth',1,'Fontsize',9)
set(gca,'FontName','Arial')

paperWidth = 3.15;
paperHeight = paperWidth*0.85;
set(gcf, 'paperunits', 'inches');
set(gcf, 'papersize', [paperWidth paperHeight]);
set(gcf, 'PaperPosition', [0    0   paperWidth paperHeight]);
print(gcf, '-dpng', 'stress_components'); % Colour



%% regression
X = [ones(10,1) true_strain(1:10,1)];
Y = data_local_avg(1:10,4);
[b,bint,r,rint,stats] = regress(Y,X);

modulus = b(2,1) %in MPa
strength = max(data_local_avg(:,4)) % in MPa

%% polyfit

x_01 = true_strain(1:10,1);
y_01 = data_local_avg(1:10,4);
p_01 = polyfit(x_01,y_01,1);
f_01 = polyval(p_01,x_01); 

%% Plotting 

figure
plot(true_strain(1:10,1), data_local_avg(1:10,4),'ok','LineWidth',1,'MarkerSize',2)
hold on
plot(true_strain(1:10,1), f_01,'-r','LineWidth',1,'MarkerSize',2)
grid on

legend('data','linear-fit')

set(gca,'LineWidth',1,'Fontsize',9)
set(gca,'FontName','Arial')

xlabel('\sigma_{33}','FontName','Arial','fontsize',12)
ylabel('\epsilon_{33} (GPa)','FontName','Arial','fontsize',12)