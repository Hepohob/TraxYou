//
//  EditWaypointViewController.swift
//  TraxYou
//
//  Created by Aleksei Neronov on 04.01.17.
//  Copyright © 2017 Aleksei Neronov. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController, UITextFieldDelegate {

    //MARK: OUTLEST
    
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }

    @IBOutlet weak var descriptionTextField: UITextField! { didSet { descriptionTextField.delegate = self } }
    
    //MARK: Public API
    
    var waypointToEdit: EditableWaypoint? { didSet { updateUI() } }
    
    //MARK: Private declaration
    
    private func updateUI() {
        nameTextField?.text = waypointToEdit?.name
        descriptionTextField?.text = waypointToEdit?.info
    }
    
    private var ntfObserver: NSObjectProtocol?
    private var itfObserver: NSObjectProtocol?

    private func listenToTextFields() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        
        ntfObserver = center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange,
                           object: nameTextField,
                           queue: queue) { notification in
                            if let waypoint = self.waypointToEdit {
                                waypoint.name = self.nameTextField.text
                            }
        }
        itfObserver = center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange,
                           object: descriptionTextField,
                           queue: queue) { notification in
                            if let waypoint = self.waypointToEdit {
                                waypoint.info = self.descriptionTextField.text
                            }
        }
    }
    
    private func stopListeningToTextFields() {
        if let observer = ntfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = itfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    //MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        nameTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenToTextFields()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopListeningToTextFields()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        preferredContentSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    //MARK: Textfield delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
