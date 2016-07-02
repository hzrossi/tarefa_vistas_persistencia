//
//  ListaLivros_TableViewController.swift
//  tarefa-vistas
//
//  Created by Henrique Zuchetto Rossi on 17/06/16.
//  Copyright © 2016 Henrique Zuchetto Rossi. All rights reserved.
//

import UIKit
import CoreData

class ListaLivros_TableViewController: UITableViewController, Adicionar_ViewDelegate {

	var listaLivros:[Livro] = []
	var contexto:NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Livros"

		self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

		let secaoEntidade = NSEntityDescription.entityForName("Secao", inManagedObjectContext: self.contexto!)
		let peticao = secaoEntidade?.managedObjectModel.fetchRequestTemplateForName("petSecoes")
		do {
			let secoesEntidade = try self.contexto?.executeFetchRequest(peticao!)
			for secaoEntidade2 in secoesEntidade! {
				let livro = secaoEntidade2.valueForKey("tem") as! NSObject
				let titulo = livro.valueForKey("titulo") as! String
				let autores = livro.valueForKey("autores") as! String
				let capa = UIImage(data: livro.valueForKey("capa") as! NSData)
				listaLivros.append(Livro(Titulo: titulo, Autores: autores, Capa: capa!))
			}
		}
		catch _ {
			
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (!listaLivros.isEmpty) {
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
			if (!listaLivros.isEmpty) {
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
