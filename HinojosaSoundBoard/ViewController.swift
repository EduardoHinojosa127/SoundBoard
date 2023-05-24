//
//  ViewController.swift
//  HinojosaSoundBoard
//
//  Created by Mac 04 on 24/05/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        grabaciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let grabacion = grabaciones[indexPath.row]
        cell.textLabel?.text = grabacion.nombre
        return cell
    }
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    
    @IBOutlet weak var tablaGrabacion: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaGrabacion.dataSource = self
        tablaGrabacion.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
           grabaciones = try
               context.fetch(Grabacion.fetchRequest())
           tablaGrabacion.reloadData()
        }catch{}
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        do{
           reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
           reproducirAudio?.play()
        }catch{}
        tablaGrabacion.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
           let grabacion = grabaciones[indexPath.row]
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           context.delete(grabacion)
           (UIApplication.shared.delegate as! AppDelegate).saveContext()
           do{
               grabaciones = try
                   context.fetch(Grabacion.fetchRequest())
               tablaGrabacion.reloadData()
           }catch{}
        }

    }
}

