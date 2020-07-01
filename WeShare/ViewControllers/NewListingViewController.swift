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
import Firebase
import Promises

class NewListingViewController: UIViewController, PickCategoryDelegate {

    weak var databaseController: DatabaseProtocol?
    
    var imagesPNG: [Data] = []

    let INFO_CELL = "infoCell"
    
    var newListing: Listing = Listing() // initialize an empty Listing
    
    @IBOutlet weak var imageStack: UIStackView!
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var givingSwitch: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var unitField: UITextField!
    @IBOutlet weak var addressField: SearchTextField!
    @IBOutlet weak var descriptionField: UITextView!
    
    var searchCompleter = MKLocalSearchCompleter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImageButton.setImage(UIImage(systemName: "photo"), for: .normal)
        addImageButton.imageView?.contentMode = .scaleAspectFit
        addImageButton.layer.borderWidth = 1
        addImageButton.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        
        descriptionField.layer.borderWidth = 1
        descriptionField.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        descriptionField.layer.cornerRadius = 5.0
        descriptionField.text = "Description"
        descriptionField.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        descriptionField.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        givingSwitch.onTintColor = UIColor.GIVING
        givingSwitch.tintColor = UIColor.ASKING
        givingSwitch.layer.cornerRadius = givingSwitch.frame.height / 2
        givingSwitch.backgroundColor = UIColor.ASKING
        
        titleField.delegate = self
        categoryField.delegate = self
        quantityField.delegate = self
        unitField.delegate = self
        addressField.delegate = self
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
        addressField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition] as! AddressSuggestion
            self.addressField.text = item.title
            
            let searchRequest = MKLocalSearch.Request(completion: item.completion!)
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                if error == nil {
                    let coordinate = response?.mapItems[0].placemark.coordinate
                    self.newListing.location = [(coordinate?.latitude)!, (coordinate?.longitude)!]
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
    
    func uploadImages() -> Promise<[URL]> {
        
        var downloadURLs: [URL] = []
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        return Promise { fulfill, reject in
            self.imagesPNG.forEach { imageData in
                
                let fileName = NSUUID().uuidString
                print(fileName)
                let uploadRef = storageRef.child("images/\(fileName).png")
                
                _ = uploadRef.putData(imageData, metadata: nil) { metadata, error in
                    if metadata == nil {
                        print("Error uploading images")
                        reject(error!)
                    }
                    
                    uploadRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            print("Error getting downloadURL")
                            reject(error!)
                            return
                        }
                        downloadURLs.append(downloadURL)
                        
                        if (downloadURLs.count == self.imagesPNG.count) { // all images have been uploaded, add listing now
                            self.newListing.imageURLs = downloadURLs
                            fulfill(downloadURLs)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func saveListing(_ sender: Any) {
        
        // TODO: Validation
        
        let spinner = UIActivityIndicatorView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        spinner.startAnimating()
        
        uploadImages().then { (urls) in
            self.newListing.imageURLs = urls
            self.newListing.title = self.titleField.text
            self.newListing.quantity = Int(self.quantityField.text!)
            self.newListing.remaining = self.newListing.quantity
            self.newListing.unit = self.unitField.text
            self.newListing.address = self.addressField.text
            self.newListing.desc = self.descriptionField.text
            self.newListing.giving = self.givingSwitch.isOn
            _ = self.databaseController?.addListing(listing: self.newListing)
            self.navigationController?.popViewController(animated: true)
        }
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
        
        let suggestions = completer.results.map { AddressSuggestion(title: $0.title + ", " + $0.subtitle, completion: $0 ) }
        
        addressField.filterItems(suggestions)
    }
}

extension NewListingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22) {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        }
    }
}
