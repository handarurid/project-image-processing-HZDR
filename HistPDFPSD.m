clc;
disp('*******************************************************************')
disp('HISTOGRAM, PDF, PSD FOR TIME-SERIES SIGNAL FLUCTUATION')
disp('Developed by : 1. Dr. IGNB. Catrawedharma')
disp('               2. Dr(Cand). Setya Wijayanta')
disp('Contact info : +62 81229392829')
disp('Supervisors  : 1. Prof. Dr. Ir. Indarto, DEA.')
disp('               2. Prof. Dr. Deendarlianto, S.T., M.Eng.')
disp('*******************************************************************')
disp('-------------------------------------------------------------------')

% Excel data source
    A=xlsread('Data-R1_QL-1-9lpm_QG-90lpm_Journal','data-acquired','A16:B15016');
    t=A(:,1);  % Time-series
    h=A(:,2);  % Voltages
% Data filtering
    b=ones(1,10)/10;
    hfilt=filtfilt(b,1,h);
% Graphical Grid
    XLim = get(gca,'XLim');
    XLim = XLim + [-1 1] * 0.01 * diff(XLim);
    XGrid = linspace(XLim(1),XLim(2),100);
% Histogram
    [CdfF,CdfX] = ecdf(hfilt,'Function','cdf');  % compute empirical cdf
    BinInfo.rule = 1;
    [~,BinEdge] = internal.stats.histbins(hfilt,[],[],BinInfo,CdfF,CdfX);
    [BinHeight,BinCenter] = ecdfhist(CdfF,CdfX,'edges',BinEdge);
    figure (1),hLine = bar(BinCenter,BinHeight,'hist');
    set(hLine,'FaceColor','none','EdgeColor',[0.333333 0.666667 0],...
        'LineStyle','-', 'LineWidth',0.5);
    xlabel('Voltage (V)');
    ylabel('Probability');
% Normal PDF
    pd1 = fitdist(hfilt, 'normal');
    YPlot = pdf(pd1,XGrid);
    figure (2),hLine = plot(XGrid,YPlot,'Color',[1 0 0],...
        'LineStyle','-', 'LineWidth',1,...
        'Marker','none', 'MarkerSize',6);
    xlabel('Voltage (V)');
    ylabel('NormPDF');
% Beta PDF
    pd2 = fitdist(hfilt, 'beta');
    YPlot = pdf(pd2,XGrid);
    figure (3),hLine = plot(XGrid,YPlot,'Color',[0 0 1],...
        'LineStyle','-', 'LineWidth',1,...
        'Marker','none', 'MarkerSize',6);
    xlabel('Voltage (V)');
    ylabel('BetaPDF');
% Maximum and minimum time
    tmin=min(t);
    tmax=max(t);
    N=length(hfilt);    % Number of data
    dt=tmax/(N-1);      % Sampling time interval
    fs=1/dt;            % Sampling size
% Jumlah data PSD
    N1=2^(nextpow2(N)-1);   % Number of PSD data
    h1=hfilt(1:N1);         % PSD data filtering
% Time-series Voltase
    figure (4), plot(t(1:N1),h1,'r');
    xlabel('Time series (s)'); ylabel('Voltage (V)');
    Am=fft(h1);                                       % Fourrier trans
% Single-side spectrum convertion
    Am=Am(2:N1);
    y=Am.*conj(Am);           % Absolute value of Am (y=autocorrelation)
    PSD=y/N1^2;               % Power Spectrum
    f=((0:1:N1/2)*fs/N1);     % Spektrum frequency
    F=f';                     % Transpose column to row
    figure (5), semilogx(F,PSD(1:N1/2+1),'r');
    xlabel('Frequency (Hz)'); ylabel('PSD');
% Dominant frequency and Maximum spectrum
    PSDmax=max(PSD);                    % Maximum spectrum magnitude
    Indeksf=find(PSD(1:N1/2)==PSDmax);
    DomFreq=f(Indeksf);               % Dominant frequency magnitude
% Results stetements
    fprintf('\nCALCULATION PROPERTIES:\n')
    bremarks={'Minimum time','Maximum time','Number of data','Time interval','Sample size','Number of PSD data','Maximum spectrum','Dominant frequency'};
    bnotations={'tmin','tmax','N','dt','fs','N1','PSDmax','DomFreq'};
    bmagnitudes={tmin,tmax,N,dt,fs,N1,PSDmax,DomFreq};
    bunits={'second','second','data','second','Sample/second','data','Volt/Hz','Hz'};
    fprintf('%21s %12s %15s %14s\n','REMARK','NOTATION','MAGNITUDE','UNIT')
    results=[bremarks; bnotations; bmagnitudes; bunits];
    fprintf('%21s %12s %15.6f %14s\n',results{:})
disp('-------------------------------------------------------------------')