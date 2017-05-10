/*!
\file       ascii.c 
\brief      template unit, ascii table unit, this file defined normal ascii,
            can be copy to define FSM for PARSER(such as xml,json,html...)

 ----history----
\author     chengzhiyong 
\date       2009-01-23
\version    0.01
\desc       create
*/
#if !defined(__ASCII_H__)
#define __ASCII_H__
#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if 0 /* just template, so close it  */

/* -------- <char type list> ---------- 
    NAM hex description
    ___     comman char
    NUL 00  \0 null char     
    SOH 01  start of header     
    STX 02  start of text     
    ETX 03  end of text     
    EOT 04  end of Transmission     
    ENQ 05  enquiry     
    ACK 06  acknowledgment     
    BEL 07  bell     
    BS  08  backspace     
    HT  09  \t horizontal tab     
    LF  0a  \n line feed     
    VTB 0b  vertical tab     
    FF  0c  form feed     
    CR  0d  \r return
    SO  0e  shift out     
    SI  0f  shift in     
    DLE 10  data link escape     
    DC1 11  device control 1(xon)     
    DC2 12  device control 2     
    DC3 13  device control 3(xoff)    
    DC4 14  device control 4     
    NAK 15  negative acknowledgement     
    SYN 16  synchronous idle     
    ETB 17  end of trans. block     
    CAN 18  cancel     
    EM  19  end of medium     
    SUB 1A  substitute     
    ESC 1B  escape     
    FS  1C  file separator     
    GS  1D  group separator     
    RS  1E  request to send(record separator)     
    US  1F  unit separator     
    SP  20  space
    WSP     \20 \t white space
    LWS     \20 \t \r white space
    WHT     white char, normal way should by \20 \t \n \r
    VCH     21-7e print char
    EXM 21  ! exclamation mark     
    DQT 22  " double quote     
    SHP 23  # sharp(number sign)     
    DOL 24  $ dollar sign     
    PER 25  % percent     
    AMP 26  & ampersand     
    SQT 27  ' single quote
    OPR 28  ( opening/left parenthesis     
    CPR 29  ) closing/right parenthesis     
    MUL 2A  * multiplication sign     
    PLS 2B  + plus     
    CMA 2C  , comma     
    MIN 2D  - minus/dash     
    DOT 2E  . dot     
    FSL 2F  / forward slash
    BIT     0-1(30-31)  bit number
    OCT     0-7(30-37)  oct number char
    DIG       0-9(30-39) digit number char     
    CLO 3A  : colon     
    SCL 3B  ; semi-colon     
    LT  3C  < less than     
    EQ  3D  = equal     
    GT  3E  > greater than     
    QST 3F  ? question mark     
    AT  40  @ at symbol     
    ALP     A-Z/a-z(41-5A/61-7A) alpha char     
    UCH     A-Z(41-5A) upper case char     
    LCH     a-z(61-7A) lower case char     
    HDG     A-F/a-f(41-46/61-66) hex digit number char
    OBK 5B  [ opening/left bracket     
    BKS 5C  \ back slash     
    CBK 5D  ] closing/right bracket     
    CRT 5E  ^ caret/circumflex     
    UNS 5F  _ underscore     
    BKT 60  ` backticks     
    OBC 7B  { opening/left brace     
    VRB 7C  | vertical bar     
    CBC 7D  } closing/right brace     
    TLD 7E  ~ tilde     
    DEL 7F  delete     
    MCH     multi char(80-ff), means multi bytes char, such as Chinese     
    TMX          type max   
-------- <char type list> ----------*/

/* here just a template ascii table from <char type list> */
typedef enum ch_type_template
{
    /*  \0      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0-1,0-7 0-9 :   ;   <   =   >   ?   @   [   ]   ]   ^   _   `   {   |   }   ~       */
    ___,NUL,WHT,EXM,DQT,SHP,DOL,PER,AMP,SQT,OPR,CPR,MUL,PLS,CMA,MIN,DOT,FSL,BIT,OCT,DIG,CLO,SCL,LT ,EQ ,GT ,QST,AT ,OBK,BKS,CBK,CRT,UNS,BKT,OBC,VRB,CBC,TLD,TMX
}_ch_type_template;

/* ascii table (7bits) (ascii = american standard code for information interchange)
   here just a template ascii table, can copy from here then change it. */
static int ch_table_template[] = 
{
/* |0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
---+----------------------------------------------------------------*/
    NUL,___,___,___,___,___,___,___,___,HT ,LF ,___,___,CR ,___,___,
/*0|NUL SOH STX ETX EOT ENQ ACK BEL BS  HT  LF  VTB FF  CR  SO  SI  */
    ___,___,___,___,___,___,___,___,___,___,___,___,___,___,___,___,
/*1|DLE DC1 DC2 DC3 DC4 NAK SYN ETB CAN EM  SUB ESC FS  GS  RS  US  */
    SP ,EXM,DQT,SHP,DOL,PER,AMP,SQT,OPR,CPR,MUL,PLS,CMA,MIN,DOT,FSL,
/*2|SP  !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   */
    ___,___,___,___,___,___,___,___,___,___,CLO,SCL,LT ,EQ ,GT ,QST,
/*3|0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   */
    AT ,___,___,___,___,___,___,___,___,___,___,___,___,___,___,___,
/*4|@   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   */
    ___,___,___,___,___,___,___,___,___,___,___,OBR,BKS,CBR,CRT,UNS,
/*5|P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   */
    ___,___,___,___,___,___,___,___,___,___,___,___,___,___,___,___,
/*6|`   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   */
    ___,___,___,___,___,___,___,___,___,___,BKT,OBR,VRB,CBR,TLD,DEL
/*7|p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~   DEL */
/*---+--------------------------------------------------------------*/
};


/*! \breif operation template */
typedef enum operation_template
{
    __,
    nxt = __,   /* 0  next char, and not change status */
    bnd,        /* begin node */
    err         /* error */
}_operation_template;

/*!< \breif parse status template */
typedef enum status_template
{
    s_in_root_idle,
    s_wait_node_name,
    s_status_max
}_status_template;

/*! \brief sym node  */
typedef struct sym_node_template
{
    enum operation_template  opr[TMX];       /*!< operation */
    enum status_template     status;         /*!< status */
}_sym_node_template;

/*! \brief sym table template*/
static struct sym_node_template __sym_table_template[s_status_max]=
{
       /*  \0      !   "   '   /   <   =   >   ?  
        ___,NUL,WHT,EXM,DQT,SQT,FSL,LT ,EQ ,GT ,QST */
    {{  err,suc,__, err,err,err,err,bnd,err,err,err}, s_in_root_idle},
    {{  bun,err,err,bcm,err,err,bdn,err,err,err,bun}, s_wait_node_name}
};

/*! \brief check sym table */
long check_sym_table_template()
{
    static long sym_table_valid/* 1:ok, -1:err */;
    if(0 == sym_table_valid)
    {/* have not checked */
        long i;
        for(i = 0; i < (long)s_status_max; ++i)
        {
            if(i != (long)__xml_parse_sym[i].status)
            {
                printf("err: xml_check_sym_table() failed at index[%d]. %s:%d\r\n", i, __FILE__, __LINE__);
                return -1;
            }
        }
        sym_table_valid = 1;
        return 0;
    }
    return (0 < sym_table_valid)?0:-1;
}


#endif /* #if 0 */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
#endif /* !defined(__ASCII_H__) */
