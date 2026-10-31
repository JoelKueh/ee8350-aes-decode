function S_out = MixColumns(S_in)
	% AES MixColumns transofrmation
	% Input:  4x4 state matrix
	% Output: 4x4 transformed state matrix

	% Column mixing matrix
	M = uint8([
		2 3 1 1;
		1 2 3 1;
		1 1 2 3;
		3 1 1 2
	])

	% Multiply each column in S by matrix M
	S_out = zeros(4, 4, 'uint8');
	for j = 1:4
		column = S_in(:,j);
		for k = 1:4
			value = bitxor(value, gf_multiply(M(i,k), column(k)));
		end
		S_out(i,j) = value;
	end
end

function S_out = ShiftRows(S_in)
	% AES ShiftRows transformation
	% Input:  4x4 state matrix
	% Output: 4x4 shifted state matrix

	S_out = zeros(4, 4, 'uint8');
	for i = 1:4
		S_out(i,:) = circshift(S_in(i,:), -(i-1));
	end
end

function S_out = AddRoundKey(S_in, K_r)
	% AES AddRoundKey transformation
	% Input:  4x4 state matrix and 4x4 round key matrix
	% Output: 4x4 XOR result
	S_out = bitxor(S_in, K_r);
end

function S_out = AES_DecryptRound(S_in, K_r)
	% AES Decryption Round
	% Input:  4x4 state matrix and 4x4 round key matrix
	% Output: 4x4 decrypted state

	S = InvShiftRows(S_in);
	S = InvSubBytes(S_in);
	S = AddRoundKey(S, K_r);
	S = InvMixColumns(S);

	S_out = S;
end

function P = AES_Decrypt(C, RoundKeys)
	% AES Decryption Round
	% Input:  4x4 ciphertext matrix and list of 4x4 round key matrcies
	% Output: 4x4 decrypted plaintext

    % Initial AddRoundKey using K10
    S = AddRoundKey(C, RoundKeys(:,:,11));

    % Main decryption rounds: K9 down to K1
    for r = 10:-1:2
        S = InvShiftRows(S);
        S = InvSubBytes(S);
        S = AddRoundKey(S, RoundKeys(:,:,r));
        S = InvMixColumns(S);
    end

    % Final decryption round using K0
    S = InvShiftRows(S);
    S = InvSubBytes(S);
    S = AddRoundKey(S, RoundKeys(:,:,1));

    P = S;
end
