Loading and Display image::
imgOrg= double(imread('D:\Quantum_third_paper\Paper\Code\code\Encryption_code\Image\Encr_image\check_folderdata\cecum_one.png'));
[row,column] = size(imgOrg);
n = 400000;n2=64;

% Generate chaotic sequence
[cx, cy, ~] = mHNN(5000);   % discard handled internally

% Ensure equal length
seq_length = min(length(cx), length(cy));

k = 3;
discard = 5000;
required_length = 512*512;

needed = discard + required_length;

% Preallocate P
num_steps = floor(seq_length / k);
P = zeros(1, 2*num_steps);

idx = 1;
for i = k:k:seq_length
    P(idx)   = cx(i);
    P(idx+1) = cy(i);
    idx = idx + 2;
end

% Trim safely
if length(P) < needed
    error('Not enough chaotic samples. Increase deltat in mHNN.');
end

P_seq = P(discard+1 : discard+required_length);
P_seq = abs(P_seq);

% Map to [0,255]
L = mod(floor(1e15 * P_seq), 256);
Img2 = reshape(uint8(L), [512,512]);

%% Generalized Quantum Arnold Scrambling::
[rows, columns, numberOfColorChannels] = size(imgOrg);
maxAllowableSize = 1024;
iteration = 1;
% Initialize image.
oldScrambledImage = imgOrg;
% The number of iterations needed to restore the image can be shown never to exceed 3N.
Nz = rows;
a=11;
d=19;
while iteration <= 3 * Nz
	% Scramble the image based on the old image.
	for row = 1 : rows % y
		for cols = 1 : columns % x
			c = mod(cols + (a*row), Nz) + 1; % x coordinate
			r = mod((d*cols) +((a*d+1)*row), Nz) + 1; % y coordinate
			% Move the pixel.  Note indexes are (row, column) = (y, x) NOT (x, y)!
			currentScrambledImage(row, cols, :) = oldScrambledImage(r, c, :);
		end
	end
	% Make the current image the prior/old one so we'll operate on that the next iteration.
	oldScrambledImage = currentScrambledImage;
	% Update the iteration counter.
	iteration = iteration+1;
    if(iteration==59) 
        break;
    end
end
Arnold_scr= currentScrambledImage;

%% Magic cube diffusion :::
magic_cube = magic_cube(n2);
mod_mc = mod(magic_cube,256);
pre_diffuse = quantumXORSimulation_enc(mod_mc,Arnold_scr); 
pre_diff = uint8(pre_diffuse);
%imwrite(pre_diff,'D:\Quantum_third_paper\Paper\Code\code\Encryption_code\Image\Encr_image\check_folderdata\barbara_pre_enc.png');

%% Chaotic diffusion :::
Enc_new = quantumXORSimulation_enc(Img2, pre_diffuse);
Enc_nEw = UV_permutation(Enc_new);
Enc_img = uint8(Enc_nEw);
imwrite(Enc_img,'D:\Quantum_third_paper\Paper\Code\code\Encryption_code\Image\Encr_image\check_folderdata\cecum_one_2.2.01_enc.png');
