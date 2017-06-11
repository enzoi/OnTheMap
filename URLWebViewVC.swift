//
//  URLWebViewVC.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class URLWebViewVC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var studentLocation: StudentLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        webView.delegate = self
        if let url = URL(string: (self.studentLocation?.mediaURL)!) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
        
    }

}
