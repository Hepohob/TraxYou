//
//  GPXViewController.swift
//  TraxYou
//
//  Created by Aleksei Neronov on 03.01.17.
//  Copyright © 2017 Aleksei Neronov. All rights reserved.
//

import UIKit
import MapKit

class GPXViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .satellite
            mapView.delegate = self
        }
    }
    
    var gpxURL:URL? {
        didSet {
            clearWaypoints()
            if let url = gpxURL {
                GPX.parse(url) { gpx in
                    if gpx != nil {
                        self.addWaypoints(gpx!.waypoints)
                    }
                }
            }
        }
    }
    
    private func clearWaypoints() {
        mapView?.removeAnnotations(mapView.annotations )
    }
    
    private func addWaypoints(_ waypoints:[GPX.Waypoint]) {
        mapView?.addAnnotations(waypoints)
        mapView?.showAnnotations(waypoints, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gpxURL = NSURL(string: "http://cs193p.stanford.edu/Vacation.gpx") as URL?
        title = "Trax You"
    }

    //MARK: MKMapView delegates
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view.canShowCallout = true
        } else {
            view.annotation = annotation
        }
        
        view.leftCalloutAccessoryView = nil
        if let waypoint = annotation as? GPX.Waypoint {
            if waypoint.thumbnailURL != nil {
                view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton,
                let url = (view.annotation as? GPX.Waypoint)?.thumbnailURL,
                let imageData = try? Data(contentsOf: url as URL),
                let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    thumbnailImageButton.setImage(image, for: UIControlState())
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            performSegue(withIdentifier: Constants.ShowImageSegue, sender: view)
        }
    }

    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            let waypoint = GPX.Waypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Some name"
            mapView.addAnnotation(waypoint)
        }
    }

    // MARK: Constants
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59) // sad face
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditUserWaypoint = "Edit Waypoint"
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contentViewController
        let annotationView = sender as? MKAnnotationView
        let waypoint = annotationView?.annotation as? GPX.Waypoint
        
        if segue.identifier == Constants.ShowImageSegue {
            if let ivc = destination as? ImageViewController {
                ivc.imageURL = waypoint?.imageURL as NSURL?
                ivc.title = waypoint?.name
            }
        }
     /*   else if segue.identifier == Constants.EditUserWaypoint {
            if let editableWaypoint = waypoint as? EditableWaypoint,
                let ewvc = destination as? EditWaypointViewController {
                if let ppc = ewvc.popoverPresentationController {
                    ppc.sourceRect = annotationView!.frame
                    ppc.delegate = self
                }
                ewvc.waypointToEdit = editableWaypoint
            }
        }
 */
    }

}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}

