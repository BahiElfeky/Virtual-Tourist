//
//  Alert.swift
//  Virtual Tourist
//
//  Created by Bahi El Feky on 5/11/19.
//  Copyright © 2019 Bahi El Feky. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert (message: String) {
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.default) { action in self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
