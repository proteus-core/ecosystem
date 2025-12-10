// #include <sys/mman.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#ifdef _MSC_VER
#include <intrin.h> /* for rdtscp and clflush */
#pragma optimize("gt", on)
#else
// #include <x86intrin.h> /* for rdtscp and clflush */
#include "performance.h"
#endif

#include "Hacl_Chacha20.h"

#include "sglib.h"

/*
    This file provides the synthetic benchmark for SpectreGuard. It
    splits execution into two sections.

    Work
        This section performs an algorithm that is moderately dependent
        on speculative execution for performance. We could have made
        this even more performance dependent on speculation, but the
        intention was to create something significantly noticeable during
        testing, not a worse-case scenario.

    Encrypt
        This section simply performs the AES encryption algorithm. It
        contains minimal conditional branches, so it does not rely
        heavily on speculative execution for performance.

    The argument passed in will change the percent of time the program
    spends in the Encrypt section.
        ex: ./benchmark 10
            This should spend 10% of execution time in the Encrypt
            section when running in native -no Spectre protection-
            mode.

    The intention of the benchmark is:
    1)  To show the effect of marking data in non-critical, and
        non-reliant on speculation for performance, sections as
        non-speculative.
    2)  To show how to use the current programmer interfaces to use
        SpectreGuard.

    The intention is not:
    1)  To show how to create a secure application with regards to
        non-speculative attacks.
*/

#define MESSAGE_LEN 16 // Same as AES_encrypt()
#define MACBYTES 16
#define NONCEBYTES 12
#define KEYBYTES 32
#define CIPHERTEXT_LEN (MESSAGE_LEN)

struct bounded_array
{
    volatile unsigned int length; // length of array
    char *data;                   // pointer to array
};

__attribute__((section(".public"))) static uint8_t nonce[NONCEBYTES] = {
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05,
    0x06, 0x07, 0x08, 0x09, 0x10, 0x11};

/* The data that we will perform work on, and then encrypt. */
char plain_text_orig_data[] = "oDFV2O1aP136YnmEbhZJLMizLukPQF3Ir6kzrYGMOm9M822cFsuLftYMulqTzNwmhvoTkUr7mFwm0r8w2t51ccg2qgRhdWrI5ldwsnRZXoXoogHLUYbNMQPn8Pc4SPVRckc1XtQVAoIFSaBrOX3WBl27GZQfqTUROjIrSwlErkwevuIXQfby8WtMRbw8f0RrvJCytHaJfWyD9rC0VMCMFl4gZstTw0WxxBvAEQEhtBdJkJKOEw1xUo9MyiLj77QD14XSzx2p9wFEpPTbP96X69Mz628IaGgmGbKO06uFesKISWF4qltlIe74Jm00kZpeXCx7uZQ02VGQ3vLPSanJUBv0FYVMbl2VoARBo1D0IAwYvk35fLR4qXUinVgoL8NxhaaNi6Al6zww23kBSlzXZimSkkG0V9mmjArlOyE5N6DR0C2n9R6jEtsUQejADev21cWPE742mQc8q50u8B5X5QWYiPsZVz4VlMnC0aNDRH7gQMz4gCfuEfd14sm4Kl7TdNGHw0VzrxaFARKR1T6kih3RgeBCQGYvIJiP9oWQQvXf0WkoL289SrwOYA5lj8ArAH3ftM15K4ih3UrXVfZHvE031bqwTueRZQPTGp7psY5jBNGs5G8bUROxYtUwS63lkJTj7IuvIUaTIgJvxQHrMUSnN86aG6uMUlNZCFF8lJamsDtLAU5WlXs5aWS2ckwmo0BECJxkZwg8FiPmY2A4EPrmcKnLIj0DHHmbelAV57KmPmRk9q3LeFZeNJvranJU3FDioc5rSAxT16M5rDlZlxdLANByfz6jaaVa3CcqTGFfS5F0ZHcZlDCEy4fzLQtwDACfQAoiUAOvmfI01q89U1fNqIBcbuXi8AZwcos19bJCpOZfaTkBEldeC2EmTLVLZZ6XhZWBJf6iKL2sJriGPfJY6NT67LOit0cvPs8N8o2v9XP7HSRw7RPm5h3GSeVGbcftzQ4VgEefEIlu4QWgoMqRsnASzEhAS0TPk4AUC63ieNwRjwBerK7PA60Oq9tyRfUfqWXlvCfqV8JOUDo9hzxxopC4Bk0HtjPZ21KyPqQD2AFGVSWcucK4ZL3eYed1R9yG2XWDUfpT5Z8pFNX59X9SAlyjob28IHayBhVmVlmJDFTVS7vcsVqACSetqJCexJ8kkBO1eCI1x67LjztTT2N7o4gmb8zunYutnHpIO9OFdVuqv1taRrcCFBhNrhpeBME7n94QQnTK2zJ7grqhEm1ZXLkO235sCIDXnSmkiCsvvNiYEfVyksi3bjZFlNLIgLorrdR3ykjFWAyJxkotmGCIxLQ1ykGJU8wDLoTnKD21z6IHm9YNl3HNLPEHIzOMdJuYwazUb1ih00RNsr9OYcSPxy7s0xrpt3sJZ44DWtGYwN84OY5eCHhyP2UdiV4Otlqtbj3seC2yCJ9hznVO67yNHsp07vQgIUXGZSbX5zzTRLrkHrDAVexrKElHrafqRgWwnzibtlvo8cd6jknGbIzXKypEAREYrCzLBusH3A7A8xMc6Gox4JEJxpZ22Ui5MuFA5fQt9xNwKSJmsZPENe55wjcLg58MWZey8cbiA3LpqK2lPRC7mvBpVvIb0dxD";

