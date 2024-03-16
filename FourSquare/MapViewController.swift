//
//  MapViewController.swift
//  FourSquare
//
//  Created by Hakan Hardal on 22.11.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate{
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    var locationManager = CLLocationManager()
    var chosenLongitude = Double()
    var chosenLatitude = Double()
    var secilenTitle = ""
    
    //isimler
    var namesText = ""
    var detailsText = ""
    var imagedata : Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(namesText)
        print(detailsText)
        let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
        mapView.removeAnnotations(annotations)
        
        
        
       
        mapView.delegate = self
        locationManager.delegate = self
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(choseLocation(gestureRecognizer:)))
     
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if secilenTitle == ""{
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
            
        }
    }
    @objc func choseLocation(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let touchedPoint = gestureRecognizer.location(in: self.mapView) // dokunulan yeri bulma
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView) // dokunulan noktay kordinata çevir
            
            chosenLongitude = touchedCoordinates.longitude
            chosenLatitude = touchedCoordinates.latitude
            
            //pin oluşturma
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates // pin dokunulan yerde oluşturulcak
            annotation.title = self.namesText
            annotation.subtitle = self.detailsText
            
            self.mapView.addAnnotation(annotation)
            
        }
        
        
    }
    
    
    @IBAction func saveClick(_ sender: Any) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newAll = NSEntityDescription.insertNewObject(forEntityName: "All", into: context)
       
        if namesText == "" && detailsText == ""{
            alert(error: "Error", message: "Name&Detail can not empty", button: "Ok")
        }else{
            newAll.setValue(namesText, forKey: "name")
            newAll.setValue(detailsText, forKey: "details")
            if self.chosenLatitude != 0.0 && self.chosenLongitude != 0.0 && self.imagedata != nil{
                newAll.setValue(chosenLatitude, forKey: "latitude")
                newAll.setValue(chosenLongitude, forKey: "longitude")
                newAll.setValue(imagedata, forKey: "image")
                newAll.setValue(UUID(), forKey: "id")
                do{
                    try context.save()
                    print("Succes")
                }catch{
                    print("Error")
                }
            }else{
                alert(error: "Error", message: "Location&Image can not empty", button: "Ok")
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        performSegue(withIdentifier: "maptoPlacesVC", sender: nil)
        
    }
    
    
    func alert(error:String,message:String,button:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel)
        alert.addAction(ok)
        present(alert, animated: true)
        
    }
    
    func findLocation(){
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if secilenTitle == ""{
                let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
                let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                let region = MKCoordinateRegion(center: location, span: span)
                mapView.setRegion(region, animated: true)
                
            }
        }
    }
    
}

