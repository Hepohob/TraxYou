//
//  ImageViewController.swift
//  ScrollViewExample
//
//  Created by Aleksei Neronov on 21/12/2016.
//  Copyright © 2016 Aleksei Neronov. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    var imageURL:NSURL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            spinner?.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                let content = NSData(contentsOf: url as URL)
                DispatchQueue.main.async {
                    if url == self.imageURL {
                        if let imageData = content {
                            self.image = UIImage(data: imageData as Data)
                        } else {
                            self.spinner?.stopAnimating()
                        }
                    }
                }
            }
        }
    }
    
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            self.spinner?.stopAnimating()
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.addSubview(imageView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    //MARK: UIScrollView delegates
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
