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


## Results ##
### Altera Cyclone ###

Device: 5CGXFC9E6F31C7

| Opa | Opb | DSP Blocks | 18x18 mult | 27x27 mult | ALMs | Regs | Fmax|
|-----|-----|------------|------------|------------|------|------|-----|
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|256  |256  | 100        | 1          | 99         | 6963 | 1024 |22.5 |
|     |     |            |            |            |      |      |     |
|     |     |            |            |            |      |      |     |
|-----|-----|------------|------------|------------|------|------|-----|
