# multiplier implementation test #
This test tries to answer the question How multiplier implementations
scale in different technologies with different operand sizes.

## Implementation ##
The core consists of a fairly narrow interface (16 bit data words, but
can be changed by a single parameter) that connects to internal operand
and product ragisters.

The size of operands can be changed independently to allow testing of
multiplications with different operand widths.

The actual multiplication perform its operation on the values in the
operand registers and updates the internal product register.

This allows us to fairly well test the maximum clock frequency a design
with internal multiplications can achieve in a given technology.

Of course, the mux/demux logic will increase with the operand and product
widths. We try to sort out what logic is used for the API muxes and for
the multiplication. We assume that hard multipliers are used for the
multiplication.


Note that the actual multiplication is implemented as simple as:

    prod_new = opa_reg * opb_reg;

There is no explicit instantiation of hard macros, pipelines etc. This
is a single cycle multiplication operation. This leaves implementation
decisions to the tool.


## Results ##
### Altera Cyclone ###

Device: 5CGXFC9E6F31C7
Tool: Altera Quartus Prime 15.1

| Opa | Opb | DSP Blocks | 18x18 mult | 27x27 mult | ALMs | Regs | Fmax  |
|-----|-----|------------|------------|------------|------|------|-------|
|16   |16   |1           |1           |0           |12    |63    |310    |
|32   |32   |3           |3           |0           |49    |36    |217    |
|48   |48   |4           |0           |4           |95    |96    |214    |
|64   |64   |9           |1           |8           |190   |236   |70     |
|96   |96   |16          |1           |15          |503   |354   |52     |
|128  |128  |25          |0           |25          |1166  |512   |39     |
|144  |144  |43          |27          |16          |1703  |576   |34     |
|160  |160  |36          |0           |36          |1992  |640   |32     |
|192  |192  |75          |39          |36          |3428  |744   |27     |
|256  |256  |100         |1           |99          |6859  |998   |21     |
|     |     |            |            |            |      |      |       |
|16   |64   |1           |1           |0           |12    |0     |310    |
|32   |64   |3           |3           |0           |51    |36    |214    |
|48   |64   |4           |0           |4           |97    |96    |213    |
|96   |64   |15          |0           |15          |410   |295   |54     |
|128  |64   |24          |0           |24          |896   |374   |47     |
|144  |64   |38          |22          |16          |1207  |406   |42     |
|160  |64   |33          |0           |33          |1437  |438   |40     |
|192  |64   |55          |20          |35          |2235  |490   |36     |
|256  |64   |72          |0           |72          |4248  |617   |30     |
|     |     |            |            |            |      |      |       |


### Xilinx Spartan-6 ###

Device: xc6slx75-3csg484
Tool: ISE 14.7

| Opa | Opb | DSP48A1s    | LUTs   | Regs | Fmax |
|-----|-----|-------------|--------|------|------|
|16   |16   |             |        |      |      |
|32   |32   | 4           | 81     | 128  | 60   |
|48   |38   |             |        |      |      |
|64   |64   | 16          | 346    | 256  | 45   |
|96   |96   |             |        |      |      |
|128  |128  | 64          | 1369   | 514  | 33   |
|144  |144  |             |        |      |      |
|160  |160  |             |        |      |      |
|192  |192  |             |        |      |      |
|256  |256  |             |        |      |      |
|     |     |             |        |      |      |
|     |     |             |        |      |      |
|16   |64   |             |        |      |      |
|32   |64   |             |        |      |      |
|48   |64   |             |        |      |      |
|64   |64   |             |        |      |      |
|96   |64   |             |        |      |      |
|128  |64   |             |        |      |      |
|192  |64   |             |        |      |      |
|144  |64   |             |        |      |      |
|160  |64   |             |        |      |      |
|192  |64   |             |        |      |      |
|256  |64   |             |        |      |      |
|     |     |             |        |      |      |


### Xilinx Artix-7 ###

Device: xc7a200t-3fbg484
Tool: ISE 14.7

| Opa | Opb | DSP48E1s    | LUTs   | Regs | Fmax |
|-----|-----|-------------|--------|------|------|
|16   |16   |             |        |      |      |
|32   |32   | 3           | 66     | 128  | 122  |
|48   |38   |             |        |      |      |
|64   |64   | 12          | 339    | 257  | 85   |
|96   |96   |             |        |      |      |
|128  |128  | 56          | 1388   | 514  | 62   |
|144  |144  |             |        |      |      |
|160  |160  |             |        |      |      |
|192  |192  |             |        |      |      |
|256  |256  | 231         | 4853   | 1029 | 40   |
|     |     |             |        |      |      |
|     |     |             |        |      |      |
|16   |64   |             |        |      |      |
|32   |64   |             |        |      |      |
|48   |64   |             |        |      |      |
|64   |64   |             |        |      |      |
|96   |64   |             |        |      |      |
|128  |64   |             |        |      |      |
|192  |64   |             |        |      |      |
|144  |64   |             |        |      |      |
|160  |64   |             |        |      |      |
|192  |64   |             |        |      |      |
|256  |64   |             |        |      |      |
|     |     |             |        |      |      |
