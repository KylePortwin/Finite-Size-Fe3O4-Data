
clear all
crystal = spinw;
 
%fcc lattice, FM
crystal.genlattice('lat_const',[8.38 8.38 8.38],'angle',[90 90 90]*pi/180,'sym','F d -3 m')
crystal.addatom('label','MFe3+','r',[0.125 0.125 0.125],'S',5/2, 'color','orange')
%Fe3+
crystal.addatom('label','MFe2+','r',[0.5 0.5 0.5],'S',2, 'color','blue')
%Fe2.5+
disp('Magnetic lattice:')
crystal.table('matom')
crystal.plot('range', [0 1; 0 1; 0 1]);

%J1 = - (FM), + (AFM) 

crystal.addmatrix('label','JAB','color',[255 0 0]','mat',-4.49*0.75*eye(3))
crystal.addmatrix('label','JBB','color',[0 255 0]','mat',0.67*0.75*eye(3))
 
crystal.gencoupling('maxDistance',12);
 
crystal.addcoupling('mat','JAB','bond',2)
crystal.addcoupling('mat','JBB','bond',1)

crystal.plot('range', [0 1; 0 1; 0 1]);
 
%% input mag. str. from paper
%PHYSICAL REVIEW MATERIALS 4, 075402 (2020)
S0 = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 1 1 1 1 1 1 1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
crystal.genmagstr('mode','direct','k',[0 1 0],'n',[1 0 1],'unitS','lu','S',S0);
disp('Magnetic structure:')
crystal.table('mag')
plot(crystal,'maglHead',0.5,'range',[-1 1; 0 2; -1 1])
crystal.plot('range', [0 1; 0 1; 0 1]);

%% spin waves
%Fe3O4spec = crystal.spinwave({[-1 0 0] [0 0 0] [1 1 0] [1 1 1] 100},'hermit',false);
%Fe3O4spec = sw_neutron(Fe3O4spec);
%Fe3O4spec = sw_egrid(Fe3O4spec, 'Evect',linspace(0,120,300),'component','Sperp');
%figure
%sw_plotspec(Fe3O4spec,'mode',1,'colorbar',false,'axLim',[0 150])

%% Powder spectrum
Fe3O4Pow = crystal.powspec(linspace(0,6,150),'Evect',linspace(0,175,150),'nRand',500,'hermit',false);
figure
sw_plotspec(Fe3O4Pow,'colorbar',true,'axLim',[0 1],'dE',1,'norm',true)
%this plots with an energy resolution which broadens spectral phases

%% Calculate Magnon Density of States
% Extract the intensity data and energy values from the powder spectrum
intensity = Fe3O4Pow.swConv;
energy = Fe3O4Pow.Evect;

% Define new energy bins to match the powder spectrum plot
dE = 0.1; % Energy bin size in meV
E_bins = 0:dE:max(energy);

% Bin the DOS data
DOS = zeros(size(E_bins));
for i = 1:length(E_bins)-1
    E_min = E_bins(i);
    E_max = E_bins(i+1);
    idx = energy >= E_min & energy < E_max;
    DOS(i) = sum(sum(intensity(idx,:)));
end

% Create a smooth line plot
E_plot = E_bins(1:end-1) + dE/2; % Center of each bin

% Plot the Magnon Density of States
figure
plot(E_plot, DOS(1:end-1), 'LineWidth', 2)
xlabel('Energy (meV)', 'FontSize', 12)
ylabel('Density of States (arb. units)', 'FontSize', 12)
title('Magnon Density of States', 'FontSize', 14)
xlim([0, max(energy)])
ylim([0, max(DOS)*1.1])
grid on

% Print some statistics
fprintf('Energy range: %.2f to %.2f meV\n', min(E_bins), max(E_bins));
fprintf('Number of points: %d\n', length(E_plot));
fprintf('Energy resolution: %.2f meV\n', dE);
