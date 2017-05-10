#ifndef __H264_STREAM_H__
#define __H264_STREAM_H__
#pragma pack(1)

#include"assert.h"

#define ASSERT	assert
#define MIN(x, y, z) (z = (x < y)? (x): (y))



typedef struct
{
    unsigned char   *m_pucStreamStart;
    unsigned char   *m_pucStreamEnd;

    unsigned char   *m_pucStream;
    long            m_lBitCnt;
    unsigned long   m_ulBits;
} ST_STREAM;

#define STREAM_INIT(pucStream, len) {    \
    stream.m_pucStreamStart = pucStream; \
    stream.m_pucStreamEnd = pucStream+len;  \
    stream.m_pucStream = pucStream;      \
    stream.m_lBitCnt = 0; \
    stream.m_ulBits = 0;  \
    }

#define STREAM_READ_FLNBIT(n, val){   \
    while (stream.m_lBitCnt < (long)(n)) {  \
        stream.m_ulBits <<= 8;    \
        stream.m_ulBits += *stream.m_pucStream; \
        stream.m_pucStream ++;    \
        stream.m_lBitCnt += 8; }  \
    ASSERT(stream.m_lBitCnt <= 32);   \
    stream.m_lBitCnt -= n;    \
    val = ((stream.m_ulBits >> stream.m_lBitCnt) & ((1<<(n))-1));   \
    }

#define STREAM_SEEK_BACK_NBIT(n) {    \
    stream.m_lBitCnt += n;        \
    ASSERT(stream.m_lBitCnt <= 32 );  \
    }

#define STREAM_DECODE_UE_PREFIX(lIdx) {   \
     long _lBits, _lData;   \
    lIdx = 0;   \
    while (lIdx < 32) { \
        STREAM_READ_FLNBIT(8, _lBits);    \
        if (_lBits) break;  \
        lIdx += 8; }    \
    _lData = m_aucUEPrefixDecode[_lBits];  \
    lIdx += (_lData & 0xF); \
    _lData >>= 4;   \
    STREAM_SEEK_BACK_NBIT(_lData);   \
    }

#define STREAM_DECODE_U(n, u)     {  \
    ASSERT(n <= 24 );   \
    STREAM_READ_FLNBIT(n, u);  \
    }
#define STREAM_DECODE_UGT24(n, u)       {   \
     long _u;       \
    ASSERT(n>24&&n<=32);    \
    STREAM_DECODE_U(n-24, _u);   \
    _u <<= 24;  \
    STREAM_DECODE_U(24, u);   \
    u += _u;    \
    }

#define STREAM_DECODE_UE(ue)            {   \
     long _lPrefix, _lSuffix;   \
    STREAM_DECODE_UE_PREFIX(_lPrefix);   \
    MIN(_lPrefix, 24, _lPrefix);    \
    STREAM_READ_FLNBIT(_lPrefix, _lSuffix); \
    ue = (1<<_lPrefix)+_lSuffix-1;      \
    }

#define STREAM_DECODE_SE(se)            {   \
     long _lPrefix, _lSuffix, _lSign;   \
    STREAM_DECODE_UE_PREFIX(_lPrefix);    \
    MIN(_lPrefix, 24, _lPrefix);    \
    STREAM_READ_FLNBIT(_lPrefix, _lSuffix);   \
    _lSign = _lSuffix&1;    \
    _lSuffix += (1<<_lPrefix);  \
    _lSuffix >>= 1; \
    _lSuffix ^= (0-_lSign); \
    se = _lSuffix+_lSign;   \
    }

#pragma pack()
#endif

