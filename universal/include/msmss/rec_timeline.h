/*!
\file       rec_timeline.h
\brief     

 ----history----
\author     Liuzp
\date       2014-02-25
\version    0.01
\desc       create

*/

#if !defined(__rec_timeline_h__)
#define __smss_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

/*********************************************************
 \brief: Set <v> to pos <seq> of timeline, each <v> occupy two bytes.   
 \param: pstart - bits-map head
 \param: seq - start from 0
 \param: v - bits value, o
*/
static inline void rec_timeline_set(char* pstart, ulong seq, char v)
{
    char* ptmp;
	ulong pos_in_byte;
		
    v &= 0x3;

	// Locate bits
	ptmp += pstart + (seq / 4);
	pos_in_byte = (seq % 4) << 1;

	*ptmp |= (v << pos_in_byte);
}


#if defined(__cplusplus)
    }
#endif/* defined(__cplusplus) */

#endif /* !defined(__rec_timeline_h__) */


