//
//  ListaLivros_TableViewController.swift
//  tarefa-vistas
//
//  Created by Henrique Zuchetto Rossi on 17/06/16.
//  Copyright © 2016 Henrique Zuchetto Rossi. All rights reserved.
//

import UIKit

class ListaLivros_TableViewController: UITableViewController, Adicionar_ViewDelegate {

	var listaLivros:[Livro]!

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Livros"

		/*if (listaLivros != nil) {
			print(listaLivros!)
		}*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (listaLivros != nil) {
			return listaLivros.count
		}
		else {
        	return 0
		}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("celulaLivro", forIndexPath: indexPath)
		cell.textLabel?.text = listaLivros[indexPath.row].titulo
        return cell
    }

	func setLivros(livros: [Livro]) {
		listaLivros = livros
		tableView.reloadData()
	}

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "segueAdicionar") {
			let viewAdicionar:Adicionar_ViewController = segue.destinationViewController as! Adicionar_ViewController
			if (listaLivros != nil) {
				viewAdicionar.livros = listaLivros
			}
			viewAdicionar.delegate = self
			
		}
		else if (segue.identifier == "segueDetalhes") {
			let viewDetalhes:Detalhes_ViewController = segue.destinationViewController as! Detalhes_ViewController
			let linhaSelecionada = self.tableView.indexPathForSelectedRow //pega o índice da linha selecionada (indexPath)
			viewDetalhes.titulo = self.listaLivros[linhaSelecionada!.row].titulo
			viewDetalhes.autores = self.listaLivros[linhaSelecionada!.row].autores
			viewDetalhes.capa = self.listaLivros[linhaSelecionada!.row].capa
		}
    }
}
