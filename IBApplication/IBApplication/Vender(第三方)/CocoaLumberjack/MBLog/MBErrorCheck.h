//
//  MBErrorCheck.h
//  IBApplication
//
//  Created by Bowen on 2019/5/14.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#ifndef __MBERRORCHECK_H__
#define __MBERRORCHECK_H__

// #define DISABLE_ASSERT

// ---------------------------------------------------------------------------

#ifdef _MSC_VER
#define __X_FUNCTION__ __FUNCTION__
#else
#define __X_FUNCTION__ __PRETTY_FUNCTION__
#endif

#if defined(DEBUG) && !defined(DISABLE_ASSERT)

    #if defined (_WIN32) || defined(_WIN64)              // Windows
        #include <crtdbg.h>
        #define MBAssert(exp)                   \
        do                                      \
        {                                       \
            _ASSERT(exp);                       \
        } while (0)
        
    #elif defined (__APPLE__)
		#include "TargetConditionals.h"
		#if defined(TARGET_OS_IPHONE) || defined(TARGET_IPHONE_SIMULATOR)
			#if defined(__i386__) || defined(__x86_64__) // iOS simulator
				#define MBAssert(exp)					\
				do                                      \
				{                                       \
					if (!(exp))							\
                    {                                   \
                        DDLogError(@"Assert Faild: %s", #exp);				\
						asm("int $3");					\
                    }                                   \
				} while (0)

			#elif defined(__arm__) || defined(__arm64__) // iOS device
				#include <signal.h>
				#include <pthread.h>

				#define MBAssert(exp)								\
				do													\
				{													\
					if (!(exp))										\
                    {                                               \
                        DDLogError(@"Assert Faild: %s", #exp);				\
						pthread_kill(pthread_self(), SIGINT);		\
                    }                                               \
				} while (0)
			#endif

		#elif defined(TARGET_OS_MAC)					 // Mac OS
			#include <CoreFoundation/CoreFoundation.h>
			#define MBAssert(exp)\
			do                                      \
			{                                       \
				if (!(exp))                         \
				{                                   \
					CFUserNotificationDisplayAlert(10, kCFUserNotificationNoteAlertLevel, NULL, NULL, NULL, CFSTR(#exp), NULL, NULL, NULL, NULL, NULL);\
					asm("int $3");                  \
				}                                   \
			} while (0)
		#endif
    #else                                                 // Linux and other
        #include <assert.h>
        #define MBAssert(exp)					\
        do                                      \
        {                                       \
            assert(exp);                        \
        } while (0)
        
    #endif
#else
    #ifdef __OBJC__
        #define MBAssert(exp)						\
        do                                          \
        {                                           \
            if (!(exp))                             \
                DDLogError(@"Assert Faild: %s", #exp);				\
        } while (0)
    #else
        #define MBAssert(exp)						 (void)0
    #endif
#endif

// -------------------------------------------------------------------------

#define MBCheck(exp)                                                        \
    do {																	\
        if (!(exp))															\
        {																	\
            goto MBExit;													\
        }																	\
    } while(0)

#define MBErrorCheck(exp)                                                   \
    do {																	\
    if (!(exp))															    \
        {																	\
            MBAssert(!"MBErrorCheck: " #exp);                               \
            goto MBExit;													\
        }																	\
    } while(0)

#define MBCheckEx(exp, exp1)                                                \
    do {																	\
    if (!(exp))															    \
        {																	\
            exp1;															\
            goto MBExit;													\
        }																	\
    } while(0)

#define MBErrorCheckEx(exp, exp1)                                           \
    do {																	\
    if (!(exp))			    												\
        {																	\
            MBAssert(!"MBErrorCheckEx: " #exp);								\
            exp1;															\
            goto MBExit;													\
        }																	\
    } while(0)

#define MBQuit()            \
    do                      \
    {                       \
        goto MBExit;        \
    } while (0)

//--------------------------------------------------------------------------
#endif /* __MBERRORCHECK_H__ */
