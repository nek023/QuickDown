#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "MarkdownParser.h"

// The minimum aspect ratio (width / height) of a thumbnail.
#define MINIMUM_ASPECT_RATIO (1.0 / 2.0)

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSString *HTMLString = parseMarkdown([(__bridge NSURL *)url path]);
    
    if (HTMLString) {
        NSRect frame = NSMakeRect(0, 0, 600, 800);
        double scaledHeight = maxSize.height / NSHeight(frame);
        NSSize scaledSize = NSMakeSize(scaledHeight, scaledHeight);
        CGSize thumbnailSize = CGSizeMake(maxSize.width * (NSWidth(frame) / NSHeight(frame)), maxSize.height);
        
        WebView *webView = [[WebView alloc] initWithFrame:frame];
        [webView scaleUnitSquareToSize:scaledSize];
        
        [[[webView mainFrame] frameView] setAllowsScrolling:NO];
        [[webView mainFrame] loadHTMLString:HTMLString baseURL:(__bridge NSURL *)url];
        
        while ([webView isLoading]) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
        }
        
        [webView display];
        
        CGContextRef context = QLThumbnailRequestCreateContext(thumbnail, thumbnailSize, false, NULL);
        
        if (context) {
            NSGraphicsContext *nsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)context
                                                                                      flipped:[webView isFlipped]];
            [webView displayRectIgnoringOpacity:[webView bounds]
                                      inContext:nsContext];
            
            QLThumbnailRequestFlushContext(thumbnail, context);
            
            CFRelease(context);
        }
    }
    
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
