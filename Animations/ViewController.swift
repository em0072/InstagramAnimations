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
    let likeAnimatorDuration: TimeInterval = 0.5

    var tableViewDataSource: TableViewDataSource!
    
    // Avatar Animation Properties
    var zoomedImageView: UIImageView?
    lazy var overlayView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: nil)
        view.frame = self.view.bounds
        return view
    }()
    
    // Like Animation Properties
    var dragLikeAnimator: UIViewPropertyAnimator?
    var copiedLikeButton: UIButton?

    var dragLikeCompletionPercent: CGFloat = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewDataSource = TableViewDataSource(tableView: tableView)
        initTableView()
    }

    func initTableView() {
        tableView.dataSource = self
    }
    
    func initDragLikeAnimator(with button: UIButton) {
        dragLikeAnimator = UIViewPropertyAnimator(duration: likeAnimatorDuration, curve: .easeInOut, animations: {
            
        })
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

// MARK: - Like Animation
extension ViewController {
    
    func panActionDidStart(on likeButton: UIButton) {
        // 1. Convert like button frame from cell coordinate system to view controller coordinate system
        guard let convertedLikeFrame = likeButton.superview?.convert(likeButton.frame, to: view) else { return }
        // 2. Create copy of the like button
        copiedLikeButton = UIButton(frame: convertedLikeFrame)
        // 3. Copy imageEdgeInsets of the button
        copiedLikeButton?.imageEdgeInsets = likeButton.imageEdgeInsets
        // 4. Set image to the copy button
        copiedLikeButton?.setImage(likeButton.image(for: .normal), for: .normal)
        // 5. Add copy button to view controller
        self.view.addSubview(copiedLikeButton!)
        // 6. After that hide initial like button
        likeButton.isHidden = true
    }
    
    func panActionDidMove(_ likeButton: UIButton, to position: CGPoint, target: UIImageView) {
        // 1. Make sure that we have copy button and convert new position of the like button from cell coordinate system to view controller coordinate system
        guard let copiedLikeButton = copiedLikeButton,
            let convertedPosition = likeButton.superview?.convert(position, to: self.view) else { return }
        // 2. Set new coordinates
        copiedLikeButton.center = convertedPosition
    }

    func panActionDidStop(on likeButton: UIButton, target: UIImageView, at row: Int) {
        guard copiedLikeButton != nil else { return }
        let dragAnimator = UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut, animations: nil)
        var targetCenter: CGPoint?
        if dragLikeCompletionPercent < 0.5 {
            targetCenter = likeButton.superview?.convert(likeButton.center, to: view)
            dragAnimator.addCompletion { (_) in
                likeButton.isHidden = false
                self.copiedLikeButton?.removeFromSuperview()
                self.copiedLikeButton = nil
            }
        } else {
            targetCenter = target.superview?.convert(target.center, to: view)
            dragAnimator.addCompletion { (_) in
                self.performLikeAnimation(initialLikeButton: likeButton)
                self.tableViewDataSource.posts[row].isLiked = true
            }
        }
        guard let targetPoint = targetCenter else { return }
        dragAnimator.addAnimations {
            self.copiedLikeButton?.center = targetPoint
        }
        dragAnimator.startAnimation()
    }

    func performLikeAnimation(initialLikeButton: UIButton) {
        guard copiedLikeButton != nil else { return }
        let likeAnimator = UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut, animations: nil)
        initialLikeButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        initialLikeButton.isHidden = false
        initialLikeButton.setImage(#imageLiteral(resourceName: "LikeButtonActivated.png"), for: .normal)
        likeAnimator.addAnimations {
            self.copiedLikeButton?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            initialLikeButton.transform = CGAffineTransform.identity
        }
        likeAnimator.addCompletion { (_) in
            self.copiedLikeButton?.removeFromSuperview()
            self.copiedLikeButton = nil
        }
        likeAnimator.startAnimation()
    }
}


