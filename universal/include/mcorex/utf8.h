/*!
\file       utf8.h
\brief      utf8 unit

 ----history----
\author     chengzhiyong
\date       2007-03-04
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: utf8.h,v 1.6 2008-11-18 06:19:58 chengzhiyong Exp $
*/
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__utf8_h__)
#define __utf8_h__

#if !defined(__uint32_t_defined)
#define __uint32_t_defined
    typedef unsigned int        uint32_t;
#endif

#define utf8_3_mask  (*(uint32_t*)"\xff\xff\xff\x00")

#define utf8_same_3_bytes(x,y) ((utf8_3_mask & *(uint32_t*)(x)) == (utf8_3_mask & *(uint32_t*)(y)))
#define utf8_same_6_bytes(x,y) (((*(uint32_t*)(x)) == (*(uint32_t*)(y))) \
    && ((*(short*)(((char*)(x)) + 4)) == (*(short*)(((char*)(y)) + 4))))
#define utf8_same_9_bytes(x,y) (((*(uint32_t*)(x)) == (*(uint32_t*)(y))) \
    && ((*(uint32_t*)(((char*)(x)) + 4)) == (*(uint32_t*)(((char*)(y)) + 4)))\
    && ((*(((char*)(x)) + 8)) == (*(((char*)(y)) + 8))))
#define utf8_same_12_bytes(x,y) (((*(uint32_t*)(x)) == (*(uint32_t*)(y))) \
    && ((*(uint32_t*)(((char*)(x)) + 4)) == (*(uint32_t*)(((char*)(y)) + 4)))\
    && ((*(uint32_t*)(((char*)(x)) + 8)) == (*(uint32_t*)(((char*)(y)) + 8))))
    
#define utf8_prefix "\x00\xc0\xe0\xf0\xf8\xfc"
/*          bytes  f-mask  f-flag  description
0*******    1bytes 0x80    0x00    0*******
110*****    2bytes 0xe0    0xc0    110***** 10******
1110****    3bytes 0xf0    0xe0    1110**** 10****** 10******
11110***    4bytes 0xf8    0xf0    1111**** 10****** 10****** 10******
111110**    5bytes 0xfc    0xf8    11111*** 10****** 10****** 10****** 10******
1111110*    6bytes 0xfe    0xfc    111111** 10****** 10****** 10****** 10****** 10******
*/
/*! get CHINESE utf8 char len, don't let (c < 80)!!!, just for CHINESE char */
#define utf8_len_of_zh_c(c) \
    (\
        (0xe0 == (0xf0 & ((unsigned char)(c))))?3:\
            (\
                (0xf8 <= ((unsigned char)(c)))?\
                    ((0xfc <= ((unsigned char)(c)))?6:5):\
                    ((0xe0 > ((unsigned char)(c)))?2:4)\
            )\
    )
#define utf8_len_of_zh_s(s) utf8_len_of_zh_c(*s)
/*! get utf-8 char length, if 0 means invalid utf8-char, else the char counts */
#define utf8_len_of_c(c) \
    (\
        (0x80 > ((unsigned char)(c)))?1:\
            (\
                (0xe0 == (0xf0 & ((unsigned char)(c))))?3:\
                    (\
                        (0xf8 <= ((unsigned char)(c)))?\
                            ((0xfc > ((unsigned char)(c)))?5:((0xfe > ((unsigned char)(c))?6:0))):\
                            (((0xf0 <= ((unsigned char)(c)))?4:((0xc0 <= ((unsigned char)(c)))?2:0)))\
                    )\
            )\
    )

/*! check is utf-8 follow char */
#define utf8_is_follow_char(c) (0x80 == (0xc0 & (c)))

