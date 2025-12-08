#include <stdint.h>

#ifndef TRUE
#define FALSE 0
#define TRUE (!FALSE)
#endif /* if TRUE not already defined */
#ifndef min /* if min macro not already defined */
#define min(a,b) ( (a)<(b) ? (a) : (b) )
#define max(a,b) ( (a)>(b) ? (a) : (b) )
#endif /* if min macro not already defined */
#define IDEAKEYSIZE 16
#define IDEABLOCKSIZE 8
#define IDEAROUNDS 8
#define IDEAKEYLEN (6*IDEAROUNDS+4)

typedef struct{
	int16_t ek[IDEAKEYLEN],dk[IDEAKEYLEN];
}idea_ctx;
/* End includes for IDEA.C */

#define low16(x) ((x) & 0xFFFF)

static uint16_t mul(register uint16_t a, register uint16_t b)
{
	register int32_t p;
	uint16_t ret;
	p = (int32_t)a * b;
	
	if (p) {
		b = low16(p);
		a = p>>16;
		return (b - a) + (b < a);
	} else if (a) {
		return 1-b;
	} else {
		return 1-a;
	}
} /* mul */

static uint16_t mulInv(uint16_t x)
{
	uint16_t t0, t1;
	uint16_t q, y;
	
	if (x <= 1)
		return x; /* 0 and 1 are self-inverse */
	
	t1 = 0x10001L / x; /* Since x >= 2, this fits into 16 bits */
	y = 0x10001L % x;
	
	if (y == 1)
		return low16(1-t1);
	
	t0 = 1;
	
	do {
		q = x / y;
		x = x % y;
		t0 += q * t1;
		if (x == 1)
			return t0;
		q = y / x;
		y = y % x;
		t1 += q * t0;
	} while (y != 1);

	return low16(1-t1);
} /* mukInv */

static void ideaExpandKey(int8_t const *userkey, int16_t *EK)
{
	int i,j;
	for (j=0; j<8; j++) {
		EK[j] = (userkey[0]<<8) + userkey[1];
		userkey += 2;
	}
	for (i=0; j < IDEAKEYLEN; j++) {
		i++;
		EK[i+7] = EK[i & 7] << 9 | EK[i+1 & 7] >> 7;
		EK += i & 8;
		i &= 7;
	}
} /* ideaExpandKey */

static void ideaInvertKey(int16_t const *EK, int16_t DK[IDEAKEYLEN])
{
	int i;
	uint16_t t1, t2, t3;
	int16_t temp[IDEAKEYLEN];
	int16_t *p = temp + IDEAKEYLEN;
	t1 = mulInv(*EK++);
	t2 = -*EK++;
	t3 = -*EK++;
	*--p = mulInv(*EK++);
	*--p = t3;
	*--p = t2;
	*--p = t1;
	for (i = 0; i < IDEAROUNDS-1; i++) {
		t1 = *EK++;
		*--p = *EK++;
		*--p = t1;
		t1 = mulInv(*EK++);
		t2 = -*EK++;
		t3 = -*EK++;
		*--p = mulInv(*EK++);
		*--p = t2;
		*--p = t3;
		*--p = t1;
	}
	t1 = *EK++;
	*--p = *EK++;
	*--p = t1;
	t1 = mulInv(*EK++);
	t2 = -*EK++;
	t3 = -*EK++;
	*--p = mulInv(*EK++);
	*--p = t3;
	*--p = t2;
	*--p = t1;
	/* Copy and destroy temp copy */
	memcpy(DK, temp, sizeof(temp));
	for(i=0;i<IDEAKEYLEN;i++)temp[i]=0;
} /* ideaInvertKey */

#define MUL(x,y) (x = mul(low16(x),y))

static void ideaCipher(int16_t *key, int8_t *inbuf, int8_t *outbuf)
{
	register uint16_t x1, x2, x3, x4, s2, s3;
	int16_t *in, *out;
	#ifndef SMALL_CACHE
	register uint16_t t16; /* Temporaries needed by MUL macro */
	register int32_t t32;
	#endif
	int r = IDEAROUNDS;
	in = (int16_t *)inbuf;
	x1 = *in++; x2 = *in++;
	x3 = *in++; x4 = *in;

	#ifndef HIGHFIRST
	x1 = (x1 >>8) | (x1<<8);
	x2 = (x2 >>8) | (x2<<8);
	x3 = (x3 >>8) | (x3<<8);
	x4 = (x4 >>8) | (x4<<8);
	#endif

	do {
		MUL(x1,*key++);
		x2 += *key++;
		x3 += *key++;
		MUL(x4, *key++);
		s3 = x3;
		x3 ^= x1;
		MUL(x3, *key++);
		s2 = x2;
		x2 ^= x4;
		x2 += x3;
		MUL(x2, *key++);
		x3 += x2;
		x1 ^= x2; x4 ^= x3;
		x2 ^= s3; x3 ^= s2;
	} while (--r);

	MUL(x1, *key++);
	x3 += *key++;
	x2 += *key++;
	MUL(x4, *key);
	out = (int16_t *)outbuf;

	#ifdef HIGHFIRST
	*out++ = x1;
	*out++ = x3;
	*out++ = x2;
	*out = x4;
	#else /* !HIGHFIRST */
	*out++ = (x1 >>8) | (x1<<8);
	*out++ = (x3 >>8) | (x3<<8);
	*out++ = (x2 >>8) | (x2<<8);
	*out = (x4 >>8) | (x4<<8);
	#endif
} /* ideaCipher */

void idea_key(unsigned char *key, idea_ctx *c){
	ideaExpandKey(key,c->ek);
	ideaInvertKey(c->ek,c->dk);
}

void idea_enc(idea_ctx *c, unsigned char *data, int blocks){
	int i;
	unsigned char *d = data;
	for(i=0;i<blocks;i++){
		ideaCipher(c->ek, d,d);
		d+=8;
	}
}

void idea_dec(idea_ctx *c, unsigned char *data, int blocks){
	int i;
	unsigned char *d = data;
	for(i=0;i<blocks;i++){
		ideaCipher(c->dk, d,d);
		d+=8;
	}
}

static char key[16] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef};
static char in[8] = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xe7};
int main(void)
{ 
	idea_ctx c;
	
	idea_key(&c,key);
	idea_enc(&c,in,1); /* encrypt */
	
	return 0; /* normal exit */
} /* main */