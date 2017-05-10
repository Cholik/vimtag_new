/*!
\file       at88sc_datasheet.h
\brief      mining at88sc chip, refer to <<CryptoMemory AT88XXXC Full Datasheet.pdf>>

 ----history----
\author     chengzhiyong
\date       2011-08-06
\version    0.01
\desc       create
*/

#if !defined(__at88sc_datasheet_h__)
#define __at88sc_datasheet_h__

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */



/*  
    [ $0B ][ $1B ][ $2B ][ $3B ][ $4B ][ $5B ][ $6B ][ $7B ]
-------------------------Identifycation---------------------
$00 [Answer To Reset Identification                        ]
$08 [Fab Code    ][MTZ         ][Card Manufacturer Code    ] */
#define at88sc_answer_to_reset_addr                         0x00
#define at88sc_answer_to_reset_size                         0x08
#define at88sc_fab_code_addr                                0x08
#define at88sc_fab_code_size                                0x02
#define at88sc_mtz_addr                                     0x0a
#define at88sc_mtz_size                                     0x02
#define at88sc_card_manufacturer_code_addr                  0x0c
#define at88sc_card_manufacturer_code_size                  0x04

typedef struct at88sc_identifycation
{
    unsigned char       answer_to_reset[at88sc_answer_to_reset_size];
    unsigned char       fab_code[at88sc_fab_code_size];
    unsigned char       mtz[at88sc_mtz_size];
    unsigned char       card_manufacturer_code[at88sc_card_manufacturer_code_size];
}_at88sc_identifycation;


/*
-------------------------read only-------------------------
[ $0B ][ $1B ][ $2B ][ $3B ][ $4B ][ $5B ][ $6B ][ $7B ]
$10 [Lot History Code Read Only                            ] */
#define at88sc_lot_history_code_addr                        0x10
#define at88sc_lot_history_code_size                        0x08


/*
-------------------------Access Control---------------------
    [ $0B ][ $1B ][ $2B ][ $3B ][ $4B ][ $5B ][ $6B ][ $7B ]
$18 [DCR  ][Identification Number Nc                       ]
$20 [AR0  ][PR0  ][AR1  ][PR1  ][AR2  ][PR2  ][AR3  ][PR3  ]
$28 [Reserved                                              ]                     
$30 [Reserved                                              ]
$38 [Reserved                                              ]
$40 [Issuer Code                                           ]
$48 [Issuer Code                                           ] */
/* Device Configuration Register (DCR) */
#define at88sc_dcr_addr                                     0x18
#define at88sc_dcr_size                                     0x01
#define at88sc_dcr_sme_bit_index                            7   /* Supervisor Mode Enable */
#define at88sc_dcr_ucr_bit_index                            6   /* Unlimited Checksum Reads */
#define at88sc_dcr_uat_bit_index                            5   /* Unlimited Authentication Trials */
#define at88sc_dcr_eat_bit_index                            4   /* Eight Trials Allowed */
#define at88sc_dcr_cs_bit_index                             0   /* Programmable Chip Select (only relevant in synchronous protocol), four most significant bits (b4 每 b7) of every command comprise the Chip Select Address.*/
#define at88sc_dcr_cs_bit_counts                            4   /* 4 bits */
#define at88sc_identify_addr                                0x19
#define at88sc_identify_size                                0x07
#define at88sc_ar_pr_addr                                   0x20
#define at88sc_ar_pr_item_size                              0x02
#define at88sc_ar_pr_item_counts                            0x04
#define at88sc_ar_pr_item_max_counts                        0x10    /* reserved 12 item in at88sc */
#define at88sc_ar_index                                     0x00    /* pos in ar_pr item */
#define at88sc_ar_size                                      0x01
/* Access Registers */
/* 
    Password Mode
    PM0 PM1 Access
    1   1 No Password required
    1   0 Write Password required
    0   * Read and Write Passwords required
    Authentication Mode
    AM1 AM0 Access
    1   1 No Authentication required
    1   0 Authentication for Write
    0   1 Normal Authentication Mode
    0   0 Dual Access Mode */