struct bounded_array plain_text_orig = {
    1600,
    plain_text_orig_data};

__attribute__((section("secret"))) char plain_in_data[8192];
struct bounded_array plain_in = {
    8192,
    plain_in_data};


/*  The value of the secret key stored in the binary. We do not suggest
    storing secrets in binaries, this is just used to show how to mark
    data as non-speculative through the Linux loader. I.E. This data
    will be non-speculative at load time.
*/
__attribute__((section("secret"))) static uint8_t key[KEYBYTES] = {
    0x85, 0xd6, 0xbe, 0x78, 0x57, 0x55, 0x6d, 0x33,
    0x7f, 0x44, 0x52, 0xfe, 0x42, 0xd5, 0x06, 0xa8,
    0x01, 0x03, 0x80, 0x8a, 0xfb, 0x0d, 0xb2, 0xfd,
    0x4a, 0xbf, 0xf6, 0xaf, 0x41, 0x49, 0xf5, 0x1b};

extern char *__start_secret;
extern char *__stop_secret;

#define mode 0
#define input "75"

int main(int argc, char **argv)
{
    register uint64_t time1, time2, time_work, time_encrypt;
    int i, j, k;
    int work_loop, crypto_loop;

    printf("Mode: %d, input: %s\n", mode, input);

    // set up secret region  boundaries in CSRs
    switch (mode)
    {
    case 0: // baseline
        break;
    case 1: // precise boundaries
        __asm__ __volatile__(
            "csrrw zero, 0x707, %0\n\t"
            "csrrw zero, 0x708, %1\n\t"
            :
            : "r"(&__start_secret), "r"(&__stop_secret)
            : "t0");
        break;
    case 2: // all secrets
        uint32_t bottom = 0;
        uint32_t top = 0xFFFFFFFF;

        __asm__ __volatile__(
            "csrrw zero, 0x707, %0\n\t"
            "csrrw zero, 0x708, %1\n\t"
            :
            : "r"(bottom), "r"(top)
            : "t0");
        break;
    }

    __attribute__((section("secret"))) static char cipher_buf[4096];

    if (!strcmp(input, "75"))
    {
        printf("25s/75c\n");
        work_loop = 1;
        crypto_loop = 100;
    }
    else if (!strcmp(input, "50"))
    {
        printf("50s/50c\n");
        work_loop = 4;
        crypto_loop = 100;
    }
    else if (!strcmp(input, "25"))
    {
        printf("75s/25c\n");
        work_loop = 4;
        crypto_loop = 40;
    }
    else if (!strcmp(input, "10"))
    {
        printf("90s/10c\n");
        work_loop = 4;
        crypto_loop = 15;
    }
    else
    {
        printf("Invalid setup!\n");
        // return 1;
        work_loop = 1;
        crypto_loop = 1;
    }

    memset(cipher_buf, 0, 4096);

    time_work = 0;
    time_encrypt = 0;

    for (k = 0; k < 10; k++)
    {
        printf("%d\n", k);
        time1 = rdcycle();
        for (j = 0; j < work_loop; j++)
        {
            // call sglib benchmark
            benchmark();
        }
        time2 = rdcycle() - time1;
        time_work += time2;

        time1 = rdcycle();
        for (i = 0; i < crypto_loop; i++)
        {
            // do Encrypt section
            Hacl_Chacha20_chacha20_encrypt((uint32_t)MESSAGE_LEN, (unsigned char *)(cipher_buf + (i * 16)), (unsigned char *)(plain_in_data + (i * 16)),
                                           key, nonce, (uint32_t)0U);
        }
        time2 = rdcycle() - time1;
        time_encrypt += time2;
    }

    // print the final execution times
    printf("work time   :[%llu]\n", time_work);
    printf("encrypt time:[%llu]\n", time_encrypt);
    printf("total time  :[%llu]\n", time_work + time_encrypt);

    return 0;
}
