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
    
    // Assign Delegates
    let memeTextDelegate = MemeTextDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextFields()
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        if meme != nil {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = meme!.originalImage
            textSize = meme!.textSize
            topTextField.text = meme!.topText
            bottomTextField.text = meme!.bottomText
            setUpTextFields()
        }
        
        enableOrHideButtons()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = image
            enableOrHideButtons()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: UIBarButtonItem) {
        pickAnImageFrom(sender)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
        pickAnImageFrom(sender)
    }
    
    @IBAction func shareButton(_ sender: AnyObject) {
        bottomTextField.resignFirstResponder()
        topTextField.resignFirstResponder()
        let memedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
//        controller.completionWithItemsHandler = { (activity: String?, completed: Bool, items: [AnyObject]?, error: NSError?) in
//            if completed {
//                self.save()
//            }
//        }
        controller.completionWithItemsHandler = { (activity, completed, items, error) in
            if completed {
                self.save()
            }
        }
    
    }
    
    @IBAction func increaseTextSize(_ sender: AnyObject) {
        changeTextSize(2)
        setUpTextFields()
    }
    
    @IBAction func decreaseTextSize(_ sender: AnyObject) {
        changeTextSize(-2)
        setUpTextFields()
    }
    
    @IBAction func doneButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // Create Notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:))    , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    // Helper Functions
    // Initiate and set up the textfields
    
    func setUpTextFields() {
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont(name: "Impact", size: textSize)!,
            NSStrokeWidthAttributeName : -3.0
        ] as [String : Any]
        
        self.topTextField.delegate = memeTextDelegate
        self.bottomTextField.delegate = memeTextDelegate
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.sizeToFit()
        bottomTextField.sizeToFit()
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
    }
    
    // Finds Keyboard Height
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage(), textSize: self.textSize)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        print("the memes array consists of these memes: \n \(appDelegate.memes)")
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide the status bar and navigation bar
        topToolBar.isHidden = true
        bottomToolBar.isHidden = true
        UIApplication.shared.isStatusBarHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show the status bar and navigation bar
        topToolBar.isHidden = false
        bottomToolBar.isHidden = false
        UIApplication.shared.isStatusBarHidden = false
        
        return memedImage
    }
    
    // Increase and decrease text size for top and bottom text fields
    func changeTextSize(_ size: CGFloat) {
        textSize += size
    }
    
    // Show / Hide / Enable / Disable buttons and text based on if an image is set
    func enableOrHideButtons() {
        if imagePickerView.image == nil {
            shareBarButton.isEnabled = false
            minusButton.isEnabled = false
            plusButton.isEnabled = false
            topTextField.isHidden = true
            bottomTextField.isHidden = true
        } else {
            shareBarButton.isEnabled = true
            minusButton.isEnabled = true
            plusButton.isEnabled = true
            topTextField.isHidden = false
            bottomTextField.isHidden = false
        }
    }
    
    func pickAnImageFrom(_ sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType(rawValue: sender.tag)!
        self.present(pickerController, animated: true, completion: nil)
    }
    
}

