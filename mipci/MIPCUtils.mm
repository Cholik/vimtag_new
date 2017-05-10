//
//  MIPCUtils.m
//  ipcti
//
//  Created by MagicStudio on 12-8-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import <Foundation/NSURLRequest.h>
#import <Foundation/NSURLResponse.h>
#import "MIPCUtils.h"
#import "mdev_id/mdev_id.h"
#import "mpack_file/mpack_file.h"
#import "mencrypt/mencrypt.h"
#import "mlicense/mlicense.h"


#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "sys/utsname.h"

#import "SystemConfiguration/CaptiveNetwork.h"
#import "mipc_data_object.h"


#include <stdio.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <string.h>
#include <TargetConditionals.h>

/* cacs_dh_req.js?hfrom_handle=768987&dbnum_prime=791658605174853458830696113306796803&droot_num=5&dkey_a2b=529845209391588155162253691910789776&dtid=0x10
 
 http://hehehi.com:6080/ccm/cacs_login_req.js?hfrom_handle=768988&dlid=0x1c&duser=1JFIEGAAAAAFQ&dpass=41ce01dd249c31ed1c11f6cd31dd2356&dsess_req=1
 
 *server http://hehehi.com:6080/ccm/ccm_devs_get.js?hfrom_handle=768990&dsess=1&dsess_Nid=MHBC50uYNJ34vufJQSU3hwNCAWJhDg&dsess_SerialNumber=ms%5f001&dStart=0&dCounts=20
 
 http://hehehi.com:6080/ccm/ccm_profiles_get_ack.js?hfrom_handle=768997&dsess=1&dsess_Nid=MHK%5fMG6CF713yLwvqmhqEZ9CAWdhDg&dsess_SerialNumber=1JFIEGAAAAAFQ
 
 **http://hehehi.com:6080/ccm/CcmMediaGetRequest.js?hfrom_handle=768998&dsess=1&dsess_Nid=MBY3xXJT%2esW%2e2sjuSJciROVCAWhhDg&dsess_SerialNumber=1JFIEGAAAAAFQ
 
 http://hehehi.com:6080/ccm/ccm_play.js?hfrom_handle=768999&dsess=1&dsess_Nid=MHFd%2elfH8MtHXsvdcwmTDetCAWlhDg&dsess_SerialNumber=1JFIEGAAAAAFQ&dStreamSetup=1&dStreamSetup_Stream=RTP%5fUnicast&dStreamSetup_Transport=1&dStreamSetup_Transport_Protocol=rtdp&dProfileToken=p1
 
 */

