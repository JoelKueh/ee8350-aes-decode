cfg = coder.config('mex');

codegen -config cfg AES_Decrypt ...
    -args {zeros(4,4,'uint8'), zeros(4,4,11,'uint8')} ...
    -report

C = uint8(randi([0 255],4,4));
RoundKeys = uint8(randi([0 255],4,4,11));

P_matlab = AES_Decrypt(C,RoundKeys);
P_mex = AES_Decrypt_mex(C,RoundKeys);

assert(isequal(P_matlab,P_mex));

disp('MATLAB and generated MEX outputs match.');
