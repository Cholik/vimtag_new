/*
\file       sha256.h
\brief      sha256 unit

 ----history----
\author     chengzhiyong 
\date       2009-12-18
\version    0.01
\desc       sha 256 hash algorithm, hmac sha 256 encrypt

$Author: chengzhiyong $
$Id: sha256.h,v 1.4 2008-06-02 12:54:50 chengzhiyong Exp $
*/
#if !defined(__sha256_h__)
#define __sha256_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct sha256_ctx;
#define sha256_digest_size  32

struct sha256_ctx *sha256_create(void);
long sha256_destroy(struct sha256_ctx *ctx);
long sha256_update(struct sha256_ctx *ctx, unsigned long len, unsigned char *data);
long sha256_digest(struct sha256_ctx *ctx, unsigned long len, unsigned char *digest);
long sha256_hmac(unsigned long key_len, unsigned char *key, unsigned long data_len, unsigned char *data, unsigned char *digest/* 32bytes */);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__sha256_h__) */

