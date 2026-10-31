#set page(
  width: 8.5in,
  height: 11in,
  margin: 1in,
)

#show raw: set text(size: 7pt)
#show raw.where(block: true): it => block(
  fill: luma(240),
  inset: 4pt,
  radius: 4pt,
  width: 100%,
  it
)

#set document(title: "EE8350 - AES Algorithm", author: ("Joel Kuehne <kuehn348@umn.edu>"))
#title()
_Joel Kuehne \<kuehn348\@umn.edu\>_

= Overview

The encryption module is based on the state matrix $S$ and round key $K_r$:

#grid(
  columns:(1fr, 1fr),
  [$ S = mat(
    delim: "[",
    s_(0,0), s_(0,1), s_(0,2), s_(0,3);
    s_(1,0), s_(1,1), s_(1,2), s_(1,3);
    s_(2,0), s_(2,1), s_(2,2), s_(2,3);
    s_(3,0), s_(3,1), s_(3,2), s_(3,3);
  ) $],
  [$ K_r = mat(
    delim: "[",
    k_(0,0), k_(0,1), k_(0,2), k_(0,3);
    k_(1,0), k_(1,1), k_(1,2), k_(1,3);
    k_(2,0), k_(2,1), k_(2,2), k_(2,3);
    k_(3,0), k_(3,1), k_(3,2), k_(3,3);
  ) $],
)

Encryption goes through various phases of SubBytes, ShiftRows, MixColumns, and AddRoundKey

== Sub-Bytes

Sub bytes is based on the S-box transform which consists of computing the multiplicative inverse
$b = a^(-1) = a^254$ and then performing an affine transformation $b' = A b xor c$. The matrix
A is as follows:

#grid(
  columns: (1fr, 1fr),
  [$ A = mat(
      delim: "[",
      1, 0, 0, 0, 1, 1, 1, 1;
      1, 1, 0, 0, 0, 1, 1, 1;
      1, 1, 1, 0, 0, 0, 1, 1;
      1, 1, 1, 1, 0, 0, 0, 1;
      1, 1, 1, 1, 1, 0, 0, 0;
      0, 1, 1, 1, 1, 1, 0, 0;
      0, 0, 1, 1, 1, 1, 1, 0;
      0, 0, 0, 1, 1, 1, 1, 1;
    ) $],
  [$ C = mat(
      delim: "[",
      1;
      1;
      0;
      0;
      0;
      1;
      1;
      0;
    ) $],
)

= Encrypt

= Decrypt

= Key Expand
