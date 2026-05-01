%% plot_Pg_phase1_auto.m
% Phase 1 Pg figure with:
% 1) theoretical optimal reference lines + values
% 2) automatically computed settling time

clearvars -except Pg_scope
close all; clc;

%% 1. Read data
t = Pg_scope.time;
Pg = squeeze(Pg_scope.signals.values);   % likely 6 x N

% Convert to N x 6 if needed
if size(Pg,1) == 6
    Pg = Pg.';
end

% Force time to column vector
t = t(:);

%% 2. Keep Phase 1 only
idx = t < 300;
t1 = t(idx);
Pg1 = Pg(idx,:);

%% 3. Theoretical optimal dispatch values (Phase 1)
Pg_star = [168.20, 37.28, 15.00, 131.34, 24.00, 64.18];

%% 4. Automatically compute settling time
% Settling criterion:
% all generator errors remain within tol_pg afterwards
tol_pg = 1.0;   % MW

Pg_error = abs(Pg1 - Pg_star);   % implicit row expansion

Ts_idx = NaN;
for k = 1:length(t1)
    if all(Pg_error(k:end,:) <= tol_pg, 'all')
        Ts_idx = k;
        break;
    end
end

if ~isnan(Ts_idx)
    Ts = t1(Ts_idx);
else
    Ts = NaN;
end

%% 5. Plot
figure('Color','w','Position',[100 100 1100 650]);
plot(t1, Pg1, 'LineWidth', 1.5);
hold on;

% Get axis limits later for annotations
x_min = 0;
x_max = 300;

% Plot theoretical optimal lines
for i = 1:6
    yline(Pg_star(i), '--', 'LineWidth', 1.0, 'HandleVisibility','off');
end

% Add numerical labels for theoretical optimal values
% Put the labels near the right-hand side of the plot
label_x = 285;   % you can adjust this if needed

for i = 1:6
    text(label_x, Pg_star(i), ...
        sprintf('P^*_{g,%d}=%.2f MW', i, Pg_star(i)), ...
        'FontSize', 10, ...
        'FontName', 'Times New Roman', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'bottom', ...
        'BackgroundColor', 'w', ...
        'Margin', 1);
end

% Settling time line
if ~isnan(Ts)
    xline(Ts, '--k', sprintf('Settling time = %.2f s', Ts), ...
        'LineWidth', 1.2, ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'bottom', ...
        'LabelHorizontalAlignment', 'center');
end

%% 6. Axes / labels / legend
xlabel('Time / s');
ylabel('Generator output P_{g,i} / MW');
title('Generator Output Convergence, Phase 1');

legend({'P_{g,1}','P_{g,2}','P_{g,3}','P_{g,4}','P_{g,5}','P_{g,6}'}, ...
       'Location','eastoutside');

grid on;
xlim([x_min x_max]);

set(gca, 'FontName','Times New Roman', 'FontSize',11);

%% 7. Export figure
exportgraphics(gcf, 'Figure_4_1_Pg_Phase1_auto.png', 'Resolution', 300);

%% 8. Display useful results in Command Window
disp('Final simulated Pg before 300 s:');
disp(Pg1(end,:));

disp('Theoretical optimal Pg*:');
disp(Pg_star);

disp('Absolute error at the end of Phase 1:');
disp(abs(Pg1(end,:) - Pg_star));

if ~isnan(Ts)
    fprintf('Automatically computed settling time (tol = %.2f MW): %.4f s\n', tol_pg, Ts);
else
    fprintf('No settling time found before 300 s under tol = %.2f MW.\n', tol_pg);
end