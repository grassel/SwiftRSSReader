//
//  RssFeedChannelParserDelegate.swift
//  SwiftRSS
//
//  Created by Guido Grassel on 13/09/14.
//  Copyright (c) 2014 albert mckeever. All rights reserved.
//

import Foundation

protocol RssFeedChannelParserDelegate {
    func onParseResult (title ftitle : String, pubDate fpubDateString : String, description fdescription: String, imageUrl fimageUrlString :String);
}