

import UIKit
import IBMCloudAppID
import BMSCore
import SwiftCloudant

struct UserViolations:Decodable{
    let violations:[Days]
}

struct Days:Decodable{
    let day:[Violation]
}

struct Violation:Decodable{
    var date:String
    var status:String
    var image:Int
    var type:String
    var time:String
}



let cloudantURL = NSURL(string: "https://4f50a42f-2cbe-410c-97ef-d8cfd286514d-bluemix:f7888c3ea04a02acb50dbbfb39e89fcdd2d831f531961e2531314b86637be611@4f50a42f-2cbe-410c-97ef-d8cfd286514d-bluemix.cloudantnosqldb.appdomain.cloud")!

let client = CouchDBClient(url: cloudantURL as URL, username: "4f50a42f-2cbe-410c-97ef-d8cfd286514d-bluemix", password: "f7888c3ea04a02acb50dbbfb39e89fcdd2d831f531961e2531314b86637be611")

let dbName = "image_captures"


class LoggedInEmployeeView: UIViewController {
    var accessToken:AccessToken?
       var idToken:IdentityToken?
       var refreshToken: RefreshToken?
    var user_violations:UserViolations!
    var display_violations = [Violation]()
    var document_id:String!
    var images = [UIImage]()
    
    var firstLogin: Bool = false
    @IBOutlet weak var ViolationsTable: UITableView!
    @IBOutlet weak var DisplayName: UILabel!
    override func viewDidLoad(){
        self.navigationItem.hidesBackButton = true
        self.view.SetGradientBackground(start: CustomColors.lightblue, end: CustomColors.white)
        let displayName = idToken?.name ?? (idToken?.email?.components(separatedBy: "@"))?[0] ?? "Guest"
        let arr = displayName.components(separatedBy: " ")
        
        let given_name = arr[0].lowercased()
        let family_name = arr[1].lowercased()
        document_id = given_name + "_" + family_name
        
        self.DisplayName.text = displayName
        self.DisplayName.textColor = UIColor(displayP3Red: 21/256, green: 55/256, blue: 103/256, alpha: 1.00)
        
        
        self.load_violations()
        
        ViolationsTable.register(ViolationCell.nib(), forCellReuseIdentifier: "ViolationCell")
        ViolationsTable.delegate = self
        ViolationsTable.dataSource = self
        
        
        
        super.viewDidLoad()
    }
    
    func load_violations(){
        let read = GetDocumentOperation(id: document_id, databaseName: dbName) { (response, httpInfo, error) in
                    if let error = error {
                        print("Encountered an error while reading a document. Error: \(error)")
                    } else {
                        let jsonData = try? JSONSerialization.data(withJSONObject:response as Any)
                        self.parse(JSONData: jsonData!)
                    }
                }
        client.add(operation: read)
    }
    
    func parse(JSONData: Data){
        do{
            user_violations = try JSONDecoder().decode(UserViolations.self, from:JSONData)
            display_violations = user_violations.violations[0].day
            load_images()
        }catch{
            print("Decode Error")
        }
    }
    
    func load_images(){
        let serialQueue = DispatchQueue(label: "load_image")
        let mygroup = DispatchGroup()
        for (index, _) in display_violations.enumerated(){
            mygroup.enter()
            let read_image = GetDocumentOperation(id: String(display_violations[index].image), databaseName: "images"){ (response, httpInfo, error) in
                if let error = error {
                    print("Encountered an error while reading a document. Error: \(error)")
                } else {
                    print("Image Read success")
                    let DataDecoded = Data(base64Encoded: response?["image"] as! String)
                    
                    let im = UIImage(data:  DataDecoded!)
                    serialQueue.sync{
                        self.images.append(im!)
                    }
                    mygroup.leave()
                }
            }
            client.add(operation: read_image)
        }
        mygroup.notify(queue: .main){
            self.ViolationsTable.reloadData()
        }
    }
    
}

extension LoggedInEmployeeView:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         print("Cell Selected")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
}

extension LoggedInEmployeeView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViolationCell", for: indexPath) as! ViolationCell

        
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
        
        return cell
    }
    
}
