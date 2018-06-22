//
//  TableViewDataSource.swift
//  Animations
//
//  Created by Evgeny Mitko on 16.06.2018.
//  Copyright © 2018 Evgeny Mitko. All rights reserved.
//

import UIKit

class TableViewDataSource {
        
    let numberOfImages = 10
    let numberImageRepeat = 4
    
    let tableView: UITableView

    var posts: [Post] = []
    
    var numberOfRows: Int {
        return posts.count
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.separatorStyle = .none
        generateDataSource()
    }
    
    func generateDataSource() {
        let totalCount = numberOfImages * numberImageRepeat
        for i in 0...totalCount {
            let photo = getImage(for: i)
            posts.append(Post(photo: photo, isLiked: false))
        }
    }
    
    
    func cellFor(row: Int) -> TableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let post = posts[row]
        cell.set(image: post.photo)
        let likeImage = post.isLiked ? #imageLiteral(resourceName: "LikeButtonActivated.png") : #imageLiteral(resourceName: "LikeButton")
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.rowNumber = row
        return cell
    }
    
    private func getImage(for index: Int) -> UIImage {
        let roundIndex = Int(index / numberOfImages)
        let imageIndex = index - (numberOfImages * roundIndex)
        let image = UIImage(named: "\(imageIndex + 1)")!
        return image
    }
    
    
    
    
}
