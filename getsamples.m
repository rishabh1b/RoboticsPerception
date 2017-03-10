
% color param 1 - Red, 2 - Yellow, 3 - Green
% if color == 1
% filename_base = '../Images/TrainingSet/CroppedBuoys/R_';
% elseif color == 2
% filename_base = '../Images/TrainingSet/CroppedBuoys/Y_';
% else
% filename_base = '../Images/TrainingSet/CroppedBuoys/G_';
% end

Samples = [];
imagepath = '../Images/TrainingSet/Frames';
count = 1;
%Samples = [];
for k=1:250
    % Load image
    filename = sprintf('Frame %d.jpg', k);
    fullfilename = fullfile(imagepath,filename);
    if ~exist(fullfilename, 'file')
        continue;
    end
    I = imread(fullfilename);
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);   
    % Collect samples 
    disp('');
    disp('INTRUCTION: Click along the boundary of the ball. Double-click when you get back to the initial point.')
    disp('INTRUCTION: You can maximize the window size of the figure for precise clicks.')
    figure(1), 
    mask = roipoly(I); 
    figure(2), imshow(mask); title('Mask');
    sample_ind = find(mask > 0);

    R = R(sample_ind);
    G = G(sample_ind);
    B = B(sample_ind);
    Samples = [Samples; [R G B]];
    disp('INTRUCTION: Press any key to continue. (Ctrl+c to exit)')
    pause
    count = count + 1;
end

