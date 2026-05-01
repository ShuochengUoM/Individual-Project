%% plot_Pg_phase2_auto.m
% Phase 2 Pg figure with:
% 1) generator output trajectories from 0 to 500 s
% 2) Unit 1 outage marker at t = 300 s
% 3) Phase 2 theoretical optimal reference lines + values
% 4) automatically computed re-convergence time after outage

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

%% 2. Keep 0-500 s for Phase 1 + Phase 2 display
idx = (t >= 0) & (t <= 500);
t2 = t(idx);
Pg2 = Pg(idx,:);

%% 3. Define outage instant
t_out = 300;

%% 4. Effective output treatment after Unit 1 outage
% Unit 1 is disconnected in Phase 2.
% For the physical generator output plot, Pg1 is shown as 0 after outage.
Pg2(t2 >= t_out, 1) = 0;

%% 5. Theoretical optimal dispatch values (Phase 2)
% Phase 2: Unit 1 offline, active generators 2-6
% Total demand = 350 MW
% lambda* = 14.527
Pg_star_phase2 = [0, 50.53, 15.00, 168.14, 42.40, 73.92];

%% 6. Automatically compute re-convergence time after outage
% Settling criterion:
% after t = 300 s, all online generator errors remain within tol_pg afterwards
tol_pg = 1.0;        % MW
online_units = 2:6;  % Unit 1 is offline in Phase 2

idx_phase2 = t2 >= t_out;
t_post = t2(idx_phase2);
Pg_post = Pg2(idx_phase2,:);

Pg_error_post = abs(Pg_post(:,online_units) - Pg_star_phase2(online_units));

Ts_idx = NaN;
for k = 1:length(t_post)
    if all(Pg_error_post(k:end,:) <= tol_pg, 'all')
        Ts_idx = k;
        break;
    end
end

if ~isnan(Ts_idx)
    Ts_abs = t_post(Ts_idx);   % absolute time instant
    Ts_rec = Ts_abs - t_out;   % re-convergence time after outage
else
    Ts_abs = NaN;
    Ts_rec = NaN;
end

%% 7. Plot
figure('Color','w','Position',[100 100 1100 650]);

plot(t2, Pg2, 'LineWidth', 1.5);
hold on;

x_min = 0;
x_max = 500;

% Unit 1 outage marker
xline(t_out, '--k', 'Unit 1 outage', ...
    'LineWidth', 1.2, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'center');

% Plot Phase 2 theoretical optimal lines for online units
for i = 2:6
    yline(Pg_star_phase2(i), '--', ...
        'LineWidth', 1.0, ...
        'HandleVisibility','off');
end

% Plot Unit 1 offline reference at 0 MW
yline(0, ':', ...
    'LineWidth', 1.0, ...
    'HandleVisibility','off');

%% 8. Add numerical labels for Phase 2 theoretical optimal values
label_x = 470;   % near right-hand side of the plot

for i = 2:6
    text(label_x, Pg_star_phase2(i), ...
        sprintf('P^*_{g,%d}=%.2f MW', i, Pg_star_phase2(i)), ...
        'FontSize', 10, ...
        'FontName', 'Times New Roman', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'bottom', ...
        'BackgroundColor', 'w', ...
        'Margin', 1);
end

% Label Unit 1 offline status
text(label_x, 0, 'P_{g,1}=0 MW (offline)', ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

%% 9. Re-convergence time line
if ~isnan(Ts_abs)
    xline(Ts_abs, '--k', ...
        sprintf('Re-convergence time = %.2f s', Ts_rec), ...
        'LineWidth', 1.2, ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'top', ...
        'LabelHorizontalAlignment', 'center');
end

%% 10. Axes / labels / legend
xlabel('Time / s');
ylabel('Generator output P_{g,i} / MW');
title('Generator Outputs, Phase 1 and Phase 2');

legend({'P_{g,1}','P_{g,2}','P_{g,3}','P_{g,4}','P_{g,5}','P_{g,6}'}, ...
       'Location','eastoutside');

grid on;
xlim([x_min x_max]);

set(gca, 'FontName','Times New Roman', 'FontSize',11);

%% 11. Export figure
exportgraphics(gcf, 'Figure_4_4_Pg_Phase2_auto.png', 'Resolution', 300);

%% 12. Display useful results in Command Window
disp('Final simulated Pg at 500 s:');
disp(Pg2(end,:));

disp('Theoretical optimal Pg* after Unit 1 outage, Phase 2:');
disp(Pg_star_phase2);

disp('Absolute error at 500 s, online units only:');
disp(abs(Pg2(end,online_units) - Pg_star_phase2(online_units)));

if ~isnan(Ts_abs)
    fprintf('Automatically computed re-convergence time after outage (tol = %.2f MW): %.4f s\n', tol_pg, Ts_rec);
    fprintf('Absolute settling instant: %.4f s\n', Ts_abs);
else
    fprintf('No re-convergence time found before 500 s under tol = %.2f MW.\n', tol_pg);
end