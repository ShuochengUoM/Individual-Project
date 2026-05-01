%% plot_mismatch_phase1_auto.m
% Phase 1 mismatch figure with:
% 1) zero reference line
% 2) tolerance band
% 3) automatically computed settling time
%
% Required workspace variable:
% mismatch_scope

clearvars -except mismatch_scope
close all; clc;

%% 1. Read data
t = mismatch_scope.time;
mismatch = mismatch_scope.signals.values;

% Force mismatch into a column vector
mismatch = mismatch(:);
t = t(:);

%% 2. Keep Phase 1 only
idx = t < 300;
t1 = t(idx);
mismatch1 = mismatch(idx);

%% 3. Settling criterion
% Settling time is defined as the earliest time after which
% |mismatch(t)| remains within tol_mis for the rest of Phase 1

tol_mis = 1.0;   % MW, can change to 0.5 or 2 depending on your requirement

Ts_idx = NaN;
for k = 1:length(t1)
    if all(abs(mismatch1(k:end)) <= tol_mis)
        Ts_idx = k;
        break;
    end
end

if ~isnan(Ts_idx)
    Ts = t1(Ts_idx);
else
    Ts = NaN;
end

%% 4. Plot
figure('Color','w','Position',[100 100 1100 650]);

plot(t1, mismatch1, 'LineWidth', 1.6);
hold on;

% Zero line
yline(0, '--k', 'Mismatch = 0', ...
    'LineWidth', 1.3, ...
    'LabelHorizontalAlignment','left', ...
    'LabelVerticalAlignment','bottom');


% Settling time line
if ~isnan(Ts)
    xline(Ts, '--k', ...
        sprintf('Settling time = %.2f s', Ts), ...
        'LineWidth', 1.2, ...
        'LabelOrientation','horizontal', ...
        'LabelVerticalAlignment','bottom', ...
        'LabelHorizontalAlignment','center');
end

%% 5. Axes / labels
xlabel('Time / s');
ylabel('Supply-demand mismatch / MW');
title('Supply-Demand Mismatch, Phase 1');

grid on;
xlim([0 300]);

set(gca, 'FontName','Times New Roman', 'FontSize',11);

%% 6. Export figure
exportgraphics(gcf, 'Figure_4_3_Mismatch_Phase1_auto.png', 'Resolution', 300);

%% 7. Display useful results
disp('Final mismatch before 300 s:');
disp(mismatch1(end));

disp('Maximum absolute mismatch in Phase 1:');
disp(max(abs(mismatch1)));

if ~isnan(Ts)
    fprintf('Automatically computed mismatch settling time (tol = %.2f MW): %.4f s\n', tol_mis, Ts);
else
    fprintf('No mismatch settling time found before 300 s under tol = %.2f MW.\n', tol_mis);
end