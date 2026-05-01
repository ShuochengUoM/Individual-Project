%% plot_mismatch_all_phases_auto.m
% Full-simulation mismatch figure with:
% 1) mismatch trajectory across all phases
% 2) Unit 1 outage marker at t = 300 s
% 3) Unit 1 reconnection marker at t = 500 s
% 4) End of reference-tracking transition marker at t = 502 s
% 5) theoretical mismatch* reference line (= 0)
% 6) automatically computed post-reconnection re-convergence time after t = 502 s

clearvars -except mismatch_scope
close all; clc;

%% 1. Read data
t = mismatch_scope.time;
mismatch = squeeze(mismatch_scope.signals.values);

% Force column vectors
t = t(:);
mismatch = mismatch(:);

%% 2. Keep full simulation display
t_start = 0;
t_end   = max(t);

idx = (t >= t_start) & (t <= t_end);
t_all = t(idx);
mismatch_all = mismatch(idx);

%% 3. Define event instants
t_out = 300;       % Unit 1 outage
t_rec = 500;       % Unit 1 reconnection
t_tr_end = 502;    % end of reference-tracking transition

%% 4. Theoretical optimal mismatch
% At optimal steady state, supply-demand mismatch should converge to zero.
mismatch_star = 0;

%% 5. Automatically compute post-reconnection re-convergence time
% Settling criterion:
% after t = 502 s, |mismatch| remains within tol_mismatch afterwards
tol_mismatch = 0.5;    % MW, adjust if needed

idx_post = t_all >= t_tr_end;
t_post = t_all(idx_post);
mismatch_post = mismatch_all(idx_post);

mismatch_error_post = abs(mismatch_post - mismatch_star);

Ts_idx = NaN;
for k = 1:length(t_post)
    if all(mismatch_error_post(k:end) <= tol_mismatch)
        Ts_idx = k;
        break;
    end
end

if ~isnan(Ts_idx)
    Ts_abs = t_post(Ts_idx);         % absolute time instant
    Ts_rec = Ts_abs - t_tr_end;      % re-convergence time after transition
else
    Ts_abs = NaN;
    Ts_rec = NaN;
end

%% 6. Plot
figure('Color','w','Position',[100 100 1150 650]);

plot(t_all, mismatch_all, 'LineWidth', 1.8);
hold on;

x_min = t_start;
x_max = t_end;

%% 7. Shade 500-502 s reference-tracking transition
yl0 = [min(mismatch_all), max(mismatch_all)];
y_span = yl0(2) - yl0(1);

if y_span < 1e-6
    y_span = 1;
end

y_min = yl0(1) - 0.10*y_span;
y_max = yl0(2) + 0.10*y_span;
ylim([y_min y_max]);

patch([t_rec t_tr_end t_tr_end t_rec], ...
      [y_min y_min y_max y_max], ...
      [0.85 0.85 0.85], ...
      'FaceAlpha', 0.25, ...
      'EdgeColor', 'none', ...
      'HandleVisibility','off');

% replot curve so it stays above patch
plot(t_all, mismatch_all, 'LineWidth', 1.8);

%% 8. Event markers
xline(t_out, '--k', '300s Unit 1 outage', ...
    'LineWidth', 1.2, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'center');

xline(t_rec, '--k', '500s Unit 1 reconnection', ...
    'LineWidth', 1.2, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'bottom', ...
    'LabelHorizontalAlignment', 'center');

xline(t_tr_end, '--k', '502s Transition ends', ...
    'LineWidth', 1.2, ...
    'LabelOrientation', 'horizontal', ...
    'LabelVerticalAlignment', 'top', ...
    'LabelHorizontalAlignment', 'center');

%% 9. Plot theoretical mismatch reference line
yline(mismatch_star, '--', 'LineWidth', 1.0, 'HandleVisibility','off');

%% 10. Add numerical label for theoretical mismatch value
label_x = x_max - 0.12*(x_max - x_min);

text(label_x, mismatch_star, ...
    'Mismatch^*=0', ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

%% 11. Optional label for the transition interval
text(t_rec + 0.2, y_max - 0.07*(y_max-y_min), ...
    'Reference-tracking transition', ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'BackgroundColor', 'w', ...
    'Margin', 1);

%% 12. Post-reconnection re-convergence time line
if ~isnan(Ts_abs)
    xline(Ts_abs, '--k', ...
        sprintf('Re-convergence time = %.2f s', Ts_rec), ...
        'LineWidth', 1.2, ...
        'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'middle', ...
        'LabelHorizontalAlignment', 'center');
end

%% 13. Axes / labels / legend
xlabel('Time / s');
ylabel('Supply-demand mismatch / MW');
title('Supply-Demand Mismatch Across Reconnection Scenario');

legend({'Mismatch'}, 'Location','eastoutside');

grid on;
box on;
xlim([x_min x_max]);
ylim([y_min y_max]);

set(gca, 'FontName','Times New Roman', 'FontSize',11);

%% 14. Export figure
exportgraphics(gcf, 'Figure_4_8_mismatch_All_Phases_auto.png', 'Resolution', 300);

%% 15. Display useful results in Command Window
disp('Final simulated mismatch at end of simulation:');
disp(mismatch_all(end));

disp('Theoretical optimal mismatch*:');
disp(mismatch_star);

disp('Absolute mismatch error at final time:');
disp(abs(mismatch_all(end) - mismatch_star));

% Additional useful diagnostics
fprintf('Maximum absolute mismatch over full simulation: %.4f MW\n', max(abs(mismatch_all)));

idx_out_event = (t_all >= t_out) & (t_all <= t_out + 10);
if any(idx_out_event)
    fprintf('Maximum absolute mismatch within 10 s after outage: %.4f MW\n', ...
        max(abs(mismatch_all(idx_out_event))));
end

idx_rec_event = (t_all >= t_rec) & (t_all <= t_rec + 10);
if any(idx_rec_event)
    fprintf('Maximum absolute mismatch within 10 s after reconnection: %.4f MW\n', ...
        max(abs(mismatch_all(idx_rec_event))));
end

if ~isnan(Ts_abs)
    fprintf('Automatically computed post-reconnection re-convergence time after t = 502 s (tol = %.3f MW): %.4f s\n', tol_mismatch, Ts_rec);
    fprintf('Absolute settling instant: %.4f s\n', Ts_abs);
else
    fprintf('No post-reconnection re-convergence time found before %.1f s under tol = %.3f MW.\n', x_max, tol_mismatch);
end