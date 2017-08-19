function Samples = createCroppedBuoys(color)
% color param 1 - Red, 2 - Yellow, 3 - Green
if color == 1
    filename_base = '../Images/TrainingSet/CroppedBuoys/R_';
elseif color == 2
    filename_base = '../Images/TrainingSet/CroppedBuoys/Y_';
else
    filename_base = '../Images/TrainingSet/CroppedBuoys/G_';
end
        
imagepath = '../Images/TrainingSet/Frames';
count = 1;
Samples = [];
% Change it here 91:200
for k=1:43
    % Load image
    filename = sprintf('Frame %d.jpg', k);
    fullfilename = fullfile(imagepath,filename);
    if ~exist(fullfilename, 'file')
        continue;
    end
    I = imread(fullfilename);
    %I = im2double(I);   
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);
    R = medfilt2(R,[3 3]);
    G = medfilt2(G,[3 3]);
    B = medfilt2(B,[3 3]);
    I_cleaned = I;
    I_cleaned(:,:,1) = R;
    I_cleaned(:,:,2) = G;
    I_cleaned(:,:,3) = B;
    % Collect samples 
    disp('');
    disp('INTRUCTION: Click along the boundary of the ball. Double-click when you get back to the initial point.')
    disp('INTRUCTION: You can maximize the window size of the figure for precise clicks.')
    figure(1), 
    mask = roipoly(I_cleaned); 
    cropped_buoy_r = double(I_cleaned(:,:,1)) .* mask;
    cropped_buoy_g = double(I_cleaned(:,:,2)) .* mask;
    cropped_buoy_b = double(I_cleaned(:,:,3)) .* mask;
    cropped_buoy = I_cleaned;
    cropped_buoy(:,:,1) = cropped_buoy_r;
    cropped_buoy(:,:,2) = cropped_buoy_g;
    cropped_buoy(:,:,3) = cropped_buoy_b;
    figure(2), imshow(mask); title('Mask');
    filename_new =sprintf('00%d.jpg',count);
    fullfilename = strcat(filename_base, filename_new);
    imwrite(cropped_buoy, fullfilename,'jpg');
    count = count + 1;
    
    sample_ind = find(mask > 0);

    R = R(sample_ind);
    G = G(sample_ind);
    B = B(sample_ind);
    Samples = [Samples; [R G B]];
end
end
    
    