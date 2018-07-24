//
//  QuoteViewController.swift
//  groovy
//
//  Created by Kyle Stokes on 7/22/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import UIKit
import Pulley

class QuoteViewController: UIViewController {
    
    // MARK: Properties
    var budget: Budget!
    var quote: String?
    var author: String?
    
    // MARK: Outlets
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Actions
    
    @IBAction func shareQuote(_ sender: UIButton) {
        let shareController = UIActivityViewController(activityItems: ["\(quote!) — \(author!)"], applicationActivities: nil)
        present(shareController, animated: true, completion: nil)
    }

    // MARK: Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getQuoteOfTheDay()
    }
    
    func hideQuoteInterface(_ isHidden: Bool) {
        self.authorLabel.isHidden = isHidden
        self.quoteTextView.isHidden = isHidden
        self.shareButton.isEnabled = !isHidden
        self.activityIndicator.isHidden = !isHidden
    }
    
    func getQuoteOfTheDay() {
        hideQuoteInterface(true)
        activityIndicator.startAnimating()
        QuotesClient.sharedInstance().getQuoteOfTheDay(completionHandlerQuote: { (quote, error) in
            if error != nil  {
                self.showAlert(title: "No Internet Connection", message: "You are not connected to the Internet. Reconnect and try again.")
            } else {
                // https://stackoverflow.com/q/30167848
                self.quote = "\"\(quote![0])\""
                self.author = quote![1]
                DispatchQueue.main.async {
                    self.authorLabel.text = self.author
                    self.quoteTextView.text = self.quote
                    self.activityIndicator.stopAnimating()
                    self.hideQuoteInterface(false)
                }
            }
        })
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension QuoteViewController: PulleyDrawerViewControllerDelegate {
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [PulleyPosition.partiallyRevealed, PulleyPosition.closed, PulleyPosition.collapsed]
    }
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 80.0
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 300.0
    }
}
