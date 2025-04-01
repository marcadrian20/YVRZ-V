MEMORY
{
    IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 4096   /* IMEM 1024 words */
    DMEM (rw) : ORIGIN = 0x80000000, LENGTH = 4096   /* DMEM 1024 words */
}

SECTIONS
{
    .text : {
        *(.text)
    } > IMEM

    .data : {
        *(.data)
    } > DMEM
}
