//
//  MarkdownParser.m
//  QuickDown
//
//  Created by Katsuma Tanaka on 2015/05/18.
//  Copyright (c) 2015年 Katsuma Tanaka. All rights reserved.
//

#import "MarkdownParser.h"

// Discount
#import "mkdio.h"

NSString * parseMarkdown(NSString *filePath) {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"jp.questbeat.QuickDown"];
    
    // Load CSS
    NSString *cssPath = [bundle pathForResource:@"github-markdown" ofType:@"css"];
    NSString *styles = [NSString stringWithContentsOfFile:cssPath
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    
    // Load markdown
    NSStringEncoding usedEncoding = 0;
    NSError *error = nil;
    NSString *markdown = [NSString stringWithContentsOfFile:filePath
                                               usedEncoding:&usedEncoding
                                                      error:&error];
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return nil;
    }
    
    if (usedEncoding == 0) {
        NSLog(@"Warning: Couldn't determine the encoding of the file. UTF-8 will be used.");
        
        error = nil;
        markdown = [NSString stringWithContentsOfFile:filePath
                                             encoding:NSUTF8StringEncoding
                                                error:&error];
        
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
            return nil;
        }
    }
    
    // Convert markdown to HTML
    mkd_with_html5_tags();
    MMIOT *document = gfm_string([markdown UTF8String], (int)strlen([markdown UTF8String]), 0);
    mkd_compile(document, 0);
    
    char *outputCString = NULL;
    int size = mkd_document(document, &outputCString);
    
    if (size == 0) {
        NSLog(@"Error: Couldn't convert markdown to HTML.");
        return nil;
    } else {
        outputCString[size - 1] = 0;
    }
    NSString *outputString = [NSString stringWithUTF8String:outputCString];
    
    NSString *HTML = [NSString stringWithFormat:@"<!DOCTYPE html>"
                      "<html>"
                      "<head>"
                      "<meta charset=\"utf-8\" />"
                      "<base href=\"%@\" />"
                      "<style>%@</style>"
                      "</head>"
                      "<body class=\"markdown-body\">"
                      "%@"
                      "</body>"
                      "</html>",
                      filePath, styles, outputString];
    
    return HTML;
}
