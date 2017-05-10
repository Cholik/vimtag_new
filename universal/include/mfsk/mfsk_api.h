/*!
\file       mfsk_api.h
\brief      mining mfsk util api

 ----history----
\author     liaowenhua
\date       2015-11-20
\version    0.01
\desc       create
*/

#ifndef _MFSK_API_H_
#define _MFSK_API_H_

#ifdef __cplusplus
extern "C" {
#endif 

#define PI                              3.141592654f   //pi

#define SEND_MODE                       0
#define RECIVE_MODE                     1
#define DECODE_FREQ_COUNTS              2

//default value
#define MODE_DEFAULT                    0
#define CHANNEL_DEFAULT                 1             //默认声道数
#define SAMPLEBITS_DEFAULT              8            //默认采样位数
#define SAMPLERATE_DEFAULT              16000         //默认采样率

#define PREBITS_DEFAULT                 40            //默认头
#define POSTBITS_DEFAULT                20            //默认尾    

#define BAND_DEFAULT                    400           //默认波特率
#define FREQLOW                         4000          //默认低频  表示 0
#define FREQHIGH                        5500          //默认高频  表示 1

#define DESC_BORDER_TYPE                maicodec_border_type_outline
#define DESC_BORDER_MAGIC               256
#define DESC_BORDER_START_MAGIC_COUNTS  8
#define DESC_CODE_PAYLOAD_BITS          8
#define DESC_CODE_INDEX_BITS            0
#define DESC_CODE_CHECKSUM_BITS         0
#define DESC_SEG_PLAYLOAD_BITS          64
#define DESC_SEG_INDEX_BITS             8
#define DESC_SEG_CHECKSUM_BITS          8

struct mfsk_desc
{
    struct maicodec_desc desc;

    struct {
        long band;                      //band rate 
        long freqhigh;           
        long freqlow;
        long prebits;                       
        long postbits;
    } info;  

    struct {
        long channel;                   //声道数   1 or 2
        long samplebits;                //采样位数 8 or 16
        long samplerate;                //采样率 
    } device;
};

struct mfsk_runner_desc
{
    struct mfsk_desc *desc;
    int    mode;                     

    struct {
        char *send_msg;         
        unsigned char *buf;
        unsigned len;
        char *wav;        
    } encode;

    struct {
        unsigned freqs[DECODE_FREQ_COUNTS];
        unsigned window_sample_counts;
        double threshold;
    } decode;
};

struct mfsk_runner 
{
    struct mfsk_desc desc;
    int    mode;                        // SEND_MODE or RECIVE_MODE

    struct {
       unsigned short maicodec_buf[256];
       unsigned maicodec_len;
       unsigned encode_len;
       
       char *send_msg;                  //send msg
       unsigned msg_len;
       unsigned char *buf;
       unsigned buf_len;

       struct wav_desc *wdesc;
       char *wav; 
    } encode;

    struct {
        struct maicodec_decode_ctx *ctx;
        
        unsigned freqs[DECODE_FREQ_COUNTS];
        double  q1[DECODE_FREQ_COUNTS];
        double  q2[DECODE_FREQ_COUNTS];
        double  r[DECODE_FREQ_COUNTS];
        double  coefs[DECODE_FREQ_COUNTS];
        int64_t total_power[DECODE_FREQ_COUNTS];
        double energies[DECODE_FREQ_COUNTS];

        unsigned short rec_data[256];        
        unsigned long rec_cur;
        unsigned char *decode_data;
        unsigned long decode_len;
        unsigned char data[256];

        double  threshold;
        int     sample_counts;
        int     window_sample_counts;
    } decode;    
};

struct mfsk
{
    long band;               //band rate 
    long freqhigh;           
    long freqlow;

    long channel;            //声道数   1 or 2
    long samplebits;         //采样位数 8 or 16
    long samplerate;         //采样率 

    long prebits;            //头标志位数 sampleRate*100/1000/spb 40
    long postbits;           //尾标志位数   20
    
    struct { 
        struct maicodec_desc *desc;
    } encode;

    struct {
        struct maicodec_desc *desc;
    } decode;    

    long trans_mode;
};

/*!
func    mfsk_create
\brief  create mfsk runner
\param  struct mfsk_runner_desc *[in]          desc
\return 
        # != NULL               success
        # = NULL                fail
*/
//struct mfsk_runner * mfsk_create (struct mfsk_runner_desc *desc);

/*!
func    mfsk_pcm_to_wav
\brief  encode pcm buf to wav file
\param  mfsk_param[in]          struct mfsk_param
\param  pcm_buf[in]           	pcm buf
\param  pcm_len[in]             pcm len          		
\param  wav_name[in]            wav file name
\return 
        # = 0                   success
        # < 0                   fail
*/
long mfsk_pcm_to_wav( struct mfsk *param, unsigned char *pcm_buf, unsigned long pcm_len, char *wav_name);

/*!
func    mfsk_encode_to_pcm
\brief  encode fsk txt to pcm buf
\param  mfsk_param[in]          struct mfsk_param
\param  wav_name[in]           	wav file name
\param  txt[in]            		message for encode
\return 
        # > 0                   encode pcm len
        # <= 0                  fail
*/
long mfsk_encode_to_pcm( struct mfsk *param, unsigned char *pcm_buf, unsigned long len, char *txt);

#ifdef __cplusplus
}
#endif/* defined(__cplusplus) */

#endif
