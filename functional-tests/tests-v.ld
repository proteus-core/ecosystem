/* Linker script for the virtual memory test environment (riscv-tests env/v), based on
 * riscv-tests/env/p/link.ld. All sections are placed explicitly (the compiled C environment also
 * produces rodata and small-data sections), and .bss is delimited by __bss_start/_end so the
 * boot code can zero it: the simulator does not zero memory, and .bss holds the page tables. */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;
  .text.init : { *(.text.init) }
  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }
  . = ALIGN(0x1000);
  .text : { *(.text) *(.text.*) }
  . = ALIGN(0x1000);
  .rodata : { *(.rodata) *(.rodata.*) *(.srodata) *(.srodata.*) }
  /* The final padding keeps the flat binary a multiple of a word, as the simulator requires. */
  .data : { *(.data) *(.data.*) *(.sdata) *(.sdata.*) . = ALIGN(4); }
  . = ALIGN(8);
  __bss_start = .;
  .bss : { *(.sbss) *(.sbss.*) *(.bss) *(.bss.*) *(COMMON) }
  . = ALIGN(8);
  _end = .;
}