#define at88sc_ar_pm_bit_index                              6   /* Password Mode */
#define at88sc_ar_pm_bit_counts                             2
#define at88sc_ar_am_bit_index                              4   /* Authentication Mode */
#define at88sc_ar_am_bit_counts                             2
#define at88sc_ar_er_bit_index                              3   /* ER 每 Encryption Required */
#define at88sc_ar_wlm_bit_index                             2   /* WLM 每 Write Lock Mode */
#define at88sc_ar_mdf_bit_index                             1   /* MDF 每 Modify Forbidden */
#define at88sc_ar_pgo_bit_index                             0   /* PGO 每 Program Only, just allow from 1 change to 0 */
#define at88sc_pr_index                                     0x01    /* pos in ar_pr item */
#define at88sc_pr_size                                      0x01
/* Password/Key Registers */
#define at88sc_pr_ak_bit_index                              6   /* AK(1:0) 每 Authentication Key, These bits define which of the four secret seeds G0-G3 */
#define at88sc_pr_ak_bit_counts                             2
#define at88sc_pr_pok_bit_index                             4   /* POK(1:0) 每 Program Only Key */
#define at88sc_pr_pok_bit_counts                            2   
#define at88sc_pr_res                                       3   /* Reserved */
#define at88sc_pr_pws_bit_index                             0   /* PW(2:0) 每 Password Set */
#define at88sc_pr_pws_bit_counts                            3
#define at88sc_0104_reserved_size                           0x18
#define at88sc_issuer_code_addr                             0x40
#define at88sc_issuer_code_size                             0x10

typedef struct at88sc_access_control
{
    unsigned char   dcr[at88sc_dcr_size];
    unsigned char   identify[at88sc_identify_size];
    struct  
    {
        unsigned char   ar, pr;
    }arpr[at88sc_ar_pr_item_max_counts];  /* 0104 used first 4 items */
    unsigned char   issuer_code[at88sc_issuer_code_size];
}_at88sc_access_control;


/*
-------------------------Cryptography-----------------------
    [ $0B ][ $1B ][ $2B ][ $3B ][ $4B ][ $5B ][ $6B ][ $7B ]
$50 [AAC0 ][Cryptogram C0                                  ]
$58 [Session Encryption Key S0                             ]
$60 [AAC1 ][Cryptogram C1                                  ]
$68 [Session Encryption Key S1                             ]
$70 [AAC2 ][Cryptogram C2                                  ]
$78 [Session Encryption Key S2                             ]
$80 [AAC3 ][Cryptogram C3                                  ]
$88 [Session Encryption Key S3                             ] */
#define at88sc_cryptography_addr                            0x50
#define at88sc_cryptography_item_size                       0x10
#define at88sc_cryptography_item_counts                     0x04
#define at88sc_aac_index                                    0x00    /* pos in cryptography item */
#define at88sc_aac_size                                     0x01
#define at88sc_cryptogram_c_index                           0x01    /* pos in cryptography item */
#define at88sc_cryptogram_c_size                            0x07
#define at88sc_session_encryption_key_s_index               0x08    /* pos in cryptography item */
#define at88sc_session_encryption_key_s_size                0x08

/*
-------------------------Secret-----------------------------
    [ $0B ][ $1B ][ $2B ][ $3B ][ $4B ][ $5B ][ $6B ][ $7B ]
$90 [Secret Seed G0                                        ]
$98 [Secret Seed G1                                        ]
$A0 [Secret Seed G2                                        ]
$A8 [Secret Seed G3                                        ] */
#define at88sc_secret_addr                                  0x90
#define at88sc_secret_item_size                             0x08
#define at88sc_secret_item_counts                           0x04

