//
//  RssFeedChannelParserDelegate.swift
//  SwiftRSS
//
//  Created by Guido Grassel on 13/09/14.
//  Copyright (c) 2014 albert mckeever. All rights reserved.
//

import Foundation

protocol RssFeedChannelParserDelegate {
    func parseValue(title ftitle : String);
    func parseValue(description fdescription: String);
    func parseValue(pubDate fpubDateString : String);
    func parseValue(imageUrl fimageUrlString :String);
}