function []=Vibration_measure(vidFile, scaleVideo, max_amplitude_threshold, cut_threshold, direction) 

% vidFile ��Ƶ�ļ���ʹ��ǰ�����ȶ���Ƶ�������źͳ��Ȳü������ٲ���Ҫ����Դ���ġ�
% scaleVideo ����Ƶ���еȱ�������
% max_amplitude_threshold �޳�һЩ�񶯹���ĵ㣬��ֵ��ʾ�޳���������
% cut_threshold 
% direction ѡ���񶯷��򣬿�ѡ����'x',��y��,�����Զ�ѡ�񷽷���Ŀǰ���ڹ�˼��
% ����ʾ��
%Vibration_measure('10hz_20.mp4',1,14,2,'y')
close all; 

%% Filters
G20 = steerGaussFilterG2(0,1);
H20 = steerGaussFilterH2(0,1);
G290 = steerGaussFilterG2(90,1);
H290 = rot90(H20,1);

Filter_x = G20 + i.*H20; 
Filter_y = G290 + i.*H290;

subplot(2,2,1);imagesc(G290);colormap(gray);
subplot(2,2,2);imagesc(H290);colormap(gray);
subplot(2,2,3);imagesc(G20);colormap(gray);
subplot(2,2,4);imagesc(H20);colormap(gray);

%% Read Video
vr = VideoReader(vidFile);
FrameRate = vr.FrameRate; % ֡��
vid = vr.read();  % ��ȡ����֡
[h, w, nC, nF] = size(vid); % �� �� ͨ���� ��֡��

fprintf('��Ƶ���Ϊ:%dx%d\n',w,h);
fprintf('��Ƶ֡��Ϊ:%f\n',FrameRate);
fprintf('��Ƶ����Ϊ:%d֡\n',nF); 
fprintf('��Ƶ����Ϊ:%f��\n',nF/FrameRate);

vid = vid(:,:,:,1:nF);

[h, w, nC, nF] = size(vid); % �� �� ͨ���� ��֡��
if (scaleVideo~= 1)
    [h,w] = size(imresize(vid(:,:,1,1), scaleVideo));
end

vidFFT_x = zeros(h,w,nF,'single');
vidFFT_y = zeros(h,w,nF,'single');

for k = 1:nF
    originalFrame = rgb2ntsc(im2single(vid(:,:,:,k)));
    tVid = imresize(originalFrame(:,:,1), [h w]); % ȡ��һ��ͨ��
    vidFFT_x(:,:,k) = single(conv2(tVid,Filter_x,'same')); % ��Ƶ�任��Ƶ��
    vidFFT_y(:,:,k) = single(conv2(tVid,Filter_y,'same'));
end

% �ο�֡
vidFFT_x_ref = vidFFT_x(:,:,1);
vidFFT_y_ref = vidFFT_y(:,:,1);
% �ο���ֵ
vidFFT_x_ref_abs = abs(vidFFT_x_ref);
vidFFT_y_ref_abs = abs(vidFFT_y_ref);
% �ο����
vidFFT_x_ref_angle = angle(vidFFT_x_ref);
vidFFT_y_ref_angle = angle(vidFFT_y_ref);

size_Ref = size(vidFFT_x_ref_abs);

% reshapeΪһά
vidFFT_x_ref_abs_reshaped = reshape(vidFFT_x_ref_abs, 1, size_Ref(1)*size_Ref(2));
vidFFT_y_ref_abs_reshaped = reshape(vidFFT_y_ref_abs, 1, size_Ref(1)*size_Ref(2));

vidFFT_x_ref_abs_reshaped_sorted = sort(vidFFT_x_ref_abs_reshaped);
vidFFT_y_ref_abs_reshaped_sorted = sort(vidFFT_y_ref_abs_reshaped);

threshhold_x = vidFFT_x_ref_abs_reshaped_sorted(size_Ref(1)*size_Ref(2)-max_amplitude_threshold);
threshhold_y = vidFFT_y_ref_abs_reshaped_sorted(size_Ref(1)*size_Ref(2)-max_amplitude_threshold);

count_considered_x = 0;
for index_i = 1:size_Ref(1)
    for index_j = 1:size_Ref(2)
        if(vidFFT_x_ref_abs(index_i,index_j) > threshhold_x /cut_threshold )
            count_considered_x = count_considered_x + 1;
        end
    end
end

