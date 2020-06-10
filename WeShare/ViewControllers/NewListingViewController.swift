//
//  NewListingViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 28/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import SkyFloatingLabelTextField
import FirebaseStorage
import SearchTextField
import MapKit

class NewListingViewController: UIViewController, PickCategoryDelegate {

    weak var databaseController: DatabaseProtocol?
    
    var imagesPNG: [Data] = []

    let INFO_CELL = "infoCell"
    
    var newListing: Listing = Listing() // initialize an empty Listing
    
    @IBOutlet weak var imageStack: UIStackView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var unitField: UITextField!
    @IBOutlet weak var addressField: SearchTextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImageButton.setImage(UIImage(systemName: "photo"), for: .normal)
        addImageButton.imageView?.contentMode = .scaleAspectFit
        addImageButton.layer.borderWidth = 1
        addImageButton.layer.cornerRadius = 10
        addImageButton.layer.borderColor = UIColor.link.cgColor
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        titleField.delegate = self
        categoryField.delegate = self
        quantityField.delegate = self
        unitField.delegate = self
        addressField.delegate = self
        descriptionField.delegate = self
        
        addressField.filterStrings(["Red", "Blue", "Yellow"])
        
        scrollView.delegate = self
        
        searchCompleter.delegate = self
        // TODO: Change region (hardcoded Monash Uni)
        searchCompleter.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -37.910549, longitude: 145.136218), latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        addressField.userStoppedTypingHandler = {
            if let criteria = self.addressField.text {
                if criteria.count > 1 {
                    print(criteria)
                    self.searchCompleter.queryFragment = criteria
                }
            }
        }
    }
    
    @IBAction func pickLocation(_ sender: Any) {
    }

    
    @IBAction func pickImages(_ sender: Any) {
        
        let imagePicker = ImagePickerController()
        
        presentImagePicker(imagePicker, select: { (asset) in
            // User selected an asset. Do something with it. Perhaps begin processing/upload?
        }, deselect: { (asset) in
            // User deselected an asset. Cancel whatever you did when asset was selected.
        }, cancel: { (assets) in
            // User canceled selection.
        }, finish: { (assets) in
            // User finished selection assets.
            
            assets.forEach { asset in
                
//                let resources = PHAssetResource.assetResources(for: asset)
//                let fileName = resources.first?.originalFilename
                
                PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil) { (image, info) in
                    if info!["PHImageResultIsDegradedKey"] as! Int == 1 {
                        return
                    }
                    let imageView = ListingImageView(image: image)
                    imageView.widthAnchor.constraint(equalToConstant: 250).isActive = true
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    
                    self.imagesPNG.append((image?.pngData())!)
                    
                    self.imageStack.insertArrangedSubview(imageView, at: self.imageStack.arrangedSubviews.count - 1)
                }
            }
        })
    }
    
    func uploadImages() -> [URL] {
        
        var downloadURLs: [URL] = []
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        imagesPNG.forEach { imageData in
            
            let fileName = NSUUID().uuidString
            print(fileName)
            let uploadRef = storageRef.child("images/\(fileName).png")
            
            _ = uploadRef.putData(imageData, metadata: nil) { metadata, error in
                guard metadata != nil else {
                    print("Error uploading images")
                    return
                }
                
                uploadRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error getting downloadURL")
                        return
                    }
                    downloadURLs.append(downloadURL)
                    
                    if (downloadURLs.count == self.imagesPNG.count) { // all images have been uploaded, add listing now
                        self.newListing.imageURLs = downloadURLs
                        
                        let _ = self.databaseController?.addListing(listing: self.newListing)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        return downloadURLs
    }
    
    @IBAction func saveListing(_ sender: Any) {
        
        // TODO: Validation
        
        let spinner = UIActivityIndicatorView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        spinner.startAnimating()
        
        _ = uploadImages()
        
        newListing.title = titleField.text
        newListing.quantity = Int(quantityField.text!)
        newListing.unit = unitField.text
        newListing.address = addressField.text
        newListing.desc = descriptionField.text
    
    }

    func pickCategory(category: Category) {
        categoryField.text = category.name
        newListing.category = category
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickCategorySegue" {
            let categoryPicker = segue.destination as! CategoriesTableViewController
            categoryPicker.pickCategoryDelegate = self
        }
    }
}

extension NewListingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addressField.hideResultsList()
    }
}

extension NewListingViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.accessibilityIdentifier == "category" {
            performSegue(withIdentifier: "pickCategorySegue", sender: nil)
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension NewListingViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        print(searchResults)
    }
}
