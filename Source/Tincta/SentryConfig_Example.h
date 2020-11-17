//  If you want to use crash logging, define your service in a file 'SentryConfig.h'.
//  This files here serves as an example.
//
//  Of course the SentryConfig.h should never be submitted to version control
//  That is why only this sample file is included in the repo.
//
//  For the App Store version we use Sentry but you could quite
//  easily use any other crash logging tool like App Center.
//
//
//  Define your DSN or other secret keys here, if you want to use it
//
//  IT IS SAVE TO JUST DELETE THIS FILE AND THE SentryConfig.h

#ifndef SentryConfig_Example_h
#define SentryConfig_Example_h

#define INCLUDE_SENTRY
#define SENTRY_DSN @"YOUR KEY GOES HERE"

#endif /* AppCenterConfig_Example_h */

