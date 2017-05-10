#if !defined(__mining_openssl_cryptos_h__)
#define __mining_openssl_cryptos_h__

#include "openssl/conf.h"

#include "openssl/asn1.h"
#include "openssl/bn.h"
#include "openssl/buffer.h"
#include "openssl/comp.h"
#include "openssl/dso.h"
#include "openssl/err.h"
#include "openssl/evp.h"
#include "openssl/krb5_asn.h"
#include "openssl/lhash.h"
#include "openssl/modes.h"
#include "openssl/objects.h"
#include "openssl/ocsp.h"
#include "openssl/pem.h"
#include "openssl/pkcs12.h"
#include "openssl/pkcs7.h"
#include "openssl/pqueue.h"
#include "openssl/rand.h"
#include "openssl/stack.h"
//#include "openssl/store.h"
#include "openssl/ts.h"
#include "openssl/txt_db.h"
#include "openssl/ui.h"
#include "openssl/whrlpool.h"
#include "openssl/x509.h"
#include "openssl/x509v3.h"


#if !defined(OPENSSL_NO_ENGINE)
#include "openssl/engine.h"
#endif


#if !defined(OPENSSL_NO_AES)
#include "openssl/aes.h"
#endif
#if !defined(OPENSSL_NO_BF)
#include "openssl/blowfish.h"
#endif
#if !defined(OPENSSL_NO_FP_API)
#include "openssl/bio.h"
#endif
#if !defined(OPENSSL_NO_CAMELLIA)
#include "openssl/camellia.h"
#endif
#if !defined(OPENSSL_NO_CAST)
#include "openssl/cast.h"
#endif
#if !defined(OPENSSL_NO_CMS)
#include "openssl/cms.h"
#endif
#if !defined(OPENSSL_NO_DES)
#include "openssl/des.h"
#endif
#if !defined(OPENSSL_NO_DH)
#include "openssl/dh.h"
#endif
#if !defined(OPENSSL_NO_DSA)
#include "openssl/dsa.h"
#endif
#if !defined(OPENSSL_NO_EC)
#include "openssl/ec.h"
#endif
#if !defined(OPENSSL_NO_ECDH)
#include "openssl/ecdh.h"
#endif
#if !defined(OPENSSL_NO_ECDSA)
#include "openssl/ecdsa.h"
#endif
#if !defined(OPENSSL_NO_HMAC)
#include "openssl/hmac.h"
#endif
#if !defined(OPENSSL_NO_IDEA)
#include "openssl/idea.h"
#endif
#if !defined(OPENSSL_NO_MD2)
#include "openssl/md2.h"
#endif
#if !defined(OPENSSL_NO_MD4)
#include "openssl/md4.h"
#endif
#if !defined(OPENSSL_NO_MD5)
#include "openssl/md5.h"
#endif
#if !defined(OPENSSL_NO_MDC2)
#include "openssl/mdc2.h"
#endif
#if !defined(OPENSSL_NO_RC2)
#include "openssl/rc2.h"
#endif
#if !defined(OPENSSL_NO_RC4)
#include "openssl/rc4.h"
#endif
#if !defined(OPENSSL_NO_RIPEMD)
#include "openssl/ripemd.h"
#endif
#if !defined(OPENSSL_NO_RSA)
#include "openssl/rsa.h"
#endif
#if !defined(OPENSSL_NO_SEED)
#include "openssl/seed.h"
#endif
#if !defined(OPENSSL_NO_SHA) && !defined(OPENSSL_NO_SHA0) && !defined(OPENSSL_NO_SHA1)
#include "openssl/sha.h"
#endif

#endif /* __mining_openssl_cryptos_h__ */
