# FPGA MISC IP

Miscellaneous IPs for FPGA project

## Arbitration

Arbitration related IPs

| IP Name                      | Files          | Description                                   |
| :---------------------------- | -------------- | --------------------------------------------- |
| bitscan                      | bitscan.sv     | Simple fixed priority arbitration<sup>1</sup> |
| arbiter                      | arbiter.sv     | Simple fixed priority arbitration<sup>2</sup> |
| round-robin aribiter         | rr_arbiter.sv  | Round robin arbiter                           |
| weighted round-robin aribter | wrr_arbiter.sv | Weighted Round robin arbiter                  |


1. The lowest req has the highest priority
2. The highest priority position can be adjusted