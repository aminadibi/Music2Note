clc
clear all
close all

w = warning ('off','all');
ref_notes = readtable('notes.csv');
Fs = 44100;
%%
d = daq.getDevices;
dev = d(2);
s = daq.createSession('directsound');
addAudioInputChannel(s, dev.ID, 1);
s.IsContinuous = true;

% setup fft of the live input
%% empty figure
hf = figure;
subplot(1,4,2:4);
hp = plot(zeros(1000,1));
T = title('Discrete FFT Plot');
xlabel('Frequency (Hz)')
ylabel('|FFT|')
grid on;
subplot(1,4,1);
plot(zeros(1,1))

%% background listener
% plotFFT = @(src, event) helper_continuous_fft(event.Data, src.Rate, hp);
% plotFFT = @(src, event) get_notes(event.Data, src.Rate);
plotFFT = @(src, event) plot_notes(event.Data, src.Rate, hp, ref_notes);
hl = addlistener(s, 'DataAvailable', plotFFT);

%% start
startBackground(s);
figure(hf);

%% add button
ButtonHStop=uicontrol('Parent',hf,'Style','pushbutton','String','Stop','Units','normalized',...
    'Position',[0.0 0.0 0.05 0.05],'Visible','on',...
    'Callback', {@stopProcess, hl, s});

ButtonHStart=uicontrol('Parent',hf,'Style','pushbutton','String','Start','Units','normalized',...
    'Position',[0.055 0.0 0.05 0.05],'Visible','on',...
    'Callback', {@startProcess, s});
%%
function stopProcess(source,event, hl, s)
    stop(s);
    s.IsContinuous = false;
%     delete(hl);
end

function startProcess(source,event, s)
    s.IsContinuous = true;    
    startBackground(s);    
end

