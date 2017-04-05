% demo_LFDA.m
%
% (c) Masashi Sugiyama, Department of Compter Science, Tokyo Institute of Technology, Japan.
%     sugi@cs.titech.ac.jp,     http://sugiyama-www.cs.titech.ac.jp/~sugi/software/LFDA/

clear all;

rand('state',0);
randn('state',0);

%%%%%%%%%%%%%%%%%%%%%% Generating data
n1a=100;
n1b=100;
n2=100;
X1a=[randn(2,n1a).*repmat([1;2],[1 n1a])+repmat([-6;0],[1 n1a])];
X1b=[randn(2,n1b).*repmat([1;2],[1 n1b])+repmat([ 6;0],[1 n1b])];
X2= [randn(2,n2 ).*repmat([1;2],[1 n2 ])+repmat([ 0;0],[1 n2 ])];
X=[X1a X1b X2];
Y=[ones(n1a+n1b,1);2*ones(n2,1)];


%%%%%%%%%%%%%%%%%%%%%% Computing LFDA solution
[T,Z]=LFDA(X,Y,1);
% [T,Z]=LFDA(X,Y,1,'weighted',6);

%%%%%%%%%%%%%%%%%%%%%% Displaying original 2D data
figure(1)
clf
hold on

set(gca,'FontName','Helvetica')
set(gca,'FontSize',12)
h=plot([-T(1) T(1)]*100,[-T(2) T(2)]*100,'k-','LineWidth',2);
legend('LFDA subspace',1)
h=plot(X(1,Y==1),X(2,Y==1),'bo');
h=plot(X(1,Y==2),X(2,Y==2),'rx');
axis equal
axis([-10 10 -10 10])
title('Original 2D data and subspace found by LFDA')

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0 12 12]);
print -depsc original_data


%%%%%%%%%%%%%%%%%%%%%% Displaying projected data
figure(2)
clf

subplot(2,1,1)
hold on
set(gca,'FontName','Helvetica')
set(gca,'FontSize',12)
hist(Z(Y==1),linspace(min(Z),max(Z),20));
h=get(gca,'Children');
set(h,'FaceColor','b')
axis([min(Z) max(Z) 0 inf])
title('Data projected onto 1D LFDA subspace')

subplot(2,1,2)
hold on
set(gca,'FontName','Helvetica')
set(gca,'FontSize',12)
hist(Z(Y==2),linspace(min(Z),max(Z),20));
h=get(gca,'Children');
set(h,'FaceColor','r')
axis([min(Z) max(Z) 0 inf])

set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0 12 12]);
print -depsc projected_data_LFDA

