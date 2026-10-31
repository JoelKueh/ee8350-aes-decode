
# Design

## Parameterizations

- Must test the design on keylen 128, 192, and 256.
    - This is not a generate parameter, but you cannot change it at runtime.

## Decryption Engine

### IO

- Ready/valid interface for input ciphertext
- Valid interface for output plaintext
- X Propagation on the ready/valid interface.
- Backoff with the valid signal? Can valid be dropped arbitrarily?

### Internals

- Registers `[0:127] State`, `[14:0] decrypt_state`, and `pt_vld_reg`
- Each round consumes one round key from the key schedule buffer
    - 11 rounds for 128 bit, 13 for 192, 15 for 256
- Waits for valid ciphertext and key schedule.
    - This implies that KeyExpand computes the entire key schedule before decrypt begins.

### Submodules

- `InvShiftRows`
    - Undoes the shift-rows operation from the AES enctyption step.
    - This is just a byte-wise shift. Corners aren't too important here.
    - Fully combinational.
- `InvSubBytes`
    - Undoes the byte substitution affine transformation from the AES enctyprion step.
    - Make sure that you hit all of the bins in the SRAM (`InvSbox`)
    - Also instantiates MUXF7 and MUXF8 (just how you build 6-input logic function with LUT5s).
    - Fully combinational.
- `InvAddRoundKey`
    - Just xor with the round key based on din0 and din1.
    - Fully combinationa.
- `InvMixColumns`
    - Performs the inverse of the column mixing by a Galois field multiplication.
    - TODO: RESEARCH ME MORE FOR THE GALOIS FIELD DEAL
    - Instantiates multiple gfmul functions.
        - TODO: Look at edge cases for Galois field multiplication.

## Key Expander

### IO

- Ready/valid interface for input keytext
- Output to key schedule buffer

### Submodules

## Key Schedule Buffer

### IO

- `[0:127] rkey_in` - Round key from the key expander with `rkey_vlk_in`
- `[0:127] rkey_out` - Round key from the key expander with `rkey_vlk_out`

### Internals

- Implemented as a block RAM (implemented as LIFO)
- Individual read and write pointers (write up, read down)
