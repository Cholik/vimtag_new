//
//  MNOpenAlDecode.h
//  mipci
//
//  Created by mining on 15/12/3.
//
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface MNOpenAlDecode : NSObject
{
    ALCcontext         *m_Context;
    ALCdevice          *m_Device;
    ALuint             m_sourceID;           
    NSCondition        *m_DecodeLock;
}

-(BOOL)initOpenAl;
-(void)playSound;
-(void)stopSound;
-(void)openAudio:(unsigned char*)pBuffer length:(UInt32)pLength;
-(void)clearOpenAL;
@end
