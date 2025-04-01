/* RV32I Linker Script for system with separate IMEM and DMEM */
/* Each memory is 4095 words (16380 bytes) */

MEMORY
{
    imem (rx)  : ORIGIN = 0x00000000, LENGTH = 16380
    dmem (rw)  : ORIGIN = 0x00010000, LENGTH = 16380
}

SECTIONS
{
    .text : {
        *(.text)
        *(.text.*)
    } > imem

    .data : {
        *(.data)
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
    } > dmem

    .bss : {
        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
    } > dmem
}