//
//  ShowDetailsViewController.swift
//  Movie App for HADI
//
//  Created by Oğuz Karatoruk on 10.09.2019.
//  Copyright © 2019 Oğuz Karatoruk. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftGifOrigin

class ShowDetailsViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var OverviewText: UITextView!
    
    var movieDetails:GETMOVIES?
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://image.tmdb.org/t/p/w500\(String(movieDetails!.poster_path))")
        imageView.sd_setImage(with: url, placeholderImage: UIImage.gif(asset: "load.gif"))
        titleLbl.text = movieDetails?.title
        dateLbl.text = "Release date: \(String(movieDetails!.release_date)) | Vote Average: \(String(movieDetails!.vote_average))"
        OverviewText.text = movieDetails?.overview
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
    }
}
