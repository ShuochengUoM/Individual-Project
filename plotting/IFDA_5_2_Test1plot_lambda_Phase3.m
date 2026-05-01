%% plot_lambda_all_phases_auto.m
% Full-simulation lambda figure with:
% 1) lambda_i trajectories across all phases
% 2) Unit 1 outage marker at t = 300 s
% 3) Unit 1 reconnection marker at t = 500 s
% 4) End of reference-tracking transition marker at t = 502 s
% 5) theoretical optimal lambda* reference lines for Phase 1, Phase 2, and Phase 3/4
% 6) lambda_1 hidden during Unit 1 outage period
% 7) automatically computed post-reconnection re-convergence time after t = 502 s

clearvars -except lambda_scope
close all; clc;

%% 1. Read data
t = lambda_scope.time;
lambda = squeeze(lambda_scope.signals.values);   % likely 6 x N or N x 6

% Convert to N x 6 if needed
if size(lambda,1) == 6
    lambda = lambda.';
end

% Force time to column vector
t = t(:);

%% 2. Keep full simulation display
% Adjust t_end if your simulation is longer or shorter.
t_start = 0;
t_end   = max(t);

idx = (t >= t_start) & (t <= t_end);
t_all = t(idx);
lambda_all = lambda(idx,:);

%% 3. Define event instants
t_out = 300;       % Unit 1 outage
t_rec = 500;       % Unit 1 reconnection
t_tr_end = 502;    % end of reference-tracking transition

%% 4. Effective treatment during Unit 1 outage
% Unit 1 is disconnected during Phase 2.
% For lambda plot, hide lambda_1 from t = 300 s to t = 500 s.
lambda_all(t_all >= t_out & t_all < t_rec, 1) = NaN;

%% 5. Theoretical optimal incremental costs
% Phase 1: all generators online, total demand = 440 MW
lambda_star_phase1 = 13.864;

% Phase 2: active generators 2-6, total demand = 350 MW
lambda_star_phase2 = 14.527;

% Phase 3/4: all generators online, total demand = 378 MW
lambda_star_phase34 = 14.255;

%% 6. Automatically compute post-reconnection convergence time
% Settling criterion:
% after t = 502 s, all ONLINE lambda_i remain within tol_lambda afterwards
tol_lambda = 0.1;       % adjust if needed
online_units = 1:6;     % all units online after reconnection

idx_post = t_all >= t_tr_end;
t_post = t_all(idx_post);
lambda_post = lambda_all(idx_post,:);

lambda_error_post = abs(lambda_post(:,online_units) - lambda_star_phase34);

Ts_idx = NaN;
for k = 1:length(t_post)
    if all(lambda_error_post(k:end,:) <= tol_lambda, 'all')
        Ts_idx = k;
        break;
    end
end

if ~isnan(Ts_idx)
    Ts_abs = t_post(Ts_idx);        % absolute time instant
    Ts_rec = Ts_abs - t_tr_end;     % re-convergence time after transition
else
    Ts_abs = NaN;
    Ts_rec = NaN;
end

%% 7. Plot
figure('Color','w','Position',[100 100 1150 650]);

plot(t_all, lambda_all, 'LineWidth', 1.5);
hold on;

x_min = t_start;
x_max = t_end;

%% 8. Event markers
xline(t_out, '--k', 'Unit 1 outage', ...
    'LineWidth', 1.2, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'center');

xline(t_rec, '--k', 'Unit 1 reconnection', ...
    'LineWidth', 1.2, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'center');


%% 9. Plot theoretical lambda* reference lines
% Use short horizontal segments instead of full yline,
% so each reference only appears in its corresponding phase.

plot([0 t_out], [lambda_star_phase1 lambda_star_phase1], ...
    '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.0, 'HandleVisibility','off');

plot([t_out t_rec], [lambda_star_phase2 lambda_star_phase2], ...
    '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.0, 'HandleVisibility','off');

plot([t_tr_end x_max], [lambda_star_phase34 lambda_star_phase34], ...
    '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.0, 'HandleVisibility','off');

%% 10. Add numerical labels for theoretical lambda* values
text(250, lambda_star_phase1, ...
    sprintf('\\lambda^*=%.3f', lambda_star_phase1), ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

text(455, lambda_star_phase2, ...
    sprintf('\\lambda^*=%.3f', lambda_star_phase2), ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

% Put Phase 3/4 label near the right-hand side of the plot.
label_x_phase34 = x_max - 0.12*(x_max - x_min);

text(label_x_phase34, lambda_star_phase34, ...
    sprintf('\\lambda^*=%.3f', lambda_star_phase34), ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

%% 11. Optional label for Unit 1 being offline
yl = ylim;
text(375, yl(1) + 0.08*(yl(2)-yl(1)), ...
    '\lambda_1 hidden during outage', ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

%% 12. Post-reconnection re-convergence time line
if ~isnan(Ts_abs)
    xline(Ts_abs, '--k', ...
        sprintf('Re-convergence time = %.2f s', Ts_rec), ...
        'LineWidth', 1.2, ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'top', ...
        'LabelHorizontalAlignment', 'center');
end

%% 13. Axes / labels / legend
xlabel('Time / s');
ylabel('Incremental cost \lambda_i');
title('Incremental Cost Dynamics Across Reconnection Scenario');

legend({'\lambda_1','\lambda_2','\lambda_3','\lambda_4','\lambda_5','\lambda_6'}, ...
       'Location','eastoutside');

grid on;
box on;
xlim([x_min x_max]);

set(gca, 'FontName','Times New Roman', 'FontSize',11);

%% 14. Export figure
exportgraphics(gcf, 'Figure_4_7_lambda_All_Phases_auto.png', 'Resolution', 300);

%% 15. Display useful results in Command Window
disp('Final simulated lambda at end of simulation:');
disp(lambda_all(end,:));

disp('Theoretical optimal lambda* values:');
fprintf('Phase 1 lambda*: %.3f\n', lambda_star_phase1);
fprintf('Phase 2 lambda*: %.3f\n', lambda_star_phase2);
fprintf('Phase 3/4 lambda*: %.3f\n', lambda_star_phase34);

disp('Absolute error at final time:');
disp(abs(lambda_all(end,online_units) - lambda_star_phase34));

if ~isnan(Ts_abs)
    fprintf('Automatically computed post-reconnection re-convergence time after t = 502 s (tol = %.3f): %.4f s\n', tol_lambda, Ts_rec);
    fprintf('Absolute settling instant: %.4f s\n', Ts_abs);
else
    fprintf('No post-reconnection re-convergence time found before %.1f s under tol = %.3f.\n', x_max, tol_lambda);
end