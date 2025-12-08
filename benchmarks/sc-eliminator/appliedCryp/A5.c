typedef struct {
	unsigned long r1,r2,r3;
} a5_ctx;

static int threshold(r1, r2, r3)
unsigned int r1;
unsigned int r2;
unsigned int r3;
{
	int total;
	total = (((r1 >> 9) & 0x1) == 1) +
	(((r2 >> 11) & 0x1) == 1) +
	(((r3 >> 11) & 0x1) == 1);
	if (total > 1)
	return (0);
	else
	return (1);
}

unsigned long clock_r1(ctl, r1)
int ctl;
unsigned long r1;
{
	unsigned long feedback;
	ctl ^= ((r1 >> 9) & 0x1);
	if (ctl)
	{
		feedback = (r1 >> 18) ^ (r1 >> 17) ^ (r1 >> 16) ^ (r1 >> 13);
		r1 = (r1 << 1) & 0x7ffff;
		if (feedback & 0x01)
			r1 ^= 0x01;
	}
	return (r1);
}

unsigned long clock_r2(ctl, r2)
int ctl;
unsigned long r2;
{
	unsigned long feedback;
	ctl ^= ((r2 >> 11) & 0x1);
	if (ctl)
	{
		feedback = (r2 >> 21) ^ (r2 >> 20) ^ (r2 >> 16) ^ (r2 >> 12);
		r2 = (r2 << 1) & 0x3fffff;
		if (feedback & 0x01)
			r2 ^= 0x01;
	}
	return (r2);
}

unsigned long clock_r3(ctl, r3)
int ctl;
unsigned long r3;
{
	unsigned long feedback;
	ctl ^= ((r3 >> 11) & 0x1);
	if (ctl)
	{
		feedback = (r3 >> 22) ^ (r3 >> 21) ^ (r3 >> 18) ^ (r3 >> 17);
		r3 = (r3 << 1) & 0x7fffff;
		if (feedback & 0x01)
			r3 ^= 0x01;
	}
	return (r3);
}

