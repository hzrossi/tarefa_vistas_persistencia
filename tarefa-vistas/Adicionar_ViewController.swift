//
//  Adicionar_ViewController.swift
//  tarefa-vistas
//
//  Created by Henrique Zuchetto Rossi on 17/06/16.
//  Copyright © 2016 Henrique Zuchetto Rossi. All rights reserved.
//

import UIKit
import CoreData

protocol Adicionar_ViewDelegate {
	func setLivros(livros:[Livro])
}

class Adicionar_ViewController: UIViewController {

	@IBOutlet weak var txtISBN: UITextField!
	@IBOutlet weak var imgCapa: UIImageView!
	@IBOutlet weak var txtDados: UITextView!

	var tituloLivro:String!
	var capaLivro:UIImage!
	var autoresLivro:String!
	var livro:Livro!
	var livros:[Livro] = []
	var contexto:NSManagedObjectContext? = nil
	
	var delegate:Adicionar_ViewDelegate! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Adicionar Livro"
		self.txtISBN.resignFirstResponder()
		self.imgCapa.hidden = true
		self.txtDados.hidden = true
		self.txtDados.text = ""
		self.imgCapa.image = UIImage()

		self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	//pesquisa o isbn inserido e mostra os detalhes
	@IBAction func pesquisar() {
		//se o campo de busca estiver vazio
		if (txtISBN.text == "") {
			//cria o alerta
			let alerta = UIAlertController(title: "Aviso!", message: "Preencha o ISBN", preferredStyle: UIAlertControllerStyle.Alert)
			alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))

