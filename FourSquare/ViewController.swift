//
//  ViewController.swift
//  FourSquare
//
//  Created by Hakan Hardal on 20.11.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableVİew: UITableView!
    
    var nameArray = [String]()
    var IdArray = [UUID]()
    
    
    //--------
    var chosenName = ""
    var chosenId : UUID?
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButton))
        
        tableVİew.delegate = self
        tableVİew.dataSource = self
        getData()
    }
   @objc func getData(){
       
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "All")
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(fetchRequest)
           
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.IdArray.append(id)
                    }
                    self.tableVİew.reloadData()
                }
            }
        }catch{
            print("Data Error")
        }
    }
    
    @objc func addButton(){
        chosenName = ""
        performSegue(withIdentifier: "secondVC", sender: nil)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = content
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenName = nameArray[indexPath.row]
        chosenId = IdArray[indexPath.row]
        
        performSegue(withIdentifier: "resultVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "All")
            let idString = IdArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == IdArray[indexPath.row]{
                                nameArray.remove(at: indexPath.row)
                                IdArray.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                                context.delete(result)
                                self.tableVİew.reloadData()
                                do{
                                    try context.save()
                                }catch{
                                    print("SAVE ERROR")
                                }
                                break
                                
                            }
                        }
                    }
                }
            }catch{
                
            }
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultVC"{
            let destinationVC = segue.destination as? ResultViewController
            destinationVC?.selectedName = chosenName
            destinationVC?.selectedId = chosenId
            
            
            
        }
        if segue.identifier == "secondVC"{
            let destinationVC = segue.destination as? SecondViewController
            destinationVC?.secilenTitleTasima = chosenName
        }
    }
    

}

