//
//  LoggenInSupervisorView.swift
//  iosapp
//
//  Created by Dev Manaktala on 26/07/20.
//  Copyright © 2020 IBM. All rights reserved.
//

import UIKit
import IBMCloudAppID
import BMSCore
import SwiftCloudant

struct Users:Decodable{
    let id:String
}

struct Document:Decodable{
    let rows:[Users]
}
class LoggedInSupervisorView: UIViewController {
    var accessToken:AccessToken?
          var idToken:IdentityToken?
          var refreshToken: RefreshToken?
    var user_violations:UserViolations!
    var display_violations = [Violation]()
    var users:Document!
    var document_id:String!
    var images = [UIImage]()
    var docs = [String]()
    
    @IBOutlet weak var DisplayName: UILabel!
    @IBOutlet weak var ViolationsTable: UITableView!
    override func viewDidLoad(){
        self.navigationItem.hidesBackButton = true
        self.view.SetGradientBackground(start: CustomColors.lightblue, end: CustomColors.white)
        
        let displayName = idToken?.name ?? (idToken?.email?.components(separatedBy: "@"))?[0] ?? "Arvind Krishna"
        self.DisplayName.text = displayName
        self.DisplayName.textColor = UIColor(displayP3Red: 21/256, green: 55/256, blue: 103/256, alpha: 1.00)
        
        load_users()
        print("Reached")
        ViolationsTable.register(ViolationCell.nib(), forCellReuseIdentifier: "ViolationCell")
        ViolationsTable.delegate = self
        ViolationsTable.dataSource = self
        
        super.viewDidLoad()
    }
    
    func load_users(){
        
        let get = GetAllDocsOperation(databaseName: "image_captures",
            rowHandler: { doc in
                       print("Got document: \(doc)")
                   }) { response, info, error in
                           if let error = error {
                               // handle error
                           } else {
                               // handle successful response
                            let jsonData = try? JSONSerialization.data(withJSONObject:response as Any)
                            print(jsonData)
                            do{
                                print("Decoding Users")
                                self.users = try JSONDecoder().decode(Document.self, from:jsonData!)
                                print("Loading Violations")
                                self.load_violations()
                            }catch{
                                print("error")
                            }
                       }
            }
        client.add(operation: get)
        }
    
    func load_violations(){
        let mygroup = DispatchGroup()
        let lock = DispatchQueue(label: "users")
        for (index,_) in users.rows.enumerated(){
            mygroup.enter()
                let read_final = GetDocumentOperation(id: users.rows[index].id, databaseName: dbName) { (response, httpInfo, error) in
                            if let error = error {
                                print("Encountered an error while reading a document. Error: \(error)")
                            } else {
                                print("Read doc success")
                                let jsonData = try? JSONSerialization.data(withJSONObject:response as Any)
                                lock.sync {
                                    self.parse(JSONData: jsonData!)
                                }
                                mygroup.leave()

                            }
                        }
                client.add(operation: read_final)
            }
        mygroup.notify(queue: .main){
            self.load_images()
            print(self.display_violations)
        }
    }
    
    func parse(JSONData: Data){
        do{
            user_violations = try JSONDecoder().decode(UserViolations.self, from:JSONData)
            print("sucess")
            display_violations.append(contentsOf: user_violations.violations[0].day)
        }catch{
            print("Decode Error")
        }
    }
    
    func load_images(){
        let serialQueue = DispatchQueue(label: "myqueue")
        let image_group = DispatchGroup()
        for (index, _) in display_violations.enumerated(){
            image_group.enter()
            print("last image")
            let read_image = GetDocumentOperation(id: String(display_violations[index].image), databaseName: "images"){ (response, httpInfo, error) in
                if let error = error {
                    print("Encountered an error while reading a document. Error: \(error)")
                } else {
                    print("Image Read success")
                    
                    let DataDecoded = Data(base64Encoded: response?["image"] as! String)
                    
                    let im = UIImage(data:  DataDecoded!)
                    serialQueue.sync {
                        image_group.leave()
                        self.images.append(im!)
                    }
                }
            }
            client.add(operation: read_image)
        }

            image_group.notify(queue: .main){
                self.ViolationsTable.reloadData()
        }

    }

}

extension LoggedInSupervisorView:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         print("Cell Selected")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
}

extension LoggedInSupervisorView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViolationCell", for: indexPath) as! ViolationCell
        if display_violations.count == 0{
            return cell
        }
        var contest:String

        switch(display_violations[indexPath.row].status){
            
        case "U":
            contest = "Uncontested"
        case "C":
            contest = "Contested"
        default:
            contest = "Uncontested"
            
        }
        
        let im = images[indexPath.row]
        
        cell.configure(with: display_violations[indexPath.row].type, Dated: display_violations[indexPath.row].date, Contest: contest, TimeOfViolation: display_violations[indexPath.row].time, Image: im)
        
        cell.ContestButton.isHidden = true
        
        return cell
    }
    
}
