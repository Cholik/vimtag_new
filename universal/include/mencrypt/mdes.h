/*!
\file       mdes.h
*/
#if !defined(__mdes_h__)
#define __mdes_h__

#if defined(__cplusplus)
extern "C" {
#endif

extern long mdes_enc_hex( char *in, long in_len, char *pass, long pass_len, char *out, long *out_len );
extern long mdes_dec_hex( char *in, long in_len, char *pass, long pass_len, char *out, long *out_len );

/* enc and dec with header and auto padding 8bytes align. */
extern long mdes_enc(unsigned char *data, unsigned long data_len, /* if without header must align 4 */
                     unsigned char *pass, unsigned long pass_len,
                     unsigned char *buf,  unsigned long buf_size /* buf is [out] */);
extern long mdes_dec(unsigned char *data, unsigned long data_len, /* if without header must align 4 */
                     unsigned char *pass, unsigned long pass_len,
                     unsigned char *buf,  unsigned long buf_size /* buf is [out] */);

extern long mdes_test_main(long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__mdes_h__) */
