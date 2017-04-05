function [fitresult, gof] = my_fourierFit(x, y, type)
%CREATEFIT(X,ZZ)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x
%      Y Output: zz
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 07-Aug-2015 22:12:01 自动生成

if nargin==1
    y=x;
    x=1:length(y); x=reshape(x,size(y,1),size(y,2));
end
if nargin<3
    type = 'fourier1';
end

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( type );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf 0.3]; % 2*pi/0.3=21
% opts.StartPoint = [0 0 0 w];
opts.Upper = [Inf Inf Inf 0.5]; % 2*pi/0.5=12.5

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% % Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'zz vs. x', 'untitled fit 1', 'Location', 'NorthEast' );
% % Label axes
% xlabel( 'x' );
% ylabel( 'zz' );
% grid on

end

