PHDRS
{
	text PT_LOAD;
	data PT_LOAD;
}

SECTIONS
{
	. = ALIGN(4096);
	.text : {
		*(.text*)
		*(.rodata*)
	} : text

	. = ALIGN(4096);
	.data : {
		*(.data*)
	} : data

	/DISCARD/ : {
		*(.comment*)
		*(.note*)
		*(.debug*)
		*(.eh_frame*)
	}
}
