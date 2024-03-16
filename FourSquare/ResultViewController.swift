//
//  ResultViewController.swift
//  FourSquare
//
//  Created by Hakan Hardal on 22.11.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ResultViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var detaiLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedName = ""
    var selectedId : UUID?
    //---
    var annotationLongitude = Double()
    var annotationLatitude = Double()
    var annotationTitle = ""
    var annotationSubtitle = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let locationManager = CLLocationManager()
        mapView.delegate = self
        locationManager.delegate = self
        if selectedName != ""{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "All")
            let idString = selectedId!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let imageData = result.value(forKey: "image") as? Data{
                            imageView.image = UIImage(data: imageData)
                            if let title = result.value(forKey: "name") as? String{
                                annotationTitle = title
                                if let subtitle = result.value(forKey: "details") as? String{
                                  annotationSubtitle = subtitle
                                    if let longitude = result.value(forKey: "longitude") as? Double{
                                        annotationLongitude = longitude
                                        if let latitude = result.value(forKey: "latitude") as? Double{
                                            annotationLatitude = latitude
                                            
                                            // seçilen id deki bilgilerin anotasyon ile konumda gösterimi
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            mapView.addAnnotation(annotation)
                                            nameLabel.text = annotationTitle
                                            detaiLabel.text = annotationSubtitle
                                            
                                            locationManager.stopUpdatingLocation()
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }catch{
               print("Error")
            }
            
            
        }
        
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "my"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedName != "" {
         
            var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                if let placeMark = placemarks{
                    if placeMark.count > 0{
                        let newPlacemark = MKPlacemark(placemark: placeMark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        
                        item.name = self.annotationTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
            
        }
    }
    
    
    


}
