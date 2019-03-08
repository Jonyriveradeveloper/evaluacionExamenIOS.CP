//
//  visitasVC.swift
//  examenEvaluacionIOS
//
//  Created by Misael Rivera on 3/6/19.
//  Copyright © 2019 Misael Rivera. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import  GoogleSignIn

class visitasVC: UIViewController  {


    @IBOutlet weak var tablaUbicaciones:UITableView!
    
    
    var listaUbicaciones = [Ubicaciones]()
    
    var userID:Any?
    var bandera:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = Auth.auth().currentUser?.uid
        
        tablaUbicaciones.delegate = self
        tablaUbicaciones.dataSource = self
        
        traerUbicaciones()
    }
    override func viewDidAppear(_ animated: Bool) {
        bandera = false
    }
    func traerUbicaciones()
    {
        Servicios.instancia.REF_UBICACIONES.observe(DataEventType.value) { (snapshot) in
            self.listaUbicaciones.removeAll()
            for item in snapshot.children.allObjects as! [DataSnapshot]
            {
                if let valores = item.value as? [String:AnyObject]
                {
                    let nombre = valores["nombre"] as! String
                    let direccion = valores["direccion"] as! String
                    let descripcion = valores["descripcion"] as! String
                    let latitud = valores["latitud"] as! Double
                    let longitud = valores["longitud"] as! Double
                    let idUsuario = valores["idUsuario"] as! String
                    let id = valores["id"] as! String
                    
                    
                    // let valoracion = valores["valoracion"] as! String
                    if self.userID != nil {
                        if idUsuario == self.userID as! String {
                            let ubicaciones = Ubicaciones(nombre: nombre, direccion: direccion, descripcion: descripcion, latitud: latitud, longitud: longitud, id: id)
                            self.listaUbicaciones.append(ubicaciones)
                        }
                    }
                   
            }
        }
            self.tablaUbicaciones.reloadData()
            
            if(self.listaUbicaciones.isEmpty){
                self.bandera = true
                if self.userID != nil {
                    self.performSegue(withIdentifier: "addvisita", sender: self)
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let agregarVisitasVC = segue.destination as? AgregarUbicacionVC {
            agregarVisitasVC.initUsuario(id: userID as! String, bandera: bandera)
        }
    }
    @IBAction func agregarUbicacionBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "addvisita", sender: self)
    }
    
    
}

extension visitasVC :  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaUbicaciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tablaUbicaciones.dequeueReusableCell(withIdentifier: "cellUbicaciones") as? MisUbicacionesCell
        let ubicacion = listaUbicaciones[indexPath.row]
        cell?.actualizarVista(datosUbicaciones: ubicacion)
        return cell!
}
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       
        let ubcacion = self.listaUbicaciones[indexPath.row]
        
        Servicios.instancia.REF_UBICACIONES.child(ubcacion.id).removeValue { (error, ref) in
            if error != nil {
                print("fallo la eliminacion",error)
                return
            }
            self.listaUbicaciones.remove(at: indexPath.row)
            
        }
    }
}