/*
configure zone read password section must raise a new call,
don't read from 0~0xFF!!!
-------------------------password---------------------------
    [ $0B ][ $1B ][ $2B ][ $3B ][ $4B ][ $5B ][ $6B ][ $7B ]
$B0 [PAC  ][Write 0            ][PAC  ][Read 0             ]
$B8 [PAC  ][Write 1            ][PAC  ][Read 1             ]
$C0 [PAC  ][Write 2            ][PAC  ][Read 2             ]
$C8 [reserved in AT88SC 0104                               ]
$D0 [reserved in AT88SC 0104                               ]
$D8 [reserved in AT88SC 0104                               ]
$E0 [reserved in AT88SC 0104                               ]
$E8 [PAC  ][Write 7            ][PAC  ][Read 7             ]
*/
#define at88sc_password_addr                                0xB0
#define at88sc_password_item_size                           0x08
#define at88sc_password_item_counts                         0x08
#define at88sc_password_key_no                              0x07
#define at88sc_password_write_pac_index                     0x00    /* pos in password item [*WRITE_PAC,WRITE_PWD,READ_PAC,READ_PWD] */
#define at88sc_password_read_pac_index                      0x04    /* pos in password item [WRITE_PAC,WRITE_PWD,*READ_PAC,READ_PWD] */
#define at88sc_password_pac_size                            0x01
#define at88sc_password_data_write_index                    0x01    /* pos in password item [WRITE_PAC,*WRITE_PWD,READ_PAC,READ_PWD] */
#define at88sc_password_data_read_index                     0x05    /* pos in password item [WRITE_PAC,WRITE_PWD,READ_PAC,*READ_PWD] */
#define at88sc_password_data_size                           0x03

/*
    CryptoMemory Synchronous Command Set
---------------------------------------------------------------------------------------------------
[Command Description                          ] [Command] [Addr 1] [Addr 2] [N       ] [Data (N)  ]
---------------------------------------------------------------------------------------------------
[Write |  Normal(AT88SC0104C-AT88SC1616C)     ] [$B0    ] [addr  ] [addr  ] [N ≒ $10] [N bytes   ]
[User  |  Normal(AT88SC3216C, AT88SC6416C)    ] [$B0    ] [addr  ] [addr  ] [N ≒ $40] [N bytes   ]
[Zone  |  Normal(AT88SC12816C, AT88SC25616C)  ] [$B0    ] [addr  ] [addr  ] [N ≒ $80] [N bytes   ]
[      |  with Anti-Tearing (all devices)     ] [$B0    ] [addr  ] [addr  ] [N ≒ $08] [N bytes   ]
---------------------------------------------------------------------------------------------------
[Read User Zone                               ] [$B2    ] [addr  ]  [addr ] [N                    ]
---------------------------------------------------------------------------------------------------
[      | Config (AT88SC0104C-AT88SC1616C)     ] [$B4    ] [$00   ] [addr  ] [N ≒ $10] [N bytes   ]
[      | Config (AT88SC3216C, AT88SC6416C)    ] [$B4    ] [$00   ] [addr  ] [N ≒ $40] [N bytes   ]
[Write | Config (AT88SC12816C, AT88SC25616C)  ] [$B4    ] [$00   ] [addr  ] [N ≒ $80] [N bytes   ]
[Config| Write Fuses                          ] [$B4    ] [$01   ] [fuseid] [$00     ] [          ]
[System| Send Checksum                        ] [$B4    ] [$02   ] [$00]    [$02     ] [2 bytes   ]
[Zone  | Set User Zone                        ] [$B4    ] [$03   ] [zone]   [$00     ] [          ]
[      | Write Config Zone with Anti-Tearing  ] [$B4    ] [$08   ] [addr]   [N ≒ $08] [N bytes   ]
[      | Set User Zone with Anti-Tearing      ] [$B4    ] [$0B   ] [zone]   [$00     ] [          ]
---------------------------------------------------------------------------------------------------
[System| Read Config Zone                     ] [$B6    ] [$00   ] [addr  ] [N       ] [          ]
[Read  | Read Fuse Byte                       ] [$B6    ] [$01   ] [$00   ] [$01     ] [          ]
[      | Read Checksum                        ] [$B6    ] [$02   ] [$00   ] [$02     ] [          ]
---------------------------------------------------------------------------------------------------
[Verify| Verify Authentication                ] [$B8    ] [$0X   ] [$00   ] [$10     ] [8 random bytes + 8 challenge bytes, X= key set (0-3)]
[Crypto| Verify Encryption                    ] [$B8    ] [$1X   ] [$00   ] [$10     ] [8 random bytes + 8 challenge bytes, X= key set (0-3)]
---------------------------------------------------------------------------------------------------
[Verify| Write Password                       ] [$BA    ] [$0X   ] [$00   ] [$03     ] [3 byte password, X=password set (0-7)]
[Passwd| Read Password                        ] [$BA    ] [$1X   ] [$00   ] [$03     ] [3 byte password, X=password set (0-7)]
*/
#define at88sc_cmd_write_user_zone                          0xb0
#define at88sc_cmd_read_user_zone                           0xb2
#define at88sc_cmd_system_write                             0xb4
#define at88sc_cmd_system_read                              0xb6
#define at88sc_cmd_verify_crypto                            0xb8
#define at88sc_cmd_verify_password                          0xba
#define at88sc_addr_high_verify_authentication_base         0x00
#define at88sc_addr_high_verify_encryption_base             0x10
#define at88sc_addr_high_verify_write_password_base         0x00
#define at88sc_addr_high_verify_read_password_base          0x10
#define at88sc_addr_high_config_zone                        0x00
#define at88sc_addr_high_fuse                               0x01
#define at88sc_addr_high_check_sum                          0x02
#define at88sc_addr_high_set_user_zone                      0x03
#define at88sc_addr_high_write_config_zone_with_anti_tearing    0x08
#define at88sc_addr_high_set_user_zone_with_anti_tearing    0x0b