#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */
    
    //unsigned char   pass_md5[16];
    NSString            *mipc__config_file_name = nil;
    struct mipci_conf   *mipc__config = NULL;
    char mipc__config_def_xml[] =
    "<mipci_conf type=\"mipci_conf\">\r\n"
    "  <user           type=\"lenstr\"/>\r\n"
    "  <password       type=\"lenstr\"/>\r\n"
    "  <password_md5   type=\"lenstr\"/>\r\n"
    "  <server         type=\"lenstr\"/>\r\n"
    "  <profile_id     type=\"uint32\"   info=\"profile id, 0:auto 1:160x90 2:320x180 3:640x360 4:1280x720\"/>\r\n"
    "  <dis_audio          type=\"uint32\"/>\r\n"
    "  <dis_vibrate        type=\"uint32\"/>\r\n"
    "  <buf                type=\"uint32\" info=\"0:0s 1:5s 2:10s 3:15s\"\r\n/>"
    "  <version            type=\"lenstr\"/>\r\n"
    "  <exSrv              type=\"lenstr\"/>\r\n"
    "  <exSignal_Srv       type=\"lenstr\"/>\r\n"
    "  <ring               type=\"uint32\"/>\r\n"
    "  <auto_login         type=\"uint32\"/>\r\n"
    "  <user_online        type=\"uint32\"/>\r\n"
    "  <home_url           type=\"lenstr\"/>\r\n"
    "  <faq_url            type=\"lenstr\"/>\r\n"
    "  <report_url         type=\"lenstr\"/>\r\n"
    "  <home_set           type=\"uint32\"/>\r\n"
    "  <faq_set            type=\"uint32\"/>\r\n"
    "</mipci_conf>\r\n";
    
    NSString            *mipc__server=nil;
    unsigned long       mipc__from_handle = 0, mipc__seq = 0;
    NSString            *mipc__share_key = nil;
    NSString            *mipc__server_serialNumber = nil;
    uint64_t            mipc__tid = 0, mipc__lid = 0, mipc__sid = 0;
    struct len_str      share_key_2 = {0}, share_key = {0};
    
    NSString *MIPC__url_encode(NSString *param)
    {
        CFStringRef cfString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)param, nil, nil, kCFStringEncodingUTF8);
        NSString    *result = [NSString stringWithFormat:@"%@", (__bridge NSString*)cfString];
        CFRelease(cfString);
        return result;
    }
    
    NSString    *MIPC_GetFileFullPath(NSString *subPath)
    {
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        return [documentsDirectory stringByAppendingPathComponent:subPath];
    }
    
    
    void MIPC__PrepareConfigFileName()
    {
        if(nil == mipc__config_file_name)
        {
            mipc__config_file_name = MIPC_GetFileFullPath(@"config.js");
        }
    }
    
    struct mipci_conf   *MIPC_ConfigLoad()
    {
        if(NULL == mipc__config)
        {
            MIPC__PrepareConfigFileName();
            if([[NSFileManager defaultManager] fileExistsAtPath:mipc__config_file_name])
            {/* file exist */
                mipc__config = (struct mipci_conf*)pack_file_load_json2(mipc__config_def_xml,(char*)"mipci_conf", (char*)[mipc__config_file_name UTF8String]);
            }
        }
        
        return mipc__config;
    }
    
    long MIPC_ConfigSave(struct mipci_conf *conf)
    {
        MIPC__PrepareConfigFileName();
        pack_file_save_json2(mipc__config_def_xml, (char*)"mipci_conf", conf, (char*)[mipc__config_file_name UTF8String]);
        if(mipc__config)
        {
            pack_file_unload(mipc__config);
            mipc__config = NULL;
        }
        return 0;
    }
    
    long MIPC_ParseLineParams(struct len_str *text, struct len_str *id_value, struct len_str *password_value, struct len_str *password_md5_value, struct len_str *wifi_value)
    {
        struct len_str  sIDFlag = {len_str_def_const("ID:")},
        sSNFlag = {len_str_def_const("SN:")},
        sPasswordFlag = {len_str_def_const("Password:")},
        sPasswordMD5Flag = {len_str_def_const("PasswordMD5:")},
        sTemp = *text,
        sWifiFlag = {len_str_def_const("s:")};
        
        id_value->data = NULL;
        id_value->len = 0;
        password_value->data = NULL;
        password_value->len = 0;
        wifi_value->data = NULL;
        wifi_value->len = 0;
        
        if(password_md5_value)
        {
            password_md5_value->data = NULL;
            password_md5_value->len = 0;
        }
        if(0 == len_str_case_begin(&sTemp, &sIDFlag))
        {
            id_value->data = sTemp.data + sIDFlag.len;
            while((sTemp.len > (sIDFlag.len + id_value->len))
                  && (sTemp.data[sIDFlag.len + id_value->len] != '\r')
                  && (sTemp.data[sIDFlag.len + id_value->len] != '\n')
                  && (sTemp.data[sIDFlag.len + id_value->len] != ' '))
            {
                ++id_value->len;
            }
            sTemp.data += sIDFlag.len + id_value->len;
            sTemp.len  -= sIDFlag.len + id_value->len;
            if(sTemp.len && (sTemp.data[0] == '\r')){ --sTemp.len; ++sTemp.data; };
            if(sTemp.len && (sTemp.data[0] == '\n')){ --sTemp.len; ++sTemp.data; };
            if(sTemp.len && (sTemp.data[0] == ' ')){ --sTemp.len; ++sTemp.data; };
        }
        if(0 == len_str_case_begin(&sTemp, &sSNFlag))
        {
            id_value->data = sTemp.data + sSNFlag.len;
            while((sTemp.len > (sSNFlag.len + id_value->len))
                  && (sTemp.data[sSNFlag.len + id_value->len] != '\r')
                  && (sTemp.data[sSNFlag.len + id_value->len] != '\n'))
            {
                ++id_value->len;
            }
            sTemp.data += sSNFlag.len + id_value->len;
            sTemp.len  -= sSNFlag.len + id_value->len;
            if(sTemp.len && (sTemp.data[0] == '\r')){ --sTemp.len; ++sTemp.data; };
            if(sTemp.len && (sTemp.data[0] == '\n')){ --sTemp.len; ++sTemp.data; };
        }
        /* for QR-Print some device bug. */
        else if(0 == len_str_case_begin_const(&sTemp, "1jfieg"))
        {
            long          id_len = 0;
            unsigned char id_buf[8];
            id_value->data = sTemp.data/* + sIDFlag.len */;
            while((sTemp.len > (/*sIDFlag.len + */id_value->len))
                  && (sTemp.data[/* sIDFlag.len + */id_value->len] != '\r')
                  && (sTemp.data[/* sIDFlag.len + */id_value->len] != '\n'))
            {
                ++id_value->len;
            }
            if((13 != id_value->len)
               ||(7 != (id_len = dev_id_from_sn((unsigned long)id_value->len, (unsigned char*)id_value->data,
                                                (unsigned long)sizeof(id_buf), (unsigned char*)&id_buf[0])))
               ||('I' != id_buf[0])||('P' != id_buf[1])||('C' != id_buf[2]))
            {/* invalid password */
                id_value->len = 0;
                return -1;
            }
            sTemp.data += /* sIDFlag.len + */id_value->len;
            sTemp.len  -= /* sIDFlag.len + */id_value->len;
            if(sTemp.len && (sTemp.data[0] == '\r')){ --sTemp.len; ++sTemp.data; };
            if(sTemp.len && (sTemp.data[0] == '\n')){ --sTemp.len; ++sTemp.data; };
        }
        
        if(0 == len_str_case_begin(&sTemp, &sPasswordFlag))
        {
            password_value->data = sTemp.data + sPasswordFlag.len;
            while((sTemp.len > (sPasswordFlag.len + password_value->len))
                  && (sTemp.data[sPasswordFlag.len + password_value->len] != '\r')
                  && (sTemp.data[sPasswordFlag.len + password_value->len] != '\n'))
            {
                ++password_value->len;
            }
            sTemp.data += sPasswordFlag.len + password_value->len;
            sTemp.len  -= sPasswordFlag.len + password_value->len;
        }
        
        if(0 == len_str_case_begin(&sTemp, &sPasswordMD5Flag))
        {
            password_md5_value->data = sTemp.data + sPasswordMD5Flag.len;
            while((sTemp.len > (sPasswordMD5Flag.len + password_md5_value->len))
                  && (sTemp.data[sPasswordMD5Flag.len + password_md5_value->len] != '\r')
                  && (sTemp.data[sPasswordMD5Flag.len + password_md5_value->len] != '\n'))
            {
                ++password_md5_value->len;
            }
            sTemp.data += sPasswordMD5Flag.len + password_md5_value->len;
            sTemp.len  -= sPasswordMD5Flag.len + password_md5_value->len;
        }
        if (0 == len_str_case_begin(&sTemp, &sWifiFlag)) {
            wifi_value->data = sTemp.data + sWifiFlag.len;
            while((sTemp.len > (sWifiFlag.len + wifi_value->len))
                  && (sTemp.data[sWifiFlag.len + wifi_value->len] != '\r')
                  && (sTemp.data[sWifiFlag.len + wifi_value->len] != '\n'))
            {
                ++wifi_value->len;
            }
            sTemp.data += sWifiFlag.len + wifi_value->len;
            sTemp.len  -= sWifiFlag.len + wifi_value->len;
        }
        return 0;
    }
    
    
    static long mipc__language_inited = 0;
    NSDictionary    *mpic__language_dic = nil;
    
    NSString *MIPC_GetLanguageString(char* type, char *name)
    {
        if(0 == mipc__language_inited)
        {
            
            mipc__language_inited = 1;
            mpic__language_dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"mcs_record",    @"msg.record",
                                   @"mcs_config",    @"msg.config",
                                   @"mcs_talk",      @"msg.talk",
                                   @"mcs_play",      @"msg.play",
                                   @"mcs_sdcord",    @"msg.sdcard",
                                   @"mcs_reboot",    @"msg.reboot",
                                   @"mcs_upgrade",   @"msg.upgrade",
                                   @"mcs_device",    @"msg.device",
                                   @"mcs_alert",     @"msg.alert",
                                   @"mcs_io",        @"msg.io",
                                   @"mcs_motion_alert",@"msg.motion",
                                   @"mcs_pir",       @"msg.pir",
                                   @"mcs_isp",       @"msg.isp",
                                   @"mcs_snapshot",  @"msg.CcmGetSnapshotUri",
                                   @"mcs_start",     @"msg.start",
                                   @"mcs_stop",      @"msg.stop",
                                   @"mcs_full",      @"msg.full",
                                   @"mcs_inserted",    @"msg.insert",
                                   @"mcs_finish",    @"msg.finish",
                                   @"mcs_motion_alert", @"msg.motion_alert",
                                   @"mcs_snapshot",  @"msg.snapshot",
                                   @"",              @"msg.segment",
                                   @"mcs_online",    @"msg.online",
                                   @"mcs_offline",   @"msg.offline",
                                   @"mcs_erasing",     @"msg.erase",
                                   @"mcs_writing",     @"msg.write",
                                   @"mcs_fault",   @"msg.failure",
                                   @"mcs_nick",      @"msg.CcmSetDeviceNick",
                                   @"mcs_talk",   @"msg.CcmSetAudioOutputConfiguration",
                                   @"mcs_mic",       @"msg.CcmSetAudioSourceConfiguration",
                                   @"mcs_modify_password",   @"msg.CcmSetUser",
                                   @"mcs_osd",        @"msg.CcmSetOsd",
                                   @"mcs_network",    @"msg.CcmSetNetwokInfo",
                                   @"mcs_audio_setting",     @"msg.CcmSetAudioEncoderConfiguration",
                                   @"mcs_video",          @"msg.CcmSetVideoEncoderConfiguration",
                                   @"mcs_alert_on",       @"msg.alerter",
                                   @"mcs_input_nick" ,    @"msg.nick",
                                   @"mcs_network",        @"msg.network",
                                   @"mcs_osd",            @"msg.osd",
                                   @"mcs_audio_setting",  @"msg.audio",
                                   @"mcs_video",          @"msg.video",
                                   @"mcs_talk",           @"msg.speaker",
                                   @"mcs_mic",            @"msg.mic",
                                   @"mcs_set_time",       @"msg.date",
                                   @"mcs_mounted",        @"msg.mount",
                                   @"mcs_unmounted",      @"msg.umount",
                                   @"mcs_repairing",      @"msg.repairing",
                                   @"mcs_formating",      @"msg.formating",
                                   @"",                   @"msg.init",
                                   @"mcs_download",       @"msg.download",
                                   @"mcs_motion_alert",   @"motion_alert",
                                   @"mcs_i_o_alarm",      @"io_alert",
                                   NSLocalizedString(@"1",nil),@"UTC+01:00",
                                   NSLocalizedString(@"2",nil),@"UTC+02:00",
                                   NSLocalizedString(@"3",nil),@"UTC+03:00",
                                   NSLocalizedString(@"4",nil),@"UTC+03:30",
                                   NSLocalizedString(@"5",nil),@"UTC+04:00",
                                   NSLocalizedString(@"6",nil),@"UTC+05:30",
                                   NSLocalizedString(@"7",nil),@"UTC+05:45",
                                   NSLocalizedString(@"8",nil),@"UTC+08:00",
                                   NSLocalizedString(@"9",nil),@"UTC+09:00",
                                   NSLocalizedString(@"0",nil),@"UTC+10:00",
                                   NSLocalizedString(@"11",nil),@"UTC-01:00",
                                   NSLocalizedString(@"12",nil),@"UTC-03:00",
                                   NSLocalizedString(@"12",nil),@"UTC-04:00",
                                   NSLocalizedString(@"13",nil),@"UTC-04:30",
                                   NSLocalizedString(@"14",nil),@"UTC-05:00",
                                   NSLocalizedString(@"15",nil),@"UTC-07:00",
                                   NSLocalizedString(@"16",nil),@"UTC-08:00",
                                   NSLocalizedString(@"mcs_sat",nil),@"UTC-09:00",
                                   NSLocalizedString(@"23",nil),@"UTC-10:00",
                                   NSLocalizedString(@"3242",nil),@"UTC00:00",
                                   nil];
        }
        
        NSString *s_name = [NSString stringWithFormat:@"%s%s",type,name];
        NSString *ret = [mpic__language_dic objectForKey:s_name];
        return ret?ret:[NSString stringWithUTF8String:name];
    }
    
    struct json_object *json_get_field(struct json_object *field_array, unsigned long name_len, char *name)
    {
        struct json_object  *child_first = (field_array && (field_array->type == ejot_array))?field_array->v.array.list:NULL, *child = child_first;
        struct len_str s_name = {0}, s_check_name = {name_len, name};
        if(child)
        {
            do
            {
                //                if (OLDVER)
                //                    json_get_child_string(child, "name", &s_name);
                //                else
                json_get_child_string(child, "n", &s_name);
                if(0 == len_str_cmp(&s_check_name, &s_name))
                {
                    //                    if (OLDVER)
                    //                        return json_get_child_by_name(child, NULL, len_str_def_const("value"));
                    //                    else
                    return json_get_child_by_name(child, NULL, len_str_def_const("v"));
                }
            }while ((child = child->in_parent.next) != child_first);
            
        }
        return NULL;
    }
    
    NSString *json_get_field_string(struct json_object *field_array, unsigned long name_len, char *name)
    {
        struct json_object  *value = json_get_field(field_array, name_len, name);
        struct len_str      s_value = {0};
        return (value && (0 == json_get_string(value, &s_value)) && s_value.len)?[NSString stringWithUTF8String:s_value.data]:@"";
    }
    
    long  json_get_field_long(struct json_object *field_array, unsigned long name_len, char *name)
    {
        struct json_object  *value = json_get_field(field_array, name_len, name);
        long      l_value = 0;
        return (value && (0 == json_get_long(value, &l_value)))?l_value:0;
    }
    
    NSString *MIPC_GetWifiAddress(void)
    {
        int                 mib[6];
        size_t              len;
        char                *buf;
        unsigned char       *ptr;
        struct if_msghdr    *ifm;
        struct sockaddr_dl  *sdl;
        
        mib[0] = CTL_NET;
        mib[1] = AF_ROUTE;
        mib[2] = 0;
        mib[3] = AF_LINK;
        mib[4] = NET_RT_IFLIST;
        
        if ((mib[5] = if_nametoindex("en0")) == 0) {
            print_err(@"Error: if_nametoindex error\n");
            return nil;
        }
        
        if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
            print_err(@"Error: sysctl, take 1\n");
            return nil;
        }
        
        if ((buf = (char*)malloc(len)) == NULL) {
            print_err(@"Could not allocate memory. error!\n");
            return nil;
        }
        
        if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
            print_err(@"Error: sysctl, take 2");
            free(buf);
            return nil;
        }
        
        ifm = (struct if_msghdr *)buf;
        sdl = (struct sockaddr_dl *)(ifm + 1);
        ptr = (unsigned char *)LLADDR(sdl);
        NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                               *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
        free(buf);
        
        return outstring;
    }
    
    NSString *MIPC_GetWifiSSID(NSString **bssid/* [out] */)
    {
        NSString        *desc, *s_temp, *ssid = nil;
        NSArray         *ifs = (__bridge id)CNCopySupportedInterfaces();
        NSDictionary    *info = nil;
        *bssid = nil;
        for (NSString *ifnam in ifs)
        {
            info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            if(info)
            {
                desc = [info description];
                //if([info count]){ break; };
                print_info(@"info: MIPC_GetConnectedIPCDevID() with %@", desc);
                s_temp = [info objectForKey:@"BSSID"];
                if(s_temp && [s_temp isKindOfClass:[NSString class]] && s_temp.length)
                {
                    *bssid = [NSString stringWithString:s_temp];
                }
                s_temp = [info objectForKey:@"SSID"];
                if(s_temp && [s_temp isKindOfClass:[NSString class]] && s_temp.length)
                {
                    ssid   = [NSString stringWithString:s_temp];
                }
            }
            if(*bssid && ssid)
            {
                break;
            }
        }
        return ssid;
    }
    
    NSString* MIPC_GetConnectedIPCDevID(void)
    {
        NSString        *bssid = nil, *ssid = MIPC_GetWifiSSID(&bssid), *devid = nil;
        struct len_str  s_ssid;
        unsigned char   dev_id_buf[8];
        struct netx_sockaddr  addr;
        unsigned char   *uc_addr = (unsigned char*)&addr;
        if(ssid && ssid.length)
        {
            s_ssid.len = ssid?ssid.length:0;
            s_ssid.data = ssid?(char*)ssid.UTF8String:NULL;
            if(0 == len_str_case_begin_const(&s_ssid, "ipc"))
            {
                if((0 < dev_id_from_sn((unsigned long)s_ssid.len - sizeof("ipc") - 1,
                                       (unsigned char*)(s_ssid.data + sizeof("ipc") - 1),
                                       (unsigned long)sizeof(dev_id_buf),
                                       (unsigned char*)&dev_id_buf[0]))
                   && (0 == netx_get_local_ip_2(&addr))
                   && (192 == uc_addr[0]) && (168 == uc_addr[1]) && (188 == uc_addr[2]))
                {/* is valid dev-id */
                    devid = s_ssid.len ? [NSString stringWithUTF8String:(s_ssid.data + sizeof("ipc") - 1)] : nil;
                }
            }
        }
        return devid;
    }
    
    char *MIPC_GetBuildDate()
    {
        static char s_date_buf[12];
        static char *s_date;
        if(NULL == s_date)
        {
            char mmmMM[48]="Jan_Feb_Mar_Apr_May_Jun_Jul_Aug_Sep_Oct_Nov_Dec";
            char mmm_dd_yyyy[12];
            char mmm[4];
            long m,d,y;
            sprintf(mmm_dd_yyyy,"%s",__DATE__);
            sscanf(mmm_dd_yyyy,"%s%ld%ld",mmm,&d,&y);
            m=(strstr(mmmMM,mmm)-mmmMM)/4+1;
            sprintf(s_date_buf,"%04ld-%02ld-%02ld",y,m,d);
            s_date = &s_date_buf[0];
        }
        return s_date;
    }
    
    NSString *MIPC_BuildEncryptSysInfo(NSString *user, NSString *password)
    {
        NSString            *sRet = nil;
        /* get system info */
        size_t              hw_machine_size;
        sysctlbyname("hw.machine", NULL, &hw_machine_size, NULL, 0);
        char                *model_buf = (char*)calloc(hw_machine_size, 1);
        if(model_buf){ sysctlbyname("hw.machine", model_buf, &hw_machine_size, NULL, 0); };
        
        struct netx_sockaddr local_ip = {0};
        netx_get_local_ip_2(&local_ip);
        
        NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
        NSString
        //*sDevArch = [NSString stringWithUTF8String: model_buf],
        *sDevModel = [[UIDevice currentDevice] model],
        //*sDevLocalModel = [[UIDevice currentDevice] localizedModel],
        *sDevName = [[UIDevice currentDevice] name],
        *sDevSysName = [[UIDevice currentDevice] systemName],
        *sDevSysVer = [[UIDevice currentDevice] systemVersion],
        *sAppBuildTime = [NSString stringWithFormat:@"%sT%s", MIPC_GetBuildDate(), __TIME__],
        *sAppVer =[infoDict objectForKey:@"CFBundleVersion"],
        *sAppName =[infoDict objectForKey:@"CFBundleDisplayName"],
        *sAppID = [infoDict objectForKey:@"CFBundleIdentifier"],
        *sNetWifiAddr = MIPC_GetWifiAddress(),
        *sNow = [NSString stringWithFormat:@"%s", mtime2s(0)],
        *sIP = [NSString stringWithFormat:@"%s", netx_sockaddr_ntop(&local_ip)],
        *sBSSID = nil, *sSSID = MIPC_GetWifiSSID(&sBSSID);
        
        
        struct json_object *tim, *sys, *dev, *app, *net, *root = json_create_object(NULL, 0, NULL);
        tim = json_create_string(root, len_str_def_const("time"), sNow.length, (char*)sNow.UTF8String);
        sys = json_create_object(root, len_str_def_const("sys"));
        dev = json_create_object(root, len_str_def_const("dev"));
        app = json_create_object(root, len_str_def_const("app"));
        net = json_create_object(root, len_str_def_const("net"));
        
        json_create_string(sys, len_str_def_const("name"),  sDevSysName.length,   (char*)sDevSysName.UTF8String);
        json_create_string(sys, len_str_def_const("ver"),   sDevSysVer.length,    (char*)sDevSysVer.UTF8String);
        if(model_buf){ json_create_string(dev, len_str_def_const("arch"), strlen(model_buf), (char*)model_buf); };
        json_create_string(dev, len_str_def_const("model"), sDevModel.length,     (char*)sDevModel.UTF8String);
        json_create_string(dev, len_str_def_const("name"),  sDevName.length,      (char*)sDevName.UTF8String);
        json_create_string(app, len_str_def_const("name"),  sAppName.length,      (char*)sAppName.UTF8String);
        json_create_string(app, len_str_def_const("id"),    sAppID.length,        (char*)sAppID.UTF8String);
        json_create_string(app, len_str_def_const("ver"),   sAppVer.length,       (char*)sAppVer.UTF8String);
        json_create_string(app, len_str_def_const("build"), sAppBuildTime.length, (char*)sAppBuildTime.UTF8String);
        json_create_string(net, len_str_def_const("mac"),   sNetWifiAddr.length,  (char*)sNetWifiAddr.UTF8String);
        json_create_string(net, len_str_def_const("ip"),    sIP.length,           (char*)sIP.UTF8String);
        if(sSSID && sSSID.length)
        {
            json_create_string(net, len_str_def_const("ssid"),  sSSID.length,     (char*)sSSID.UTF8String);
        }
        if(sBSSID && sBSSID.length)
        {
            json_create_string(net, len_str_def_const("bssid"), sBSSID.length,    (char*)sBSSID.UTF8String);
        }
        
        if(user && user.length)
        {
            json_create_string(root, len_str_def_const("user"), user.length, (char*)user.UTF8String);
        }
        
        /* encode */
        /* unsigned long pubk_bits = 0, pubk_len = 0;
         unsigned char *pubk = mlic_pubk_query(mlic_pubk_id_ccms_root, &pubk_bits, &pubk_len); */
        unsigned long buf_size = 4096;
        unsigned char *json_buf = (unsigned char*)malloc(buf_size),
        *encrypted_buf = (unsigned char*)malloc(buf_size),
        *base64_buf = (unsigned char*)malloc(buf_size);
        long          encrypted_len, base64_len, json_len = json_buf?json_encode(root, (char*)json_buf, buf_size):0;
        if(0 < json_len)
        {
            encrypted_len = mdes_enc(json_buf, json_len, (unsigned char*)password.UTF8String, password.length,
                                     encrypted_buf, buf_size);
            if(0 < encrypted_len)
            {
#define base64_mime_start_string    "data:application/octet-stream;base64,"
                memcpy(base64_buf, base64_mime_start_string, sizeof(base64_mime_start_string) - 1);
                base64_len = base64_encode(encrypted_buf,
                                           encrypted_len,
                                           &base64_buf[sizeof(base64_mime_start_string) - 1],
                                           buf_size - (sizeof(base64_mime_start_string) - 1) );
                if(0 < base64_len)
                {
                    sRet = [NSString stringWithUTF8String:(char*)base64_buf];
                }
            }
        }
        if(json_buf)     { free(json_buf); };
        if(encrypted_buf){ free(encrypted_buf); };
        if(base64_buf)   { free(base64_buf); };
        if(model_buf)    { free(model_buf); };
        return sRet;
    }
    
    NSString *MIPC_PostBuildEncryptSysInfo(NSString *user, NSString *password)
    {
        NSString            *sRet = nil;
        /* get system info */
        size_t              hw_machine_size;
        sysctlbyname("hw.machine", NULL, &hw_machine_size, NULL, 0);
        char                *model_buf = (char*)calloc(hw_machine_size, 1);
        if(model_buf){ sysctlbyname("hw.machine", model_buf, &hw_machine_size, NULL, 0); };
        
        struct netx_sockaddr local_ip = {0};
        netx_get_local_ip_2(&local_ip);
        
        NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
        NSString
        
        *sAppID = [infoDict objectForKey:@"CFBundleIdentifier"];
        
        
        struct json_object  *root = json_create_object(NULL, 0, NULL);
        
        json_create_string(root, len_str_def_const("appid"),  sAppID.length,      (char*)sAppID.UTF8String);
        if(user && user.length)
        {
            json_create_string(root, len_str_def_const("user"), user.length, (char*)user.UTF8String);
        }
        
        /* encode */
        /* unsigned long pubk_bits = 0, pubk_len = 0;
         unsigned char *pubk = mlic_pubk_query(mlic_pubk_id_ccms_root, &pubk_bits, &pubk_len); */
        unsigned long buf_size = 4096;
        unsigned char *json_buf = (unsigned char*)malloc(buf_size),
        *encrypted_buf = (unsigned char*)malloc(buf_size),
        *base64_buf = (unsigned char*)malloc(buf_size);
        long          encrypted_len, base64_len, json_len = json_buf?json_encode(root, (char*)json_buf, buf_size):0;
        if(0 < json_len)
        {
            encrypted_len = mdes_enc(json_buf, json_len, (unsigned char*)password.UTF8String, password.length,
                                     encrypted_buf, buf_size);
            if(0 < encrypted_len)
            {
#define base64_mime_start_string    "data:application/octet-stream;base64,"
                memcpy(base64_buf, base64_mime_start_string, sizeof(base64_mime_start_string) - 1);
                base64_len = base64_encode(encrypted_buf,
                                           encrypted_len,
                                           &base64_buf[sizeof(base64_mime_start_string) - 1],
                                           buf_size - (sizeof(base64_mime_start_string) - 1) );
                if(0 < base64_len)
                {
                    sRet = [NSString stringWithUTF8String:(char*)base64_buf];
                }
            }
        }
        if(json_buf)     { free(json_buf); };
        if(encrypted_buf){ free(encrypted_buf); };
        if(base64_buf)   { free(base64_buf); };
        if(model_buf)    { free(model_buf); };
        return sRet;
    }
    
    NSString *MIPC_BuildEncryptExceptionInfo(NSString *type,NSString *model,NSString *name,NSString *reason,NSString *call_stack,NSString *user, NSString *password)
    {
        NSString            *sRet = nil;
        /* get system info */
        
        NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
        NSString
        *sDevSysVer = [[UIDevice currentDevice] systemVersion],
        *sAppVer =[infoDict objectForKey:@"CFBundleVersion"],
        *sAppName =[infoDict objectForKey:@"CFBundleDisplayName"];

        struct json_object *root = json_create_object(NULL, 0, NULL);

        if(name && name.length)
        {
            json_create_string(root, len_str_def_const("type"), type.length, (char*)type.UTF8String);
            json_create_string(root, len_str_def_const("model"), model.length,     (char*)model.UTF8String);
            json_create_string(root, len_str_def_const("os"),   sDevSysVer.length,    (char*)sDevSysVer.UTF8String);
            json_create_string(root, len_str_def_const("name"),  sAppName.length,      (char*)sAppName.UTF8String);
            json_create_string(root, len_str_def_const("app_ver"),   sAppVer.length,       (char*)sAppVer.UTF8String);
            json_create_string(root, len_str_def_const("exception_name"), name.length, (char*)name.UTF8String);
            json_create_string(root, len_str_def_const("exception_reason"), reason.length, (char*)reason.UTF8String);
            json_create_string(root, len_str_def_const("call_stack"), call_stack.length, (char*)call_stack.UTF8String);
        }
        
        /* encode */
        unsigned long buf_size = 1024 * 1024 * 3;
        unsigned char *json_buf = (unsigned char*)malloc(buf_size),
        *encrypted_buf = (unsigned char*)malloc(buf_size),
        *base64_buf = (unsigned char*)malloc(buf_size);
        long          encrypted_len, base64_len, json_len = json_buf?json_encode(root, (char*)json_buf, buf_size):0;
        if(0 < json_len)
        {
            encrypted_len = mdes_enc(json_buf, json_len, (unsigned char*)password.UTF8String, password.length,encrypted_buf, buf_size);
            if(0 < encrypted_len)
            {
#define mining64_mime_start_string    "data:application/octet-stream;mining64,"
                memcpy(base64_buf, mining64_mime_start_string, sizeof(mining64_mime_start_string) - 1);
                base64_len = mining64_encode(encrypted_buf,
                                             encrypted_len,
                                             &base64_buf[sizeof(mining64_mime_start_string) - 1],
                                             buf_size - (sizeof(mining64_mime_start_string) - 1) );
                if(0 < base64_len)
                {
                    sRet = [NSString stringWithUTF8String:(char*)base64_buf];
                }
            }
        }
        if(json_buf)     { free(json_buf); };
        if(encrypted_buf){ free(encrypted_buf); };
        if(base64_buf)   { free(base64_buf); };
//        if(model_buf)    { free(model_buf); };
        return sRet;
    }
    
    NSString *MIPC_GetEngineKey(void)
    {
        NSString *engine_key = nil;

        NSString *path = [[NSBundle mainBundle] pathForResource:@"engine_key" ofType:@""];
        NSString *config_string = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        struct json_object *root_json = json_decode(strlen(config_string.UTF8String), (char*)config_string.UTF8String);
        struct len_str  key = {0};
        json_get_child_string(root_json, "key", &key);
        engine_key = [NSString stringWithFormat:@"%s",key.data];
        
        return engine_key;
    }
    
    NSMutableDictionary* MIPC_GetApplicationConfigInfo(void)
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@""];
        
        NSError *error = nil;
        NSString *config_string = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        struct json_object *root_json = json_decode(strlen(config_string.UTF8String), (char*)config_string.UTF8String);
        
        struct len_str      color ={0}, button_color = {0}, button_title_color = {0};
        json_get_child_string(root_json, "color", &color);
        json_get_child_string(root_json, "button_color", &button_color);
        json_get_child_string(root_json, "title_color", &button_title_color);
        
        NSString *color_str = [NSString stringWithFormat:@"%s",color.data]?[NSString stringWithFormat:@"%s",color.data]:@"";
        NSString *button_color_str = [NSString stringWithFormat:@"%s",button_color.data]?[NSString stringWithFormat:@"%s",button_color.data]:@"";
        NSString *button_title_colcor_str = [NSString stringWithFormat:@"%s",button_title_color.data]?[NSString stringWithFormat:@"%s",button_title_color.data]:@"";
        
        [dictionary setObject:color_str forKey:@"color"];
        [dictionary setObject:button_color_str forKey:@"button_color"];
        [dictionary setObject:button_title_colcor_str forKey:@"button_title_color"];
        
        struct len_str      reg_by_email = {0};
        json_get_child_string(root_json, "reg_by_email", &reg_by_email);
        NSString *reg_by_email_str = [NSString stringWithFormat:@"%s",reg_by_email.data]?[NSString stringWithFormat:@"%s",reg_by_email.data]:@"";
        
        BOOL is_reg_by_email = [reg_by_email_str isEqualToString:@"yes"];
        [dictionary setObject:[NSNumber numberWithBool:is_reg_by_email] forKey:@"is_reg_by_email"];
        
        struct len_str      alert_independent = {0};
        json_get_child_string(root_json, "alert_independent", &alert_independent);
        NSString *alert_independent_str = [NSString stringWithFormat:@"%s",alert_independent.data]?[NSString stringWithFormat:@"%s",alert_independent.data]:@"";
        [dictionary setObject:alert_independent_str forKey:@"alert_independent"];
        
        
        struct len_str      luxcam = {0};
        json_get_child_string(root_json, "luxcam", &luxcam);
        NSString *is_luxcam_str = [NSString stringWithFormat:@"%s",luxcam.data]?[NSString stringWithFormat:@"%s",luxcam.data]:@"";
        
        BOOL is_luxcam = [is_luxcam_str isEqualToString:@"yes"];
        [dictionary setObject:[NSNumber numberWithBool:is_luxcam] forKey:@"is_luxcam"];

        
        struct len_str      itelcamera = {0};
        json_get_child_string(root_json, "itelcamera", &itelcamera);
        NSString *is_itelcamera_str = [NSString stringWithFormat:@"%s",itelcamera.data]?[NSString stringWithFormat:@"%s",itelcamera.data]:@"";
        
        BOOL is_itelcamera = [is_itelcamera_str isEqualToString:@"yes"];
        [dictionary setObject:[NSNumber numberWithBool:is_itelcamera] forKey:@"is_itelcamera"];
        
        
        return dictionary;
    }
    
    NSString *MIPC_SrvFix(NSString *srv)
    {
        if(srv && srv.length)
        {
            NSString *sFixedServer = @"", *sFixedPrefix = @"", *sFixedSuffix = @"";
            if(![[srv lowercaseString] hasPrefix:@"http://"])
            {
                sFixedPrefix = @"http://";
            }
            if((![[srv lowercaseString] hasSuffix:@"/ccm"])
               && (![[srv lowercaseString] hasSuffix:@"/ccm/"]))
            {
                sFixedSuffix = [[srv lowercaseString] hasSuffix:@"/"]?@"ccm":@"/ccm";
            }
            sFixedServer = [NSString stringWithFormat:@"%@%@%@", sFixedPrefix, srv, sFixedSuffix];
            return sFixedServer;
        }
        return srv;
    }
    
    json_object *MIPC_DataTransformToJson(NSData *data)
    {
        struct json_object  *retJson = NULL;
        long                dataBytesCounts = data?data.length:0;
        char                *dataBytes = (char*)(dataBytesCounts?malloc(dataBytesCounts + 1):NULL);
        
        if(dataBytes)
        {
            [data getBytes:dataBytes length:dataBytesCounts];
            dataBytes[dataBytesCounts] = 0;
        }
        
        if(dataBytes)
        {
            char            *json_data = dataBytes;
            unsigned long   i, json_len = (unsigned long)data.length;
            while(json_len && ('}' != json_data[json_len - 1]))
            {
                --json_len;
            }
            for(i = 0; i < json_len; ++i)
            {
                if('{' == json_data[i]){ break; };
            }
            if(i < json_len)
            {
                retJson = json_decode(json_len - i, &json_data[i]);
            }
            
            if(NULL == retJson)
            {
                for(long j = i; j < json_len; ++j)
                {
                    if(0 == dataBytes[j])
                    {/* some router maybe change packet content to block some thing. such as china mobile */
                        dataBytes[j] = ' ';
                    }
                }
                retJson = json_decode(json_len - i, &json_data[i]);
                if(NULL == retJson)
                {
                    /* request */
                }
                
            }
        }
        free(dataBytes);
        
        return retJson;
    }
    
