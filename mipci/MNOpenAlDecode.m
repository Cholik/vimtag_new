//
//  OpenAIDecode.m
//  testPCM
//
//  Created by mining on 15/12/3.
//  Copyright (c) 2015年 mining. All rights reserved.
//

#import "MNOpenAlDecode.h"

@implementation MNOpenAlDecode

-(BOOL)initOpenAl
{
    if (m_Device ==nil)
    {
        m_Device = alcOpenDevice(NULL);
    }
    
    if (m_Device==nil)
    {
        return NO;
    }
    if (m_Context==nil)
    {
        if (m_Device)
        {
            m_Context =alcCreateContext(m_Device, NULL);
            alcMakeContextCurrent(m_Context);
        }
    }
    
    alGenSources(1, &m_sourceID);
    alSourcei(m_sourceID, AL_LOOPING, AL_TRUE);
    alSourcef(m_sourceID, AL_SOURCE_TYPE, AL_STREAMING);
    alSourcef(m_sourceID, AL_GAIN, 1.0f);
    //    alDopplerVelocity(1.0);
    //    alDopplerFactor(1.0);                                                                           alSpeedOfSound(1.0);
    m_DecodeLock =[[NSCondition alloc] init];
    if (m_Context==nil)
    {
        return NO;
    }    
    
    
        //    ALenum  error;
    //    if ((error=alGetError())!=AL_NO_ERROR)
    //    {
    //        return NO;
    //    }
    return YES;
}


-(BOOL)updataQueueBuffer
{
    ALint  state;
    int processed ,queued;
    
    alGetSourcei(m_sourceID, AL_SOURCE_STATE, &state);
    if (state !=AL_PLAYING)
    {
        [self playSound];
        return NO;
    }
    
    alGetSourcei(m_sourceID, AL_BUFFERS_PROCESSED, &processed);
    alGetSourcei(m_sourceID, AL_BUFFERS_QUEUED, &queued);
    
    
    NSLog(@"Processed = %d\n", processed);
    NSLog(@"Queued = %d\n", queued);
    while (processed--)
    {
        ALuint  buffer;
        alSourceUnqueueBuffers(m_sourceID, 1, &buffer);
        alDeleteBuffers(1, &buffer);
    }
    return YES;
}


-(void)openAudio:(unsigned char*)pBuffer length:(UInt32)pLength
{
    
    [m_DecodeLock lock];
    
    ALenum  error =AL_NO_ERROR;
//    if ((error =alGetError())!=AL_NO_ERROR)
//    {
//        [m_DecodeLock unlock];
//        return ;
//    }
    if (pBuffer ==NULL)
    {
        return ;
    }
    
    [self updataQueueBuffer];
    
//    if ((error =alGetError())!=AL_NO_ERROR)
//    {
//        [m_DecodeLock unlock];
//        return ;
//    }
    
    ALuint    bufferID =0;
    alGenBuffers(1, &bufferID);
    
//    if ((error = alGetError())!=AL_NO_ERROR)
//    {
//        NSLog(@"Create buffer failed");
//        [m_DecodeLock unlock];
//        return;
//    }
    
    NSData  *data =[NSData dataWithBytes:pBuffer length:pLength];
     alBufferData(bufferID, AL_FORMAT_MONO16, (char *)[data bytes] , (ALsizei)[data length], 16000 );
//    alBufferData(bufferID, AL_FORMAT_MONO16, (char *)[data bytes] , (ALsizei)[data length], 8000 );
    
//    if ((error =alGetError())!=AL_NO_ERROR)
//    {
//        NSLog(@"create bufferData failed");
//        [m_DecodeLock unlock];
//        return;
//    }
//    

    alSourceQueueBuffers(m_sourceID, 1, &bufferID);
    
    if ((error =alGetError())!=AL_NO_ERROR)
    {
        NSLog(@"add buffer to queue failed");
        [m_DecodeLock unlock];
        return;
    }
    if ((error=alGetError())!=AL_NO_ERROR)
    {
        NSLog(@"play failed");
        alDeleteBuffers(1, &bufferID);
        [m_DecodeLock unlock];
        return;
    }
    
    [m_DecodeLock unlock];
    
}
-(void)playSound
{
    ALint  state;
    alGetSourcei(m_sourceID, AL_SOURCE_STATE, &state);
    if (state != AL_PLAYING)
    {
        alSourcePlay(m_sourceID);
    }
}

-(void)stopSound
{
    ALint  state;
    alGetSourcei(m_sourceID, AL_SOURCE_STATE, &state);
    if (state != AL_STOPPED)
    {
        
        alSourceStop(m_sourceID);
    }
}

-(void)clearOpenAL
{
    alDeleteSources(1, &m_sourceID);
    if (m_Context != nil)
    {
        alcDestroyContext(m_Context);
        m_Context=nil;
    }
    if (m_Device !=nil)
    {
        alcCloseDevice(m_Device);
        m_Device=nil;
    }
}

@end
