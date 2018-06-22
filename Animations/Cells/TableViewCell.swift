//
//  TableViewCell.swift
//  Animations
//
//  Created by Evgeny Mitko on 16.06.2018.
//  Copyright © 2018 Evgeny Mitko. All rights reserved.
//

import UIKit

protocol CellActionsProtocol: class {
    func longPressActionDidStart(on avatarImageView: UIImageView)
    func longPressActionDidStop(on avatarImageView: UIImageView)
    func panActionDidStart(on likeButton: UIButton)
    func panActionDidMove(_ likeButton: UIButton, to position: CGPoint, target: UIImageView)
    func panActionDidStop(on likeButton: UIButton, target: UIImageView, at row: Int)

}

class TableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    weak var delegate: CellActionsProtocol?
    var rowNumber: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        addAvatarLongPress()
        addPanGesture()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(image: UIImage) {
        photoImageView.image = image
    }
    
    private func addAvatarLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.avatarLongPressAction(_:)))
        avatarImageView.addGestureRecognizer(longPress)
        
    }
    
    @objc private func avatarLongPressAction(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            delegate?.longPressActionDidStart(on: avatarImageView)
        case .ended, .failed, .cancelled:
            delegate?.longPressActionDidStop(on: avatarImageView)
        default:
            return
        }
    }
    
    private func addPanGesture() {
        // 1. Create pan gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.likePanAction(_:)))
        // 2. Add pan gesture to likeButton
        likeButton.addGestureRecognizer(pan)
    }

    @objc private func likePanAction(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            // 1. Call delegate method
            delegate?.panActionDidStart(on: likeButton)
        case .changed:
            // 2. Calculate new target position of likeButton on every pan gesture change
            let translation = pan.translation(in: self)
            let newPosition = CGPoint(x: likeButton.center.x + translation.x,
                                      y: likeButton.center.y + translation.y)
            delegate?.panActionDidMove(likeButton, to: newPosition, target: photoImageView)
        case .ended, .cancelled, .failed:
            // 3. Call delegate method
            delegate?.panActionDidStop(on: likeButton, target: photoImageView, at: rowNumber)
        default:
            break
        }
    }
}