count_considered_y = 0;
for index_i = 1:size_Ref(1)
    for index_j = 1:size_Ref(2)
        if(vidFFT_y_ref_abs(index_i,index_j) > threshhold_y /cut_threshold )
            count_considered_y = count_considered_y + 1;
        end
    end
end


index_max_am_x = int16(zeros(count_considered_x,2));
index = 1;
for index_i = 1:size_Ref(1)
    for index_j = 1:size_Ref(2)
        if(vidFFT_x_ref_abs(index_i,index_j) > threshhold_x /cut_threshold )
             index_max_am_x(index,1) = index_i;
             index_max_am_x(index,2) = index_j;
             index = index + 1;
             %fprintf('(%d, %d) \n', i, j);
        end
    end
end


index_max_am_y = int16(zeros(count_considered_y,2));
index = 1;
for index_i = 1:size_Ref(1)
    for index_j = 1:size_Ref(2)
        if(vidFFT_y_ref_abs(index_i,index_j) > threshhold_y /cut_threshold )
             index_max_am_y(index,1) = index_i;
             index_max_am_y(index,2) = index_j;
             index = index + 1;
             %fprintf('(%d, %d) \n', i, j);
        end
    end
end

delta_x = zeros(size(vidFFT_x_ref,1), size(vidFFT_x_ref,2) ,nF,'single');
delta_y = zeros(size(vidFFT_y_ref,1), size(vidFFT_y_ref,2) ,nF,'single');

dd_x_angle = zeros(size(vidFFT_x_ref,1), size(vidFFT_x_ref,2) ,nF,'single');
dd_y_angle = zeros(size(vidFFT_y_ref,1), size(vidFFT_y_ref,2) ,nF,'single');

amplitude_change_x = zeros(nF,count_considered_x);
phase_change_x = zeros(nF,count_considered_x);

amplitude_change_y = zeros(nF,count_considered_y);
phase_change_y = zeros(nF,count_considered_y);


for frameIDX = 1:nF
    
    filterResponse_x = vidFFT_x(:,:,frameIDX);
    CurrentfilterResponse_x_abs = abs(filterResponse_x);
    CurrentfilterResponse_x_angle = angle(filterResponse_x);
    %���� ��λ��֣�������
    dd_CurrentfilterResponse_x_angle = mipcentraldiff(CurrentfilterResponse_x_angle,'dx');
    dd_CurrentfilterResponse_x_angle = -1./dd_CurrentfilterResponse_x_angle;
    dd_x_angle(:,:,frameIDX) = dd_CurrentfilterResponse_x_angle;
    %��λ��
    delta_x(:,:,frameIDX) = single(mod(pi+CurrentfilterResponse_x_angle-vidFFT_x_ref_angle,2*pi)-pi);  
    for index = 1:count_considered_x
        amplitude_change_x(frameIDX, index) = CurrentfilterResponse_x_abs(index_max_am_x(index,1), index_max_am_x(index,2));
        phase_change_x(frameIDX, index) = CurrentfilterResponse_x_angle(index_max_am_x(index,1), index_max_am_x(index,2));
    end

    filterResponse_y = vidFFT_y(:,:,frameIDX);
    CurrentfilterResponse_y_abs = abs(filterResponse_y);
    CurrentfilterResponse_y_angle = angle(filterResponse_y);
    %imshow(CurrentfilterResponse_y_angle);
    
    %���� ��λ��֣�������
    dd_CurrentfilterResponse_y_angle = mipcentraldiff(CurrentfilterResponse_y_angle,'dy');
    dd_CurrentfilterResponse_y_angle = -1./dd_CurrentfilterResponse_y_angle;
    dd_y_angle(:,:,frameIDX) = dd_CurrentfilterResponse_y_angle;
    %��λ��
    delta_y(:,:,frameIDX) = single(mod(pi+CurrentfilterResponse_y_angle-vidFFT_y_ref_angle,2*pi)-pi);  
    for index = 1:count_considered_y
        amplitude_change_y(frameIDX, index) = CurrentfilterResponse_y_abs(index_max_am_y(index,1), index_max_am_y(index,2));
        phase_change_y(frameIDX, index) = CurrentfilterResponse_y_angle(index_max_am_y(index,1), index_max_am_y(index,2));
    end

end

