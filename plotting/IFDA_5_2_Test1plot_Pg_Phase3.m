%% plot_Pg_reconnection_auto.m
% Phase 3/4 Pg figure with:
% 1) Pg_i trajectories around reconnection, from 490 to 550 s
% 2) Unit 1 reconnection marker at t = 500 s
% 3) End of reference-tracking transition marker at t = 502 s
% 4) post-reconnection theoretical optimal Pg* reference lines
% 5) automatically computed post-reconnection convergence time after t = 502 s

clearvars -except Pg_scope
close all; clc;

%% 1. Read data
t = Pg_scope.time;
Pg = squeeze(Pg_scope.signals.values);   % likely 6 x N or N x 6

% Convert to N x 6 if needed
if size(Pg,1) == 6
    Pg = Pg.';
end

% Force time to column vector
t = t(:);

%% 2. Keep 490-550 s for reconnection zoom display
t_start = 490;
t_end   = 550;

idx = (t >= t_start) & (t <= t_end);
t_zoom = t(idx);
Pg_zoom = Pg(idx,:);

%% 3. Define reconnection instants
t_rec = 500;     % Unit 1 reconnection instant
t_tr_end = 502;  % end of reference-tracking transition

%% 4. Theoretical optimal dispatch after reconnection
% Phase 3/4: active generators 1-6
% total demand = 378 MW
% active constraints: Pg1 = Pg1_max, Pg3 = Pg3_min
Pg_star_phase34 = [60.00, 45.11, 15.00, 153.08, 34.87, 69.93];

%% 5. Automatically compute convergence time after transition
% Settling criterion:
% after t = 502 s, all Pg_i remain within tol_Pg afterwards
tol_Pg = 1.0;          % MW, adjust if needed
online_units = 1:6;    % all units online after reconnection

idx_post = t_zoom >= t_tr_end;
t_post = t_zoom(idx_post);
Pg_post = Pg_zoom(idx_post,:);

Pg_error_post = abs(Pg_post(:,online_units) - Pg_star_phase34(online_units));

Ts_idx = NaN;
for k = 1:length(t_post)
    if all(Pg_error_post(k:end,:) <= tol_Pg, 'all')
        Ts_idx = k;
        break;
    end
end

if ~isnan(Ts_idx)
    Ts_abs = t_post(Ts_idx);        % absolute time instant
    Ts_rec = Ts_abs - t_tr_end;     % convergence time after 502 s
else
    Ts_abs = NaN;
    Ts_rec = NaN;
end

%% 6. Plot
figure('Color','w','Position',[100 100 1100 650]);

hold on;

x_min = t_start;
x_max = t_end;

%% 7. Set y-limit before shaded area
y_data_min = min(Pg_zoom(:));
y_data_max = max(Pg_zoom(:));

y_ref_min = min(Pg_star_phase34);
y_ref_max = max(Pg_star_phase34);

y_min = min(y_data_min, y_ref_min) - 8;
y_max = max(y_data_max, y_ref_max) + 8;

ylim([y_min y_max]);

%% 8. Shade 500-502 s reference-tracking transition
patch([t_rec t_tr_end t_tr_end t_rec], ...
      [y_min y_min y_max y_max], ...
      [0.85 0.85 0.85], ...
      'FaceAlpha', 0.25, ...
      'EdgeColor', 'none', ...
      'HandleVisibility','off');

%% 9. Plot Pg trajectories
p = plot(t_zoom, Pg_zoom, 'LineWidth', 1.5);

%% 10. Reconnection and transition markers
xline(t_rec, '--k', 'Unit 1 reconnection', ...
    'LineWidth', 1.2, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'center');

xline(t_tr_end, '--k', 'Transition ends', ...
    'LineWidth', 1.2, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'top', ...
    'LabelHorizontalAlignment', 'center');

%% 11. Plot theoretical optimal Pg* reference lines
% Use the same colors as Pg_i curves
for i = 1:6
    yline(Pg_star_phase34(i), '--', ...
        'Color', p(i).Color, ...
        'LineWidth', 1.0, ...
        'HandleVisibility','off');
end

%% 12. Add numerical labels for theoretical Pg* values
label_x = 543;   % near right-hand side of the zoomed plot

for i = 1:6
    text(label_x, Pg_star_phase34(i), ...
        sprintf('P_{g%d}^*=%.2f', i, Pg_star_phase34(i)), ...
        'FontSize', 9, ...
        'FontName', 'Times New Roman', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'bottom', ...
        'BackgroundColor', 'w', ...
        'Margin', 1, ...
        'Color', p(i).Color);
end

%% 13. Optional label for the 2-second transition
text(500.2, y_max - 0.08*(y_max-y_min), ...
    'Reference-tracking transition', ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

%% 14. Post-reconnection convergence time line
if ~isnan(Ts_abs)
    xline(Ts_abs, '--k', ...
        sprintf('Convergence time = %.2f s', Ts_rec), ...
        'LineWidth', 1.2, ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'middle', ...
        'LabelHorizontalAlignment', 'center');
end

%% 15. Axes / labels / legend
xlabel('Time / s');
ylabel('Generator output P_{g,i} / MW');
title('Generator Output Dynamics During Reconnection');

legend({'P_{g1}','P_{g2}','P_{g3}','P_{g4}','P_{g5}','P_{g6}'}, ...
       'Location','eastoutside');

grid on;
box on;
xlim([x_min x_max]);
ylim([y_min y_max]);

set(gca, 'FontName','Times New Roman', 'FontSize',11);

%% 16. Export figure
exportgraphics(gcf, 'Figure_4_6_Pg_Reconnection_Zoom_auto.png', 'Resolution', 300);

%% 17. Display useful results in Command Window
disp('Final simulated Pg at 550 s:');
disp(Pg_zoom(end,:));

disp('Theoretical optimal Pg* after reconnection, Phase 3/4:');
disp(Pg_star_phase34);

disp('Absolute error at 550 s:');
disp(abs(Pg_zoom(end,:) - Pg_star_phase34));

if ~isnan(Ts_abs)
    fprintf('Automatically computed Pg convergence time after transition end t = 502 s (tol = %.3f MW): %.4f s\n', tol_Pg, Ts_rec);
    fprintf('Absolute settling instant: %.4f s\n', Ts_abs);
else
    fprintf('No Pg convergence time found before %.1f s under tol = %.3f MW.\n', t_end, tol_Pg);
end