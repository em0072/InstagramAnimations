//
//  ViewController.swift
//  Animations
//
//  Created by Evgeny Mitko on 16.06.2018.
//  Copyright © 2018 Evgeny Mitko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let animationDuration: TimeInterval = 0.3

    var tableViewDataSource: TableViewDataSource!
    
    // Avatar Animation Properties
    var zoomedImageView: UIImageView?
    lazy var overlayView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: nil)
        view.frame = self.view.bounds
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewDataSource = TableViewDataSource(tableView: tableView)
        initTableView()
    }

    func initTableView() {
        tableView.dataSource = self
    }
    

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewDataSource.cellFor(row: indexPath.row)
        cell.delegate = self
        return cell
    }
    
}

// MARK: - Avatar Animation
extension ViewController: CellActionsProtocol {
    
    func longPressActionDidStart(on avatarImageView: UIImageView) {
        // 1. Create Avatar Copy ImageView
        zoomedImageView = createAvatarCopyToZoom(from: avatarImageView)
        // 2. Hide avatarImageView in cell
        avatarImageView.isHidden = true
        // 3. Perform Position Calculations and animation
        animateZoomIn()
    }
    
    func longPressActionDidStop(on avatarImageView: UIImageView) {
        // 1. Return everything to initial state with animation
        animateZoomOut() {
            // 2. on animation completion show avatarImageView in cell
            avatarImageView.isHidden = false
            // 3. and remove Avatar Copy ImageView
            self.zoomedImageView?.removeFromSuperview()
            self.zoomedImageView = nil
        }
    }
    
    func createAvatarCopyToZoom(from imageView: UIImageView) -> UIImageView? {
        // 1. Create avatar copy (we need our avatar ImageView to be on top of the tableView)
        let avatarCopy = UIImageView(image: imageView.image)
        // 2. Convert frame from cell coordinate system to viewController coordinate system
        guard let convertedAvatarFrame = imageView.superview?.convert(imageView.frame, to: view) else { return nil }
        avatarCopy.frame = convertedAvatarFrame
        view.addSubview(avatarCopy)
        // 3. Make avatarCopy circular
        avatarCopy.layer.cornerRadius = avatarCopy.frame.width / 2
        avatarCopy.clipsToBounds = true
        // 4.And return
        return avatarCopy
    }
    
    func animateZoomIn() {
        guard let zoomedImageView = zoomedImageView else { return }
        // 1. Calculate target scale
        let targetWidth = view.frame.width
        let scaleFactor = targetWidth / zoomedImageView.frame.width
        // 2. Calculate target y and x translations
        let targetY = view.center.y
        let yTranslation = targetY - zoomedImageView.center.y
        let targetX = view.center.x
        let xTranslation = targetX - zoomedImageView.center.x
        
        // NEW: add overlay color
        view.insertSubview(overlayView, belowSubview: zoomedImageView)
        // 3. Animate
        UIView.animate(withDuration: animationDuration) {
            self.overlayView.effect = UIBlurEffect(style: .dark)
            zoomedImageView.transform = CGAffineTransform.identity
                .translatedBy(x: xTranslation, y: yTranslation)
                .scaledBy(x: scaleFactor, y: scaleFactor)
        }
    }
    
    func animateZoomOut(completion: @escaping () -> Void) {
        guard let zoomedImageView = zoomedImageView else { return }
        // 1. Just animate
        UIView.animate(withDuration: animationDuration, animations: {
            self.overlayView.effect = nil
            zoomedImageView.transform = CGAffineTransform.identity
        }) { finished in
            self.overlayView.removeFromSuperview()
            completion()
        }
    }
}