figure;
for index_i = 1:count_considered_x
    subplot(2,2,1);
    plot(amplitude_change_x(:,index_i));
    hold on;
    subplot(2,2,2);
    plot(phase_change_x(:,index_i));
    hold on;
end


for index_i = 1:count_considered_y
    subplot(2,2,3);
    plot(amplitude_change_y(:,index_i));
    hold on;
    subplot(2,2,4);
    plot(phase_change_y(:,index_i));
    hold on;
end

displacement_x = delta_x.*dd_x_angle;
displacement_y = delta_y.*dd_y_angle;


figure; 
subplot(121);
imshow(vid(:,:,:,1));
hold on;
scatter(index_max_am_y(:,2), index_max_am_y(:,1));
grid on;
subplot(122);
%imshow(vid(:,:,:,1));
hold on;
scatter(index_max_am_y(:,2), index_max_am_y(:,1));
set(gca,'YDir','reverse');
grid on;


if (direction== 'x')
    %displacement_d = displacement_x(222,25,:); %С��
    displacement_d = displacement_x(222,123,:); %������
    displacement_dd= displacement_d(:);
    figure;plot(displacement_dd);
    yy= fft(displacement_dd,nF);
    magmag = abs(yy);
    nn= 0:nF-1;
    ff = nn * FrameRate/nF;
    figure;plot(ff(1:int16(nF/2)),magmag(1:int16(nF/2)));
    xlabel('Ƶ��/Hz');
    ylabel('���');grid on;
    figure;plot(displacement_dd);
    ylabel('λ���������أ�');
    xlabel('֡');
    figure;plot([1:nF]./FrameRate, displacement_dd);
    xlabel('ʱ�䣨�룩');
    ylabel('λ���������أ�');       


%С���һ������
%     displacement_d = displacement_x(222,25,:);
%     displacement_dd= displacement_d(:);
%     displacement_dd= displacement_dd(271:360);
%     figure;plot(displacement_dd);
%     nF=360-271+1;
%     yy= fft(displacement_dd,nF);
%     magmag = abs(yy);
%     nn= 0:nF-1;
%     ff = nn * FrameRate/nF;
%     figure;plot(ff(1:int16(nF/2)),magmag(1:int16(nF/2)));
%     xlabel('Ƶ��/Hz');
%     ylabel('���');grid on;
%     figure;plot(displacement_dd);
%     ylabel('λ���������أ�');
%     xlabel('֡');
%     figure;plot([1:nF]./FrameRate, displacement_dd);
%     xlabel('ʱ�䣨�룩');
%     ylabel('λ���������أ�');  


end

if (direction== 'y')
    %displacement_d = displacement_y(275,190,:); %5��17
    %displacement_d = displacement_y(228,200,:); %10��20
    %displacement_d = displacement_y(280,120,:); %go pro 11HZ
    %displacement_d = displacement_y(277,260,:); %go pro 20HZ
    displacement_d = displacement_y(261,161,:); %go pro 37HZ good
    %displacement_d = displacement_y(267,355,:); %go pro 37HZ
    %displacement_d = displacement_y(286,100,:); %go pro 12HZ    
    %displacement_d = displacement_y(315,110,:); %go pro 73HZ  
    %displacement_d = displacement_y(282,110,:); %go pro 7HZ  
    %displacement_d = displacement_y(277,274,:); %go pro 3HZ
    %displacement_d = displacement_y(241,270,:); %go pro 2HZ 
    %displacement_d = displacement_y(160,86,:); %go pro 2HZ 200mvpp 
    %displacement_d = displacement_y(152,130,:);%go pro 2HZ 300mvpp
    %displacement_d = displacement_y(133,89,:);%go pro 2HZ 500mvpps
    %displacement_d = displacement_y(112,238,:);%go pro 2HZ 20mvpp
    displacement_dd= displacement_d(:);
    figure;plot(displacement_dd);
    yy= fft(displacement_dd,nF);
    magmag = abs(yy);
    nn= 0:nF-1;
    ff = nn * FrameRate/nF;
    figure;plot(ff(1:int16(nF/2)),magmag(1:int16(nF/2)));
    xlabel('Ƶ��/Hz');
    ylabel('���');grid on;
    figure;plot(displacement_dd);
    ylabel('λ���������أ�');
    xlabel('֡');
    figure;plot([1:nF]./FrameRate, displacement_dd);
    xlabel('ʱ�䣨�룩');
    ylabel('λ���������أ�');   
end


end