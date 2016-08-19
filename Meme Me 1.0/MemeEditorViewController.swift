//
//  MemeEditorViewController.swift
//  Meme Me 1.0
//
//  Created by Bennett Hartrick on 5/27/16.
//  Copyright © 2016 Bennett. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var minusButton: UIBarButtonItem!
    @IBOutlet weak var plusButton: UIBarButtonItem!
    
    var textSize: CGFloat = 40
    var meme: Meme? = nil
    var topText: String?
    var bottomText: String?
    var image: UIImage?
    
    // Assign Delegates
    let memeTextDelegate = MemeTextDelegate()

    override func viewDidLoad() {
        // print(UIFont.familyNames())
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpTextFields()
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        enableOrHideButtons()
        
        if meme != nil {
            imagePickerView.contentMode = .ScaleAspectFit
            imagePickerView.image = image
            topTextField.text = topText
            print(topTextField.text)
            bottomTextField.text = bottomText
            print(bottomTextField.text)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .ScaleAspectFit
            imagePickerView.image = image
            enableOrHideButtons()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(sender: UIBarButtonItem) {
        pickAnImageFrom(sender)
    }
    
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        pickAnImageFrom(sender)
    }
    
    @IBAction func shareButton(sender: AnyObject) {
        bottomTextField.resignFirstResponder()
        topTextField.resignFirstResponder()
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.presentViewController(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = { (activity: String?, completed: Bool, items: [AnyObject]?, error: NSError?) in
            if completed {
                self.save()
            }
        }
    }
    
    @IBAction func increaseTextSize(sender: AnyObject) {
        changeTextSize(2)
        setUpTextFields()
    }
    
    @IBAction func decreaseTextSize(sender: AnyObject) {
        changeTextSize(-2)
        setUpTextFields()
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Create Notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:))    , name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    // Helper Functions
    // Initiate and set up the textfields
    
    func setUpTextFields() {
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "Impact", size: textSize)!,
            NSStrokeWidthAttributeName : -3.0
        ]
        
        self.topTextField.delegate = memeTextDelegate
        self.bottomTextField.delegate = memeTextDelegate
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.sizeToFit()
        bottomTextField.sizeToFit()
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
    }
    
    // Finds Keyboard Height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        print("the memes array consists of these memes: \n \(appDelegate.memes)")
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide the status bar and navigation bar
        topToolBar.hidden = true
        bottomToolBar.hidden = true
        UIApplication.sharedApplication().statusBarHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show the status bar and navigation bar
        topToolBar.hidden = false
        bottomToolBar.hidden = false
        UIApplication.sharedApplication().statusBarHidden = false
        
        return memedImage
    }
    
    // Increase and decrease text size for top and bottom text fields
    func changeTextSize(size: CGFloat) {
        textSize += size
    }
    
    // Show / Hide / Enable / Disable buttons and text based on if an image is set
    func enableOrHideButtons() {
        if imagePickerView.image == nil {
            shareBarButton.enabled = false
            minusButton.enabled = false
            plusButton.enabled = false
            topTextField.hidden = true
            bottomTextField.hidden = true
        } else {
            shareBarButton.enabled = true
            minusButton.enabled = true
            plusButton.enabled = true
            topTextField.hidden = false
            bottomTextField.hidden = false
        }
    }
    
    func pickAnImageFrom(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType(rawValue: sender.tag)!
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
}

