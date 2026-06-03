SECTIONS
{
    . = 0x80000000;

    .text : {
        . = ALIGN(4);
        *(.text)
    }

    .data : {
        . = ALIGN(4);
        *(.data)
    }

    .tags 0x0 : {
        . = ADDR(.data) - ADDR(.text);
        *(.tags)
    }
}