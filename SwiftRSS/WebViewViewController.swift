//
//  WebViewViewController.swift
//  SwiftRSS
//
//  Created by Guido Grassel on 12/09/14.
//  Copyright (c) 2014 albert mckeever. All rights reserved.
//

import UIKit

class WebViewViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var url = "http://www.google.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self;
        loadAddressUrl();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAddressUrl() {
        let requestUrl = NSURL(string: url);
        let request = NSURLRequest(URL: requestUrl);
        webView.loadRequest(request);
        println("requesting loading Web page at url \"\(url)\"");
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        println("Permitting loading \"\(request.URL)\"");
        return true;
    }
    func webViewDidStartLoad(webView: UIWebView) {
        println("Start loading Web page at url \"\(url)\"");
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        println("Done loading Web page at url \"\(url)\"");
    }
    
    @IBAction func doneSelected(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
