//
//  ViewController.swift
//  Movie App for HADI
//
//  Created by Oğuz Karatoruk on 10.09.2019.
//  Copyright © 2019 Oğuz Karatoruk. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage     // save images to cache
import SwiftGifOrigin // load.gif

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var getMovies = [GETMOVIES]()
    var filteredMovies = [GETMOVIES]()
    
    var currentpage = 1
    var totalpage = 0
    
    var searching = false
    var scrollcontrol = true
    
    var apiKey = "6ebce9e2af4cc0ad98b1ba10b20a82a8"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.lightGray
        searchBar.delegate = self
        self.tableView.isHidden = true
        tableView.keyboardDismissMode = .onDrag
        SVProgressHUD.show()
        getMoviesList(page: "1") {
            print("Filmler Yukleniyor..")
        }
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK:- TABLEVIEW PARTS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredMovies.count
        } else {
            return getMovies.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let posterImageView : UIImageView = cell?.contentView.viewWithTag(1) as! UIImageView
        let titleLabel : UILabel = cell?.contentView.viewWithTag(2) as! UILabel
        let overviewLabel : UILabel = cell?.contentView.viewWithTag(3) as! UILabel
        let voteLabel : UILabel = cell?.contentView.viewWithTag(4) as! UILabel

        if searching {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(filteredMovies[indexPath.row].poster_path)")
            posterImageView.sd_setImage(with: url, placeholderImage: UIImage.gif(asset: "load.gif"))
            titleLabel.text = filteredMovies[indexPath.row].title
            overviewLabel.text = filteredMovies[indexPath.row].overview
            voteLabel.text = String(filteredMovies[indexPath.row].vote_average)
        } else {
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(getMovies[indexPath.row].poster_path)")
            posterImageView.sd_setImage(with: url, placeholderImage: UIImage.gif(asset: "load.gif"))
            titleLabel.text = getMovies[indexPath.row].title
            overviewLabel.text = getMovies[indexPath.row].overview
            voteLabel.text = String(getMovies[indexPath.row].vote_average)
        }
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = .darkGray
        cell?.selectedBackgroundView = bgColorView
        
        posterImageView.layer.cornerRadius = 8
        posterImageView.clipsToBounds = true
        posterImageView.layer.borderWidth = 2
        posterImageView.layer.borderColor = UIColor.white.cgColor
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showdetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK:- FONKSIYONLAR
    func messagebox(message:String){
        let alert = UIAlertController(title: "The MovieDB", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { action in
            print(message)
        }))
        self.present(alert, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searching == false {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height + 30  && scrollcontrol == true{
            print("NEXT")
            scrollcontrol = false
            insertnextpage()
        }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searching = false
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showdetails"
        {
            let destionationVC = segue.destination as! ShowDetailsViewController
            if searching {
                destionationVC.movieDetails = filteredMovies[(tableView.indexPathForSelectedRow?.row)!]
            }else{
            destionationVC.movieDetails = getMovies[(tableView.indexPathForSelectedRow?.row)!]
            }
        }
    }
    
    func insertnextpage(){
        if currentpage == totalpage {
            print("SON")
        }else{
        currentpage += 1
        SVProgressHUD.show()
        getMoviesList(page: String(currentpage)) {
            print("Page \(self.currentpage) is getting..")
        }
        }
    }
    
    func getMoviesList(page:String, completed: @escaping () -> ()){
        let url = URL(string: "https://api.themoviedb.org/4/list/1?api_key=\(apiKey)&page=\(page)&sort_by=release_date.desc")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil{
                do{
                    let result = try JSONDecoder().decode(TopLevel.self, from: data!)
                    if self.currentpage == 1 {
                    self.getMovies = result.results
                    } else {
                    self.getMovies = self.getMovies + result.results
                    }
                    print("Total Pages: \(result.total_pages)")
                    self.totalpage = result.total_pages
                    DispatchQueue.main.async {
                        completed()
                        print("Json Baglandi")
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                        self.tableView.isHidden = false
                        self.scrollcontrol = true
                    }
                }catch{
                    print("JSON Error \(error)")
                    self.messagebox(message: "İnternet bağlantınızı kontrol edip yeniden deneyin.")
                    SVProgressHUD.dismiss()
                }
            }
            }.resume()
    }
}



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = getMovies.filter({$0.title.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}
