/*
\file       wave_file.h
\brief      wave file unit

 ----history----
\author     chengzhiyong 
\date       2011-08-11
\version    0.01
\desc       create

*/

#if !defined(__wave_file_h__)
#define __wave_file_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct wav_file;

/*!\brief wave description */
typedef struct wav_desc
{
    unsigned long   channels;           /*!< channels counts */
    unsigned long   sample_rate;        /*!< sample rate */
    unsigned long   sample_bits;        /*!< sample bits */
}_wav_desc;

/*!
func    wav_open
\brief  open wave file, after used should call wav_close to free resource
\param	filename[in]        the wave file name
\param  mod[in]             the open mod, 'r' read, 'w' write
\param  desc[in/out]        wave description, if (mod == 'r') is [out], else is [in]
\return wave file object
        #NULL               failed
        #other              the wave file object
*/
struct wav_file *wav_open(char *filename, char *mod/* [r|w] */, struct wav_desc *desc);

/*!
func    wav_log_open
\brief  open wave file, after used should call wav_close to free resource
        file-name will be [<wave_log><moudle>-<YYYYMMDD>-<HHMMSS>--<type>-<ID>-<TOTAL-COUNTS>.wav]
        should set enviroment "wave_log=<path>", "wave_log_module=<module1>,<module2>"
\param	module[in]          module name, will check "wave_log_module" environment
                            if not exist this environment will do nothing and return NULL
\param  type[in]            type
\param  id[in]              id number
\param  sample_bits[in]     sample bits
\param  sample_rate[in]     sample rate
\param  channels[in]        channels
\return wave file object
        #NULL               failed
        #other              the wave file object
*/
struct wav_file *wav_log_open(char *module, char *type, unsigned long id,
                              unsigned long sample_bits, unsigned long sample_rate, unsigned long channels);

/*!
func    wav_close
\brief  close wave file, if 'w' mode and forget call this function
        or wave file is a invalid wave file.
\param	file[in]            the wave file object return by wav_open
\return destroy result
        #0                  succeed
        #other              error code
*/
long wav_close(struct wav_file *file);

/*!
func    wav_read
\brief  read data to file
\param	file[in]            the wave file object return by wav_open
\param  size[in]            the data size, must be align (channels*sample_bits/8)
\param  buf[out]            the data
\param  tick[out]           the current data tick
\return read data length
        #0                  end
        #<0                 error code
        #>0                 read data size
*/
long wav_read(struct wav_file *file, unsigned long size, unsigned char *buf, unsigned long *tick);

/*!
func    wav_write
\brief  write data to file
\param	file[in]            the wave file object return by wav_open
\param  size[in]            the data size, must be align (channels*sample_bits/8)
\param  buf[in]             the data
\param  tick[in]            the data tick, start from 0
                            #0  fixed near prev data
                            other will fill zero data into cap section.
\return write data length
        #<0                 error code
        #other              read data size
*/
long wav_write(struct wav_file *file, unsigned long size, unsigned char *data, unsigned long tick);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__wave_file_h__) */
