//
//  ViewController.swift
//  CallbacksAndMultithreading
//
//  Created by Chaudhary Himanshu Raj on 19/01/18.
//  Copyright © 2018 Chaudhary Himanshu Raj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // var userNames = ["Name1", "Name2", "Name3", "Name4", "Name5", "Name6", "Name7", "Name8", "Name9", "Name10"]
       var userNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /* Case-1 : Calling function with no completion handler
         getUserInfo()
        */
        
        /* Case-2 : Putting completion Handler and then calling it. This gives us some leverage to code extra line of code.
        The lines coded here will be executed in between execution of line number 56 and 58
        getUserInfo {
            print("Code done in this block will execute between exection of line number 56 and 58")
        } */
        
        // Case-3 : Completion block with 3 arguments, Name the parametes here with anyname.
        getUserInfo { (success, response, error) in
            if success {
                guard let names = response as? [String] else { return }
                print("GET USER INFO BLOCK CALLED")
                // print(names)
                    self.userNames = names
                    self.tableView.reloadData()
                print("TABLE RELOADED CALLED")
            } else if let error = error {
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserInfo(completion: @escaping (Bool, Any?, Error?) -> Void) {
        print("INSIDE GET USER INFO FUNCTION")
        // This will be the local variable containing details about user but it's scope is restricted to this function only.
        // Hence, this problem will be solved by using the call back/ Completion Handler.
        var userName = [String]()
        
        // Running a process at global with delay of 3 seconds. This takes the lines of code surrounded in this block out of main thread and run after delay of 3 seconds. NOTE : Look for something like this in console ("This application is modifying the autolayout engine from a background thread after the engine was accessed from the main thread. This can lead to engine corruption and weird crashes.")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            print("DISPATCH FINISHED")
        guard let path = Bundle.main.path(forResource: "UserDetails", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
             // print("Data Recieved is : \(data)")
            
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
             // print("Json retrieved is : \(json)")
            
            // Casting the array as Array of Dictionaries, hence [[String : Any]]
            guard let array = json as? [[String : Any]] else { return }
            for user in array {
                guard let name = user["name"] as? String else {
                    continue
                }
                userName.append(name)
            }
            /* For Case-2
                completion()
            */
            
            // For Case-3, with parameters in completion block
            // To get back onto main thread we need this block of code. This will execute completion on main thread.
            DispatchQueue.main.async {
                completion(true, userName, nil)
            }
            // print(userName)
        } catch {
            print(error)
            DispatchQueue.main.async {
                completion(false, nil, error)
                }
            }
        } // Closing dispatch here
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = userNames[indexPath.row]
        return cell
    }
}