			//mostra o alerta
			self.presentViewController(alerta, animated: true, completion: nil)
		}
		else {
			let secaoEntidade = NSEntityDescription.entityForName("Secao", inManagedObjectContext: self.contexto!)
			let peticao = secaoEntidade?.managedObjectModel.fetchRequestFromTemplateWithName("petSecao", substitutionVariables: ["isbn" : txtISBN.text!])
			do {
				let secaoEntidade2 = try self.contexto?.executeFetchRequest(peticao!)

				//se encontrou valor aramzenado, não faz busca e mostra os dados ou aviso
				if (secaoEntidade2?.count > 0) {
					//cria o alerta
					let alerta = UIAlertController(title: "Aviso!", message: "O livro já foi adicionado!", preferredStyle: UIAlertControllerStyle.Alert)
					alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))

					//mostra o alerta
					self.presentViewController(alerta, animated: true, completion: nil)
					self.txtDados.hidden = true
					self.imgCapa.hidden = true
				}
				//senão realiza a busca
				else {
					buscaSincrona(txtISBN.text!)
				}
			}
			catch _ {

			}
		}
	}

	func buscaSincrona(isbn:String) {
		let isbnBusca = "ISBN:" + isbn
		let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=" + isbnBusca
		let url = NSURL(string: urls)
		let dados:NSData? = NSData(contentsOfURL: url!)
		let novaSecaoEntidade = NSEntityDescription.insertNewObjectForEntityForName("Secao", inManagedObjectContext: self.contexto!)
		let novoLivroEntidade = NSEntityDescription.insertNewObjectForEntityForName("Livro", inManagedObjectContext: self.contexto!)

		// se resultado nulo, está sem internet
		if (dados == nil) {
			//cria o alerta
			let alerta = UIAlertController(title: "Aviso!", message: "Sem conexão de Internet", preferredStyle: UIAlertControllerStyle.Alert)
			alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))

			//mostra o alerta
			self.presentViewController(alerta, animated: true, completion: nil)

			self.txtDados.text = ""
			self.imgCapa.hidden = true
		}
		else {
			do {
				let json = try NSJSONSerialization.JSONObjectWithData(dados!, options: NSJSONReadingOptions.MutableLeaves)

				let resultado = json as! NSDictionary //armazena os dados do livro

				//se livro não contém elementos (está vazio), não encontrou o livro
				if (resultado.count == 0) {
					//cria o alerta
					let alerta = UIAlertController(title: "Aviso!", message: "ISBN não encontrado", preferredStyle: UIAlertControllerStyle.Alert)
					alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))

					//mostra o alerta
					self.presentViewController(alerta, animated: true, completion: nil)
					self.txtDados.text = ""
					self.imgCapa.hidden = true
				}

				//senão encontrou um livro
				else {
					self.tituloLivro = ""
					self.autoresLivro = ""
					self.capaLivro = UIImage()
					//print("encontrei")

					//título
					let livro = resultado["\(isbnBusca)"] as! NSDictionary
					let titulo = livro["title"] as! NSString as String
					//print(titulo)
					self.txtDados.text = "Título: " + titulo + "\n"
					self.tituloLivro = titulo

					//autor
					let autores = livro["authors"] as! NSArray
					self.txtDados.text = self.txtDados.text + "Autor(es): "
					for i in 0 ..< autores.count {
						let nome = autores[i]["name"] as! NSString as String
						//print(nome)
						if (i == (autores.count - 1)) {
							self.autoresLivro = self.autoresLivro + nome
						}
						else {
							self.autoresLivro = self.autoresLivro + nome + ", "
						}
					}
					self.txtDados.text = self.txtDados.text + self.autoresLivro
					self.txtDados.hidden = false

					//capa
					if livro["cover"]?.count > 0 {
						let capas = livro["cover"] as! NSDictionary
						let capaMedia = capas["medium"] as! NSString as String
						//print(capaMedia)

						//mostrando a capa
						let urlCapa = NSURL(string: capaMedia)
						let imagemCapa = NSData(contentsOfURL:urlCapa!)
						if (imagemCapa != nil) {
							self.imgCapa.hidden = false
							let imagem:UIImage = UIImage(data: imagemCapa!)!
							self.imgCapa.image = imagem
							self.capaLivro = imagem
						}
						else {
							//cria o alerta
							let alerta = UIAlertController(title: "Aviso!", message: "Não foi possível carregar a capa do livro", preferredStyle: UIAlertControllerStyle.Alert)
							alerta.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))

							//mostra o alerta
							self.presentViewController(alerta, animated: true, completion: nil)
							self.imgCapa.hidden = false
							let imagem:UIImage = UIImage(named: "SemCapa")!

							self.imgCapa.image = imagem
							self.capaLivro = imagem
						}
					}
					else {
						//print("sem capa")
						self.imgCapa.hidden = false
						let imagem:UIImage = UIImage(named: "SemCapa")!
						self.imgCapa.image = imagem
						self.capaLivro = imagem
					}
					novaSecaoEntidade.setValue(txtISBN.text!, forKey: "isbn")
					novoLivroEntidade.setValue(self.tituloLivro, forKey: "titulo")
					novoLivroEntidade.setValue(self.autoresLivro, forKey: "autores")
					novoLivroEntidade.setValue(UIImagePNGRepresentation(self.capaLivro), forKey: "capa")
					novaSecaoEntidade.setValue(novoLivroEntidade, forKey: "tem")
					do {
						try self.contexto?.save()
					}
					catch _ {

					}
					livros.append(Livro(Titulo: self.tituloLivro, Autores: self.autoresLivro, Capa: self.capaLivro)) //adiciona o livro atual à lista
					//print(livros)
				}
			}
			catch _ {
				print("não foi possível converter o resultado")
			}
		}
	}

	/*func criarLivroEntidade(livro:Livro) -> Set<Object> {
		var entidade = Set<NSObject>()
		let livroEntidade = NSEntityDescription.insertNewObjectForEntityForName("Livro", inManagedObjectContext: self.contexto!)

		livroEntidade.setValue(tituloLivro, forKey: "titulo")
		livroEntidade.setValue(autoresLivro, forKey: "autores")
		livroEntidade.setValue(UIImagePNGRepresentation(capaLivro), forKey: "capa")

		entidade.insert(livroEntidade)

		return entidade
	}*/

	override func viewWillDisappear(animated: Bool) {
		delegate.setLivros(livros)
	}
}
