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
    

}
