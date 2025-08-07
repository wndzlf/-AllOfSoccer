//
//  GameMatchingDetailViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/15.
//

import UIKit
//import NMapsMap

class GameMatchingDetailViewController: UIViewController {

    private var viewModel: [String] = []

    lazy var likeBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "HeartDeSeleded"), style: .plain, target: self, action: #selector(likeBarbuttonTouchUp(_:)))
        button.tintColor = .clear
        return button
    }()

    lazy var shareBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "ShareNetwork"), style: .plain, target: self, action: #selector(shareBarButtonTouchup(_:)))
        button.tintColor = .black
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()


        setupNavigationItem()
        setnaverMapView()
    }

    private func setupNavigationItem() {
        self.navigationItem.title = "팀 모집"
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.black,
         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)]
        self.navigationController?.navigationBar.topItem?.title = ""

        self.navigationItem.rightBarButtonItems = [self.likeBarButton, self.shareBarButton]
    }

    private func setnaverMapView() {

//        setCamera()
//        setMarker()
    }

//    private func setCamera() {
//        let camPoition = NMGLatLng(lat: 37.5670135, lng: 126.9783740)
//        let cameraUpdate = NMFCameraUpdate(scrollTo: camPoition)
//        //self.naverMapView.moveCamera(cameraUpdate)
//    }
//
//    private func setMarker() {
//        let marker = NMFMarker()
//        marker.position = NMGLatLng(lat: 37.5670135, lng: 126.9783740)
//        marker.iconImage = NMF_MARKER_IMAGE_BLACK
//        marker.iconTintColor = UIColor.red
//        marker.width = 50
//        marker.height = 60
//        //marker.mapView = self.naverMapView
//
//        // 정보창 생성
//        let infoWindow = NMFInfoWindow()
//        let dataSource = NMFInfoWindowDefaultTextSource.data()
//        dataSource.title = "서울특별시청"
//        infoWindow.dataSource = dataSource
//
//        // 마커에 달아주기
//        infoWindow.open(with: marker)
//    }

    @objc private func likeBarbuttonTouchUp(_ sender: UIControl) {
        print("likeBarButton이 찍혔습니다.")

        sender.isSelected.toggle()
        if sender.isSelected {
            self.likeBarButton.image = UIImage(named: "HeartSelected")
        } else {
            self.likeBarButton.image = UIImage(named: "HeartDeSeleded")
        }
    }

    @objc private func shareBarButtonTouchup(_ sender: UIBarButtonItem) {
        print("shareBarButton이 찍혔습니다.")

        for testString in 0...3 {
            self.viewModel.append(String(testString))
        }

        let activityViewController = UIActivityViewController(activityItems: self.viewModel, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}


//extension GameMatchingDetailViewController: NMFMapViewDelegate {
//
//}
