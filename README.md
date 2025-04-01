
# YVRZ-V, A simplistic RISC-V CORE

YVRZ-V is a [RISC-V](https://riscv.org/) core implementing the RV32IM_ZICSR ISA for my. It boasts a 5 stage classic RISC pipeline with in-order execution, and is supposed to be a softcore for my FPGA, Tang Nano 20K.

## Intended use

My aim for this project is to implement a highly configurable, high performance RV32 core capable of being scalable and running a modified version of Linux.  
The current implementation has an Fmax of 70Mhz on the Tang Nano 20K. Optimizations soon.

## FUTURE GOALS & PLANS
- [x] Working RV32I Base ISA
- [x] 5 Stage Pipeline Working
- [x] Pipeline Hazard Handling
- [x] RV32 Zizcsr Extension Implemented
- [x] Minimal Set of Machine mode CSRs
- [x] Exception Handling(partial)
- [x] RV32M (Multiply/Divide) Extension
- [ ] RV32C (Compressed ISA)
- [ ] Zifencei Extension Supported
- [ ] RV32 Zicntr Extension
- [ ] Branch Prediction
- [ ] RV32A Extension
- [ ] Cache Memory implementation
- [ ] Working MMU
- [ ] Linux Support
- [ ] RV32F/D FP Extensions
- [ ] Broader Configurability for the supported ISA ( RV32I, RV32IM, RV32IMA, RV32IMAC, RV32GC )
- [ ] Out of order execution and 64 Bits
