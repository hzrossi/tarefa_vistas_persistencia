//
//  Livro.swift
//  tarefa-vistas
//
//  Created by Henrique Zuchetto Rossi on 17/06/16.
//  Copyright © 2016 Henrique Zuchetto Rossi. All rights reserved.
//

//isbn teste: 0201075253 / 0201531747 / 978-84-376-0494-7

import Foundation
import UIKit

struct Livro {
	var titulo:String
	var autores:[String]
	var capa:UIImage

	init(Titulo:String, Autores:[String], Capa:UIImage) {
	self.titulo = Titulo
	self.autores = Autores
	self.capa = Capa
	}
}