int keystream(key, frame, alice, bob)
unsigned char *key; /* 64 bit session key */
unsigned long frame; /* 22 bit frame sequence number */
unsigned char *alice; /* 114 bit Alice to Bob key stream */
unsigned char *bob; /* 114 bit Bob to Alice key stream */
{
	unsigned long r1; /* 19 bit shift register */
	unsigned long r2; /* 22 bit shift register */
	unsigned long r3; /* 23 bit shift register */
	int i; /* counter for loops */
	int clock_ctl; /* xored with clock enable on each shift register */
	unsigned char *ptr; /* current position in keystream */
	unsigned char byte; /* byte of keystream being assembled */
	unsigned int bits; /* number of bits of keystream in byte */
	unsigned int bit; /* bit output from keystream generator */
	/* Initialise shift registers from session key */
	r1 = (key[0] | (key[1] << 8) | (key[2] << 16) ) & 0x7ffff;
	r2 = ((key[2] >> 3) | (key[3] << 5) | (key[4] << 13) | (key[5] << 21)) &
	0x3fffff;
	r3 = ((key[5] >> 1) | (key[6] << 7) | (key[7] << 15) ) & 0x7fffff;
	/* Merge frame sequence number into shift register state, by xor’ing it
	* into the feedback path
	*/
	for (i=0;i<22;i++)
	{
		clock_ctl = threshold(r1, r2, r2);
		r1 = clock_r1(clock_ctl, r1);
		r2 = clock_r2(clock_ctl, r2);
		r3 = clock_r3(clock_ctl, r3);
		if (frame & 1)
		{
			r1 ^= 1;
			r2 ^= 1;
			r3 ^= 1;
		}
		frame = frame >> 1;
	}
	/* Run shift registers for 100 clock ticks to allow frame number to
	* be diffused into all the bits of the shift registers
	*/
	for (i=0;i<100;i++)
	{
		clock_ctl = threshold(r1, r2, r2);
		r1 = clock_r1(clock_ctl, r1);
		r2 = clock_r2(clock_ctl, r2);
		r3 = clock_r3(clock_ctl, r3);
	}
	/* Produce 114 bits of Alice->Bob key stream */
	ptr = alice;
	bits = 0;
	byte = 0;
	for (i=0;i<114;i++)
	{
		clock_ctl = threshold(r1, r2, r2);
		r1 = clock_r1(clock_ctl, r1);
		r2 = clock_r2(clock_ctl, r2);
		r3 = clock_r3(clock_ctl, r3);
		bit = ((r1 >> 18) ^ (r2 >> 21) ^ (r3 >> 22)) & 0x01;
		byte = (byte << 1) | bit;
		bits++;
		if (bits == 8)
		{
			*ptr = byte;
			ptr++;
			bits = 0;
			byte = 0;
		}
	}
	if (bits)
		*ptr = byte;
	/* Run shift registers for another 100 bits to hide relationship between
	* Alice->Bob key stream and Bob->Alice key stream.
	*/
	for (i=0;i<100;i++)
	{
		clock_ctl = threshold(r1, r2, r2);
		r1 = clock_r1(clock_ctl, r1);
		r2 = clock_r2(clock_ctl, r2);
		r3 = clock_r3(clock_ctl, r3);
	}
	/* Produce 114 bits of Bob->Alice key stream */
	ptr = bob;
	bits = 0;
	byte = 0;
	for (i=0;i<114;i++)
	{
		clock_ctl = threshold(r1, r2, r2);
		r1 = clock_r1(clock_ctl, r1);
		r2 = clock_r2(clock_ctl, r2);
		r3 = clock_r3(clock_ctl, r3);
		bit = ((r1 >> 18) ^ (r2 >> 21) ^ (r3 >> 22)) & 0x01;
		byte = (byte << 1) | bit;
		bits++;
		if (bits == 8)
		{
			*ptr = byte;
			ptr++;
			bits = 0;
			byte = 0;
		}
	}
	if (bits)
		*ptr = byte;
	return (0);
}						
void a5_key(a5_ctx *c, char *k){
	c->r1 = k[0]<<11|k[1]<<3 | k[2]>>5 ; /* 19 */
	c->r2 = k[2]<<17|k[3]<<9 | k[4]<<1 | k[5]>>7; /* 22 */
	c->r3 = k[5]<<15|k[6]<<8 | k[7] ; /* 23 */
}
/* Step one bit in A5, return 0 or 1 as output bit. */
int a5_step(a5_ctx *c){
	int control;
	control = threshold(c->r1,c->r2,c->r3);
	c->r1 = clock_r1(control,c->r1);
	c->r2 = clock_r2(control,c->r2);
	c->r3 = clock_r3(control,c->r3);
	return( (c->r1^c->r2^c->r3)&1);
}
/* Encrypts a buffer of len bytes. */
void a5_encrypt(a5_ctx *c, char *data, int len){
	int i,j;
	char t;
	for(i=0;i<len;i++){
		for(j=0;j<8;j++) 
			t = t<<1 | a5_step(c);
		data[i]^=t;
	}
}
void a5_decrypt(a5_ctx *c, char *data, int len){
	a5_encrypt(c,data,len);
}
void main(void){
	a5_ctx c;
	char data[100];
	char key[] = {1,2,3,4,5,6,7,8};
	int i,flag;

	for(i=0;i<100;i++) 
		data[i] = i;

	a5_key(&c,key);
	a5_encrypt(&c,data,100);
	a5_key(&c,key);
	a5_decrypt(&c,data,1);
	a5_decrypt(&c,data+1,99);
	flag = 0;
	for(i=0;i<100;i++) 
		if(data[i]!=i)flag = 1;
	if(flag)printf("Decrypt failed\n"); 
	else printf("Decrypt succeeded\n");
}