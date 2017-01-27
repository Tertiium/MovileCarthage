//
//  Serie.swift
//  MovileCarthage
//
//  Created by user on 12/01/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation

/// Classe que representa as informações de um série

class Serie{
    
    //MARK: - Definição das propriedades
    
    /// Propriedade que representa o nome da série
    var nome = ""
    /// Propriedade que representa o id da série do tvdb
    var id = 0
    /// Propriedade que representa o ano que iniciou a série
    var ano = 0
    /// Propriedade que representa o url da imagem do poster da série
    var imageUrl = ""
    
    //MARK: - Inicializadores
    
    /*
     Inicializador que será utilizado para quando estivermos criando um serie.
     
     - parameter umNome: Recebe o nome da série
     - parameter umId: Recebe o id da série do tvdb
     - parameter umAno: Recebe o ano que iniciou a série
     - parameter umImageUrl: Rebebe o url da imagem do poster da série
     
     -returns: Retorna uma instância da série
     */
    
    init(comNome umNome: String, comID umID: Int, comAno umAno: Int, comImageUrl umImageUrl: String) {
        self.nome = umNome
        self.id = umID
        self.ano = umAno
        self.imageUrl = umImageUrl
    }
}
