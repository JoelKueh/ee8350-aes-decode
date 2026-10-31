
function output = gf_inv(input)
	% Multiplicative 8-bit inverse in the Galois field
	% Input:  8-bit byte
	% Output: 8-bit byte

	if input == 0
		output = 0;
    else
		output = uint8(inv(gf(double(input), 8, 283)));
    end
end

function output = gf_mul(a, b)
	% 8-bit Multiplication in the Galois field
	% Input:  8-bit byte
	% Output: 8-bit byte

	a_gf = gf(double(a), 8, 283);
	b_gf = gf(double(b), 8, 283);
	result = a_gf .* b_gf;
	product = uint8(result.x);
end

function output = SBox(input)
	% AES S-box transformation
	% Input:  8-bit byte
	% Output: 8-bit substituted byte

	% Affine transformation matrix
	A = uint8([
		1 0 0 0 1 1 1 1;
        1 1 0 0 0 1 1 1;
        1 1 1 0 0 0 1 1;
        1 1 1 1 0 0 0 1;
        1 1 1 1 1 0 0 0;
        0 1 1 1 1 1 0 0;
        0 0 1 1 1 1 1 0;
        0 0 0 1 1 1 1 1
	])

	% Constant vector
    C = uint8([1; 1; 0; 0; 0; 1; 1; 0]);

	% Compute the inverse of the byte in the Galois field.
	a = input;
	b = gf_inv(input);

	% Convert "b" into a bit vector
	bits = zeros(8, 1, 'uint8');
	for k = 1:8
		bits(k) = bitget(b, 9-k);
	end

	% Affine transformation over GF(2)
	result = zeros(8, 1, 'uint8');
	for k = 1:8
		result(k) = mod(sum(A(k,:)'.*bits), 2);
	end
	result = bitxor(result, C);

	% Return the result
	output = uint8(0);
	for k = 1:8
		output = bitor(value, bitshift(result(k),8-k));
	end
end
