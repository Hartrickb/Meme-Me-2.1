//
//  DetailViewController.swift
//  Meme Me 1.0
//
//  Created by Bennett Hartrick on 6/3/16.
//  Copyright © 2016 Bennett. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(DetailViewController.showDetailVC))
        
        detailImageView.image = meme.memedImage
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    // Gets called when Edit button is pressed
    func showDetailVC () {
        performSegueWithIdentifier("detailToEdit", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailToEdit" {
            let editController = segue.destinationViewController as! MemeEditorViewController
            
            editController.meme = self.meme
        }
    }
    
}
