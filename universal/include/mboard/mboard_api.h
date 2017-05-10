#if !defined(__mboard_api_h__)
#define __mboard_api_h__

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#if !defined(__mpin_cfg_type_magic)
#define __mpin_cfg_type_magic 0xbdbf9a11
#pragma pack(push, 1)
typedef struct mpin_cfg
{
    int32_t             pin;    /* pin number of chip */
    struct pack_lenstr  type;   /* gpio|adc */
    int32_t             id;     /* gpio id/ adc id */
    struct pack_lenstr  name;   /* pin name */
    int32_t             ev;     /* effective value */
    int32_t             ev_l;   /* effective value low threshold */
    int32_t             ev_h;   /* effective value high threshold */
}_mpin_cfg;
#pragma pack(pop)
#elif (__mpin_cfg_type_magic != 0xbdbf9a11)
#error mpin_cfg type defined but not match
#endif /* !defined(__mpin_cfg_type_magic) */


#if !defined(__mdevice_param_type_magic)
#define __mdevice_param_type_magic 0x169090d4
#pragma pack(push, 1)
typedef struct mdevice_param
{
    struct pack_lenstr  n;  /*  */
    struct pack_lenstr  v;  /*  */
}_mdevice_param;
#pragma pack(pop)
#elif (__mdevice_param_type_magic != 0x169090d4)
#error mdevice_param type defined but not match
#endif /* !defined(__mdevice_param_type_magic) */


#if !defined(__mdevice_cfg_type_magic)
#define __mdevice_cfg_type_magic 0xdc7ab406
#pragma pack(push, 1)
typedef struct mdevice_cfg
{
    struct pack_lenstr      type;                   /* device type */
    struct pack_lenstr      subtype;                /* device sub type */
    uint32_t                pins_counts;            /* pins counts */
    struct mpin_cfg         pack_def_pointer(pins); /* [0-100] */
    uint32_t                p_counts;               /* p counts */
    struct mdevice_param    pack_def_pointer(p);    /* [0-100] */
}_mdevice_cfg;
#pragma pack(pop)
#elif (__mdevice_cfg_type_magic != 0xdc7ab406)
#error mdevice_cfg type defined but not match
#endif /* !defined(__mdevice_cfg_type_magic) */


#if !defined(__mboard_cfg_type_magic)
#define __mboard_cfg_type_magic 0x27aeeb48
#pragma pack(push, 1)
typedef struct mboard_cfg
{
    uint32_t            devices_counts;             /* devices counts */
    struct mdevice_cfg  pack_def_pointer(devices);  /* [0-100] */
}_mboard_cfg;
#pragma pack(pop)
#elif (__mboard_cfg_type_magic != 0x27aeeb48)
#error mboard_cfg type defined bu
#endif /* !defined(__mboard_cfg_type_magic) */

#define MBOARD_PIN_VALUE_LONG       0
#define MBOARD_PIN_VALUE_BOOLEAN    1
#define MBOARD_PIN_VALUE_DIRECTION  2

#define mboard_pin_write_long( handle, pin, value ) mboard_pin_write( handle, pin, value, MBOARD_PIN_VALUE_LONG )
#define mboard_pin_write_boolean( handle, pin, value ) mboard_pin_write( handle, pin, value, MBOARD_PIN_VALUE_BOOLEAN )
#define mboard_pin_write_direction( handle, pin, value ) mboard_pin_write( handle, pin, value, MBOARD_PIN_VALUE_DIRECTION )
#define mboard_pin_write_boolean_and( handle, pin, ref_pin, value ) mboard_pin_write_and( handle, pin, ref_pin, value, MBOARD_PIN_VALUE_BOOLEAN )

#define mboard_pin_read_long( handle, pin, value ) mboard_pin_read( handle, pin, value, MBOARD_PIN_VALUE_LONG )
#define mboard_pin_read_boolean( handle, pin, value ) mboard_pin_read( handle, pin, value, MBOARD_PIN_VALUE_BOOLEAN )

extern struct mboard_cfg * mboard_cfg_load();
extern long mboard_cfg_unload( struct mboard_cfg *cfg );
extern void *mboard_create();
extern long mboard_destroy( void *handle );
extern long mboard_pin_write( void *handle, long pin, long value, long value_type );
extern long mboard_pin_read( void *handle, long pin, long *value, long value_type  );
extern long mboard_pin_get_write_value( void *handle, long pin, long *value);
extern long mboard_pin_write_and( void *handle, long pin, long pin_ref, long value, long value_type );

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */

#endif
