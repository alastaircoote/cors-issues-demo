//
//  SchemeCorsDemo.swift
//  cors-issues-demo
//
//  Created by Alastair Coote on 6/23/20.
//  Copyright © 2020 Alastair Coote. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

func createHTMLContent(couldInstallCustomScheme: Bool) -> String {
    return """
        <!doctype>
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1">
            </head>
            <style>
                body {
                    font-family: system-ui;
                }
                span {
                    font-weight: bold
                }
            </style>
            <body>
                <p>
                    Page URL is: <span id='page-url'/>
                </p>
                <p>
    Could install custom scheme handler: <span>\( couldInstallCustomScheme ? "YES" : "NO")</span>
                <p>
                    Could it load JSON from a custom scheme? <span id='custom-load'/>
                </p>
                <p>
                    Result found: <span id='result-details'/>
                </p>
                <p>
                    Does navigator.share exist: <span id='navigator-share'/>
                </p>
            <script>
                (async function() {
                    document.getElementById('page-url').innerText = window.location.href;
                    document.getElementById('navigator-share').innerText = 'share' in navigator? "YES" : "NO";

                    const resultTarget = document.getElementById('custom-load');
                    const detailsTarget = document.getElementById('result-details');

                    try {
                        const res = await fetch("another-custom-scheme://test.json");
                        const json = await res.json();
                        resultTarget.innerText = "YES";
                        detailsTarget.innerText = JSON.stringify(json);
                    } catch (e) {
                        resultTarget.innerText = "NO"
                        detailsTarget.innerText = e.message
                    }

                })();

            </script>
            </body>
        </html>

    """
}

struct SchemeCORSDemo: UIViewRepresentable {
    typealias UIViewType = WKWebView

    let schemeToUse:String

    func makeConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(Handler(), forURLScheme: "another-custom-scheme")
        return config
    }

    func canInstallToScheme(config: WKWebViewConfiguration) -> Bool {
        do {
            try ObjC.catchException {
                config.setURLSchemeHandler(Handler(), forURLScheme: self.schemeToUse)
            }
            return true
        } catch {
            return false
        }
    }


    func makeUIView(context: Context) -> WKWebView {

        let config = makeConfig()
        let canInstall = canInstallToScheme(config: config)
        let wv = WKWebView(frame: CGRect(x: 0,y: 0,width: 0,height: 0), configuration: config)

        var url = URLComponents()
        url.scheme = schemeToUse
        url.host = "example.com"


        wv.loadHTMLString(createHTMLContent(couldInstallCustomScheme: canInstall), baseURL: url.url)
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {

    }

}

class Handler : NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        urlSchemeTask.didReceive(HTTPURLResponse(url: urlSchemeTask.request.url!, statusCode: 200, httpVersion: nil, headerFields: [
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        ])!)
        urlSchemeTask.didReceive("{\"result\":\"hello\"}".data(using: .utf8)!)
        urlSchemeTask.didFinish()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {

    }


}
