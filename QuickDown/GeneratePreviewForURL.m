#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>
#import "MarkdownParser.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    NSString *filePath = [(__bridge NSURL *)url path];
    NSString *HTMLString = parseMarkdown(filePath);
    NSData *HTMLData = [HTMLString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (HTMLData) {
        CFDictionaryRef props = (__bridge CFDictionaryRef)[NSDictionary dictionary];
        QLPreviewRequestSetDataRepresentation(preview, (__bridge CFDataRef)HTMLData, kUTTypeHTML, props);
    }
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
