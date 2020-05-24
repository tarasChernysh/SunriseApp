//
//  HomeViewController.swift
//  Sunrise
//
//  Created by Macbook Air 13 on 5/7/19.
//  Copyright © 2019 Ihor Chernysh. All rights reserved.
//

import UIKit
import Moya
import CoreLocation
import GooglePlaces

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var sunriseTimeLabel: UILabel!
    @IBOutlet weak var sunsetTimeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var localDateLabel: UILabel!
    @IBOutlet weak var titleView: UINavigationItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var setCurrentUserLocationButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private let provider = MoyaProvider<Target>(plugins: [NetworkLoggerPlugin(verbose: true)])
    private var userLocation: CLLocationCoordinate2D?
    private var selectCityCoords: CLLocationCoordinate2D? {
        didSet {
            fetchData(coords: selectCityCoords)
        }
    }
    
    private let titleAlertController = "Увага"
    private let titleCancelAction = "Відмінити"
    private let titleSettingsAction = "Налаштування"
    private let messageErrorCoordinate = "Не вдалося отримати координати. Спробуйте будь ласка пізніше"
    private let messageOpenSettings = "Ви можете змінити налаштування доступу до локації."
    private let messageErrorGetInfo = "Помилка отримання даних про схід та захід сонця. Спробуйте будь ласка пізніше"
    
    private let dateFormat = "MMM d, hh:mm a"
    
    // MARK: - IBActions
    
    @IBAction func currentLocationTapped(_ sender: UIButton) {
        textField.text = nil
        fetchData(coords: userLocation)
        setCurrentUserLocationButton.isHidden = true
    }
    
    @IBAction func textFieldTapped(_ sender: Any) {
        textField.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self 
        present(acController, animated: true, completion: nil)
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentDate()
        checkAccessUserLocation()
        getUserLocation()
        setupVC()
    }
    
    // MARK: - Helper methods
  
    private func setupVC() {
        setCurrentUserLocationButton.isHidden = true
        setCurrentUserLocationButton.layer.cornerRadius = 10
    }
    
    private func getUserLocation() {
        activityIndicatorView.startAnimating()
        UserLocationService.shared.currentCoordinate = { [weak self] userLocation in
            self?.userLocation = userLocation
            self?.fetchData(coords: userLocation)
        }
    }
    
    private func fetchData(coords: CLLocationCoordinate2D?) {
        activityIndicatorView.startAnimating()
        guard let coordinate = coords else {
            showAlertController(withMessage: messageErrorCoordinate)
            return
        }
        provider.request(.info(coordinate)) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let json):
                let jsonDecoder = JSONDecoder()
                guard let info = try? jsonDecoder.decode(Model.self, from: json.data) else { return }
                DispatchQueue.main.async {
                    strongSelf.sunsetTimeLabel.text = DateFormatterService.shared.convertToLocalDate(utcDateString: info.sunset)
                    strongSelf.sunriseTimeLabel.text = DateFormatterService.shared.convertToLocalDate(utcDateString: info.sunrise)
                }
            case .failure(let error):
                print("error get info \(error.localizedDescription)")
                strongSelf.showAlertController(withMessage: strongSelf.messageErrorGetInfo)
            }
            strongSelf.activityIndicatorView.stopAnimating()
        }
    }
    
    func getCurrentDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: Date())
        localDateLabel.text = date
    }
    
    
    private func checkAccessUserLocation() {
        let isAuthorized = UserLocationService.shared.checkLocationAuthorizationStatus()
        if !isAuthorized {
            let settingsAction = UIAlertAction(title: titleSettingsAction, style: .default) { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            showAlertController(withMessage: messageOpenSettings, action: settingsAction)
        } else {
            print("Authorization is success!")
        }
    }
    
    private func showAlertController(withMessage message: String, action: UIAlertAction? = nil) {
        let alertController = UIAlertController(title: titleAlertController, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: titleCancelAction, style: .cancel)
        if let someAction = action {
            alertController.addAction(someAction)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

// MARK: - GMSAutocompleteViewControllerDelegate

extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        textField.text = place.name
        setCurrentUserLocationButton.isHidden = false
        selectCityCoords = place.coordinate
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