/*
------------------------------------------------
Fuse Byte Definition
------------------------------------------------
[F7  ][F6  ][F5  ][F4  ][F3  ][F2  ][F1  ][F0  ]
------------------------------------------------
[resv][resv][resv][resv][SEC ][PER ][CMA ][FAB ]
*/
#define at88sc_fuse_sec_bit_index                           0x03
#define at88sc_fuse_per_bit_index                           0x02
#define at88sc_fuse_cma_bit_index                           0x01
#define at88sc_fuse_fab_bit_index                           0x00

/*
-------------------
Fuse Writing
-------------------
[Fuse][Fuse ID]
-------------------
[FAB ][$06    ]
[CMA ][$04    ]
[PER ][$00    ]
*/
#define at88sc_fuse_id_fab                                  0x06
#define at88sc_fuse_id_cma                                  0x04
#define at88sc_fuse_id_per                                  0x00

/*
-----------------Communication Security Modes-----------------------
    [Mode                  ][Configuration Data][User Data ][Passwords Data][Integrity Check]
    -----------------------------------------------------------------------------------------
    [Standard/Password     ][clear             ][clear     ][clear         ][n/a            ]
    [Authentication        ][clear             ][clear     ][encrypted     ][MAC            ]
    [Encryption            ][clear             ][encrypted ][encrypted     ][MAC            ]
    -----------------------------------------------------------------------------------------
    Configuration data includes the entire configuration memory except the passwords.
    MAC: Message Authentication Code.
*/


#define at88sc_0104c_user_zone_size                         0x20
#define at88sc_0104c_write_size_max                         0x10
#define at88sc_0104c_read_size_max                          0x20
#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

#endif /* !defined(__at88sc_datasheet_h__) */

