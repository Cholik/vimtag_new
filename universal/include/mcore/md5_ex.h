/*
\file       md5_ex.h
\brief      md5 unit

 ----history----
\author     chengzhiyong 
\date       2009-12-18
\version    0.01
\desc       md5

$Author: chengzhiyong $
$Id: md5_ex.h,v 1.4 2008-06-02 12:54:50 chengzhiyong Exp $
*/

#ifndef _MD5_EX_H
#define _MD5_EX_H
extern void md5_ex_encrypt(unsigned char * src, long slen, unsigned char * dst);
extern void md5_ex_encrypt_hex(unsigned char * src, long slen, unsigned char * dst );
#endif             
    
