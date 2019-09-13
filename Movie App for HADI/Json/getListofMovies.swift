//
//  getListofMovies.swift
//  MovieDBApp HAdi
//
//  Created by Oğuz Karatoruk on 10.09.2019.
//  Copyright © 2019 Oğuz Karatoruk. All rights reserved.
//

import Foundation

struct TopLevel : Decodable {
    let results: [GETMOVIES]
    let total_pages: Int
}

struct GETMOVIES:Decodable{
    let title: String
    let vote_average: Float
    let overview: String
    let release_date: String
    let poster_path: String
}
