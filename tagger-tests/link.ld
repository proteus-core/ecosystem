SECTIONS
{
    . = 0x80000000;

    .text : { *(.text) }

    . = 0x80000200;

    .data : { *(.data) }

    .tags 0x0 : {
        . = ADDR(.data) - ADDR(.text);
        *(.tags)
    }
}