/*! Chinese normal char 4e00(11100100 10111000 10000000 E4 B8 C0)~9fff(11101001 10111111 10111111 E9 BF BF)*/
#define utf8_is_zh_normal_char(s) \
    ((((s)[0] > 0xe4) || (((s)[0] == 0xe4) && ((((s)[1] > 0xb8) || (((s)[1] == 0xb8) && ((s)[2] >= 0xc0)))))) \
    &&(((s)[0] < 0xe9) || (((s)[0] == 0xe9) && ((((s)[1] < 0xbf) || (((s)[1] == 0xbf) && ((s)[2] <= 0xbf)))))))

#define utf8_3_bom              "\xef\xbb\xbf"  /* UTF-8 EMPTY BOM CHAR */

#define utf8_2_doc              "\xc2\xb7"      /* Chinese DOT char */

#define utf8_3_space            "\xe3\x80\x80"  /* Chinese space char */
#define utf8_3_period           "\xe3\x80\x82"  /* Chinese . period char */
#define utf8_3_parallel         "\xe2\x80\x96"  /* Chinese || */
#define utf8_3_sglquot_l        "\xe2\x80\x98"  /* Chinese ' left(open) */
#define utf8_3_sglquot_r        "\xe2\x80\x99"  /* Chinese ' right(close) */
#define utf8_3_dblquot_l        "\xe2\x80\x9c"  /* Chinese " left(open) */
#define utf8_3_dblquot_r        "\xe2\x80\x9d"  /* Chinese " right(close) */
#define utf8_3_colo             "\xef\xbc\x9a"  /* Chinese : */
#define utf8_3_comma            "\xef\xbc\x8c"  /* Chinese , */
#define utf8_3_semicomma        "\xef\xbc\x9b"  /* Chinese ; */
#define utf8_3_lessthan         "\xef\xbc\x9c"  /* Chinese < less than */
#define utf8_3_morethan         "\xef\xbc\x9e"  /* Chinese > more than */
#define utf8_3_vbar             "\xef\xbd\x9c"  /* Chinese | */

