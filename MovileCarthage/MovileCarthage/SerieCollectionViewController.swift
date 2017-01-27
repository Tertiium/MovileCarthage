////
////  SerieCollectionViewController.swift
////  MovileCarthage
////
////  Created by user on 13/01/17.
////  Copyright © 2017 user. All rights reserved.
////

import UIKit
import Alamofire

private let reuseIdentifier = "celulaPersonalizada"

class SerieCollectionViewController: UICollectionViewController {
    
    // MARK: - Outlets
    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: - Properties
    var arraySeries : [Serie] = []
    var serieJson : [[String : AnyObject]] = []
    
    var refreshControl = UIRefreshControl()
    var dateFormatter = DateFormatter()
    
    // MARK: - Cycle Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "SerieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:reuseIdentifier)
        
        // Fazendo a requesição de dados
        self.requestSerie()
        
        // Construção do activityIndicator
        activityIndicator.center = (self.collectionView?.center)!
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Construção do Pull to Fresh
        
        // Definidno o formato da Data e do Horario
        self.dateFormatter.dateStyle = DateFormatter.Style.short
        self.dateFormatter.timeStyle = DateFormatter.Style.long
        // Defindino Refresh Control
        self.refreshControl.addTarget(self, action: #selector(refreshSerie), for: .valueChanged)
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.collectionView?.addSubview(refreshControl)
        
        
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return serieJson.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SerieCollectionViewCell
        
        // Passar os dados para os outlets
        if let url = self.serieJson[indexPath.row]["ids"] as? String{
            if let nsurl = NSURL(string: url) {
                if let data = NSData(contentsOf: nsurl as URL) {
                    cell.imageViewSerie.image = UIImage(data: data as Data)
                    cell.labelSerie.text = serieJson[indexPath.row]["title"] as? String
                }
            }
        }
        
        // Configure the cell
        return cell
    }
    
    // MARK: - Funtions
    
    // Função de Refresh
    func refreshSerie(){
        
        // Zerar o array
        self.serieJson = []
        
        // Refazer o request das Séries
        self.requestSerie()
        
        // Pegar a data atual
        let now = NSDate()
        let updateString = "Last Updated at " + self.dateFormatter.string(from: now as Date)
        self.refreshControl.attributedTitle = NSAttributedString(string: updateString)
    }
    
    func requestSerie(){
        
        // Headers do url da Requisição das Séries
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "trakt-api-version":"2",
            "trakt-api-key":"f01add05b3d743e855e43b3d1900d8b35bcc144c3227586b1b2a1cc85c57c44c"
        ]
        
        
        // Fazendo a requisição via Alamofire para trazer as séries mais populares
        Alamofire.request("https://api.trakt.tv/shows/popular", method: .get, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let serieJson = response.result.value as? [[String : AnyObject]]{
                    
                    // Print da requisição em formato Json
                    // print(serieJson)
                    self.serieJson = serieJson
                    
                    //Percorrer o Json da Serie para pegar o poster da cada Série
                    for i in 0..<self.serieJson.count{
                        
                        if let id: String = self.serieJson[i]["ids"]!["imdb"]! as? String{
                            
                            print("ID: \(id)")
                            //Requisição para pegar o url do poster
                            Alamofire.request("https://www.omdbapi.com/?i=\(id)").responseJSON(completionHandler: { (response) in
                                switch response.result{
                                    
                                case .success:
                                    if let imageJson = response.result.value as? [String : AnyObject]{
                                        self.serieJson[i]["ids"] = imageJson["Poster"]
                                    }
                                    self.collectionView?.reloadData()
                                    
                                case .failure(let error):
                                    // Print do erro para o log
                                    print("Erro no OMDB: \(error.localizedDescription as String)")
                                    
                                    // Exibindo alerta de erro para o usuario
                                    let actionErro =  UIAlertController(title: "Problema ao carregar os filmes", message: "Ocorreu um erro ao tentar carregar a lista de filmes, tente novamente mais tarde!", preferredStyle: .alert)
                                    
                                    actionErro.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                    
                                    // Mostrando a UIAlertController na tela
                                    self.present(actionErro, animated: true, completion: nil)

                                    
                                }
                            })
                            
                        }
                        
                    }
                    
                }
                
            }else if response.result.isFailure{
                
                // Print do erro para o log
                print("Erro no Trakt: \(response.result.error!.localizedDescription as String)")
                
                // Exibindo alerta de erro para o usuario
                let actionErro =  UIAlertController(title: "Problema ao carregar os filmes", message: "Ocorreu um erro ao tentar carregar a lista de filmes, tente novamente mais tarde!", preferredStyle: .alert)
                
                actionErro.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                // Mostrando a UIAlertController na tela
                self.present(actionErro, animated: true, completion: nil)
            }
            
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            print("*****************")
        }
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SerieCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    // Definindo o tamanho de cada collection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 200)
    }
    
}