#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */


#define CTL_NET         4               /* network, see socket.h */


#if defined(BSD) || defined(__APPLE__)

#define ROUNDUP(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

int getLocalIP(in_addr_t * addr)
{
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_FLAGS, RTF_GATEWAY};
    size_t l;
    char * buf, * p;
    struct rt_msghdr * rt;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[RTAX_MAX];
    int i;
    int r = -1;
    if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
        return -1;
    }
    if(l>0) {
        buf = (char *)malloc(l);
        if(sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
            return -1;
        }
        for(p=buf; p<buf+l; p+=rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for(i=0; i<RTAX_MAX; i++) {
                if(rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sa_family == AF_INET
               && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                
                
                if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    char ifName[128];
                    if_indextoname(rt->rtm_index,ifName);
                    
                    if(strcmp("en0",ifName)==0){
                        
                        *addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                        r = 0;
                    }
                }
            }
        }
        free(buf);
    }
    return r;
}



unsigned char * getdefaultgateway(in_addr_t * addr)
{
    unsigned char * octet= (unsigned char *)malloc(4);
#if 0
    /* net.route.0.inet.dump.0.0 ? */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_DUMP, 0, 0/*tableid*/};
#endif
    /* net.route.0.inet.flags.gateway */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_FLAGS, RTF_GATEWAY};
    size_t l;
    char * buf, * p;
    struct rt_msghdr * rt;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[RTAX_MAX];
    int i;
    if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
        return octet;
    }
    if(l>0) {
        buf = (char *)malloc(l);
        if(sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
            return octet;
        }
        for(p=buf; p<buf+l; p+=rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for(i=0; i<RTAX_MAX; i++) {
                if(rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sa_family == AF_INET
               && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                
                
                for (int i=0; i<4; i++){
                    octet[i] = ( ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr >> (i*8) ) & 0xFF;
                }
                
            }
        }
        free(buf);
    }
    return octet;
}

//-----test-----//
struct json_object *json_get_old_field(struct json_object *field_array, unsigned long name_len, char *name)
{
    struct json_object  *child_first = (field_array && (field_array->type == ejot_array))?field_array->v.array.list:NULL, *child = child_first;
    struct len_str s_name = {0}, s_check_name = {name_len, name};
    if(child)
    {
        do
        {
            //                if (OLDVER)
            //                    json_get_child_string(child, "name", &s_name);
            //                else
            json_get_child_string(child, "name", &s_name);
            if(0 == len_str_cmp(&s_check_name, &s_name))
            {
                //                    if (OLDVER)
                //                        return json_get_child_by_name(child, NULL, len_str_def_const("value"));
                //                    else
                return json_get_child_by_name(child, NULL, len_str_def_const("value"));                }
        }while ((child = child->in_parent.next) != child_first);
        
    }
    return NULL;
}

NSString *json_get_old_field_string(struct json_object *field_array, unsigned long name_len, char *name)
{
    struct json_object  *value = json_get_old_field(field_array, name_len, name);
    struct len_str      s_value = {0};
    return (value && (0 == json_get_string(value, &s_value)) && s_value.len)?[NSString stringWithUTF8String:s_value.data]:@"";
}

//-----test-----//

#endif
