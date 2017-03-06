//
//  ViewController.swift
//  Example
//
//  Created by Michael Leber on 2/24/17.
//  Copyright © 2017 Markit. All rights reserved.
//

import UIKit
import MDEnvironmentManager

class ViewController: UIViewController {
    var environmentManager: EnvironmentManager!
    @IBOutlet var serviceOneEnvLabel: UILabel!
    @IBOutlet var serviceTwoEnvLabel: UILabel!
    @IBOutlet var serviceThreeEnvLabel: UILabel!
    
    @IBOutlet var serviceOneBaseAPILabel: UILabel!
    @IBOutlet var serviceTwoBaseAPILabel: UILabel!
    @IBOutlet var serviceThreeBaseAPILabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let stream = InputStream(url: Bundle.main.url(forResource: "Environments", withExtension: "csv")!)!
        environmentManager = EnvironmentManager(stream)
        
        self.serviceOneEnvLabel.text = self.environmentManager.currentEnvironmentFor(apiName: "LoginAPI")
        self.serviceTwoEnvLabel.text = self.environmentManager.currentEnvironmentFor(apiName: "QuoteAPI")
        self.serviceThreeEnvLabel.text = self.environmentManager.currentEnvironmentFor(apiName: "NewsAPI")
        self.serviceOneBaseAPILabel.text = self.environmentManager.baseUrl(apiName: "LoginAPI")?.absoluteString
        self.serviceTwoBaseAPILabel.text = self.environmentManager.baseUrl(apiName: "QuoteAPI")?.absoluteString
        self.serviceThreeBaseAPILabel.text = self.environmentManager.baseUrl(apiName: "NewsAPI")?.absoluteString
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.EnvironmentDidChange, object: nil, queue: nil) { (notif: Notification) in
            let api = notif.userInfo?[EnvironmentChangedKeys.APIName] as! String
            let newEnv = notif.userInfo?[EnvironmentChangedKeys.NewEnvironment] as! String
            
            switch api {
            case "LoginAPI":
                self.serviceOneEnvLabel.text = newEnv
                self.serviceOneBaseAPILabel.text = self.environmentManager.baseUrl(apiName: "LoginAPI")?.absoluteString
            case "QuoteAPI":
                self.serviceTwoEnvLabel.text = newEnv
                self.serviceTwoBaseAPILabel.text = self.environmentManager.baseUrl(apiName: "QuoteAPI")?.absoluteString
            case "NewsAPI":
                self.serviceThreeEnvLabel.text = newEnv
                self.serviceThreeBaseAPILabel.text = self.environmentManager.baseUrl(apiName: "NewsAPI")?.absoluteString
            default:
                print("unexpected")
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // stuff
        print("prepare for storyboard segue")
        if let segue = segue as? EnvironmentManagerSegue {
            segue.pass(environmentManager: self.environmentManager)
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController: Unwindable {
    @IBAction func unwind(toExit segue: UIStoryboardSegue) {
        print("Implement this protocol on your presenting view controller to unwind")
    }
}
