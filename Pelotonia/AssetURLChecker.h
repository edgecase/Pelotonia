/*
 
 AssetURLChecker.h

 A simple utility method that synchronously checks if an IOS ALAssetsLibrary's asset
 still exists.
 
 USAGE INSTRUCTIONS
 
 Using this class is simple. Simply add the AssetUrlChecker.h and AssetURLChecker.m
 files to your project, import AssetURLChecker.h where you would like to use it, and 
 use it like so:
 
 NSUrl * assetURL = nil; //some assetURL you saved earlier
 BOOL assetExists = [AssetURLChecker assetExists:assetURL];
 
 Created by Jason Baker (jason@onejasonforsale.com) for TumbleOn, September 2012.
 
 The latest version of this code is available at www.codercowboy.com.
 
 This code is based on the OmegaDelta's example:
 
 http://omegadelta.net/2011/05/10/how-to-wait-for-ios-methods-with-completion-blocks-to-finish/
 
 This code is licensed under the BSD license, a non-viral open source license
 that lets you use this code freely within your own projects without requiring
 your project itself to also be open source. More information about the BSD
 license is here:
 
 - http://en.wikipedia.org/wiki/Bsd_license
 
 Copyright (c) 2012, Pocket Sized Giraffe, LLC
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied.
 
 */

#import <Foundation/Foundation.h>

@interface AssetURLChecker : NSObject
+ (BOOL) assetExists:(NSURL*)assetURL;
@end