#define utf8_3_parenthese_l     "\xef\xbc\x88"  /* Chinese ( left(open) parentheses */
#define utf8_3_parenthese_r     "\xef\xbc\x89"  /* Chinese ) right(close) parentheses */
#define utf8_3_frchquot_l       "\xe3\x80\x8a"  /* Chinese << left(open) French quotes */
#define utf8_3_frchquot_r       "\xe3\x80\x8b"  /* Chinese >> right(close) French quotes */
#define utf8_3_braces_l         "\xe3\x80\x8e"  /* Chinese { left(open) braces */
#define utf8_3_braces_r         "\xe3\x80\x8f"  /* Chinese } right(close) braces */
#define utf8_3_sqlbrackets_l    "\xe3\x80\x90"  /* Chinese [ left(open) square brackets */
#define utf8_3_sqlbrackets_r    "\xe3\x80\x91"  /* Chinese ] right(close) square brackets */

    
#define utf8_6_leixing          "\xe7\xb1\xbb\xe5\x9e\x8b"
#define utf8_6_chanpin	        "\xe4\xba\xa7\xe5\x93\x81"
#define utf8_6_shangpin         "\xe5\x95\x86\xe5\x93\x81"
#define utf8_12_chanpinleixing	"\xe4\xba\xa7\xe5\x93\x81\xe7\xb1\xbb\xe5\x9e\x8b"
#define utf8_6_changshang	    "\xe5\x8e\x82\xe5\x95\x86"
#define utf8_9_zhizaoshang	    "\xe5\x88\xb6\xe9\x80\xa0\xe5\x95\x86"
#define utf8_6_gongsi		    "\xe5\x85\xac\xe5\x8f\xb8"
#define utf8_6_mingzi		    "\xe5\x90\x8d\xe5\xad\x97"
#define utf8_6_xinghao		    "\xe5\x9e\x8b\xe5\x8f\xb7"
#define utf8_6_redu             "\xe7\x83\xad\xe5\xba\xa6"
#define utf8_6_jiage            "\xe4\xbb\xb7\xe6\xa0\xbc"
#define utf8_12_remenshangpin   "\xe7\x83\xad\xe9\x97\xa8\xe5\x95\x86\xe5\x93\x81"
#define utf8_6_zhichi           "\xe6\x94\xaf\xe6\x8c\x81\x00"
#define utf8_3_you              "\xe6\x9c\x89"
#define utf8_3_wu               "\xe6\x97\xa0"
#define utf8_3_shi              "\xe6\x98\xaf"
#define utf8_3_fou              "\xe4\xb8\x8d"
#define utf8_3_bu               "\xe5\x90\xa6"
#define utf8_3_mei              "\xe6\xb2\xa1"
#define utf8_6_canshu           "\xe5\x8f\x82\xe6\x95\xb0"
#define utf8_6_liebiao          "\xe5\x88\x97\xe8\xa1\xa8"
#define utf8_6_jiben            "\xe5\x9f\xba\xe6\x9c\xac"
#define utf8_6_zhuyao           "\xe4\xb8\xbb\xe8\xa6\x81"
#define utf8_12_jibenguige      "\xe5\x9f\xba\xe6\x9c\xac\xe8\xa7\x84\xe6\xa0\xbc"
#define utf8_12_jibencanshu     "\xe5\x9f\xba\xe6\x9c\xac\xe5\x8f\x82\xe6\x95\xb0"
#define utf8_12_jibenshuxin     "\xe5\x9f\xba\xe6\x9c\xac\xe5\xb1\x9e\xe6\x80\xa7"
#define utf8_12_zhuyaoxinneng   "\xe4\xb8\xbb\xe8\xa6\x81\xe6\x80\xa7\xe8\x83\xbd"
#define utf8_12_tijiaochenggong "\xe6\x8f\x90\xe4\xba\xa4\xe6\x88\x90\xe5\x8a\x9f"
#define utf8_12_zhutichongfu    "\xe4\xb8\xbb\xe9\xa2\x98\xe9\x87\x8d\xe5\xa4\x8d"
#define utf8_12_cankaojiage     "\xe5\x8f\x82\xe8\x80\x83\xe4\xbb\xb7\xe6\xa0\xbc"
#define utf8_12_jiagefanwei     "\xe4\xbb\xb7\xe6\xa0\xbc\xe8\x8c\x83\xe5\x9b\xb4"

#define utf8_6_suoyou           "\xe6\x89\x80\xe6\x9c\x89"

#define utf8_3_jia              "\xe4\xbb\xb7"
#define utf8_3_fei              "\xe8\xb4\xb9"
#define utf8_3_jia_tzh          "\xe5\x83\xb9"
#define utf8_3_jia_jp           "\xe4\xbe\xa1"
#define utf8_3_yuan             "\xe5\x85\x83"
#define utf8_3_zhe              "\xe6\x8a\x98"
#define utf8_3_yuan_sign        "\xef\xbf\xa5"
#define utf8_2_yuan_sign        "\xc2\xa5"
#define utf8_2_pound_sign       "\xc2\xa3"
#define utf8_3_wan              "\xe4\xb8\x87"
    
#define utf8_6_paixu            "\xe6\x8e\x92\xe5\xba\x8f"
#define utf8_6_xiansi           "\xe6\x98\xb3\xe7\xa4\xba"
#define utf8_6_ziduan           "\xe5\xad\x97\xe6\xae\xb5"

#define utf8_6_chakan           "\xe6\x9f\xa5\xe7\x9c\x8b"
#define utf8_6_baojia           "\xe6\x8a\xa5\xe4\xbb\xb7"


#define utf8_6_zhuce            "\xe6\xb3\xa8\xe5\x86\x8c"
#define utf8_6_shijian          "\xe6\x97\xb6\xe9\x97\xb4"
#define utf8_6_riqi             "\xe6\x97\xa5\xe6\x9c\x9f"

#endif /* !defined(__utf8_h__) */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
