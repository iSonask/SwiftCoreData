//
//  DataController.swift
//  SwiftCoreData
//
//  Created by Akash on 26/07/17.
//  Copyright © 2017 Akash. All rights reserved.
//

/*
 let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
 fetchRequest.predicate = NSPredicate(format: "%K = %@", "name", "mahesh") // = for matching the string if mahesh exist in whole database which hase name key  %K is for Key in coredata  ,,,,,,,,,,,,,, CONTAINS ,,,,,,,,, is for searching data [c] use for case sensitive true false
 fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "ID", ascending: true)] // sorting data with key here ID is key for ascending value
 fetchRequest.fetchLimit = 30    // how many data you want in one request
 fetchRequest.fetchOffset = 0    // for pagination in requested data
 */


import UIKit
import CoreData

class DataController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate{
    
    var searchController : UISearchController!
    let appDel = UIApplication.shared.delegate as! AppDelegate
    var datas: [Data] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var count = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        tableView.isEditing = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        //        fetchPaginatedData(offset: 0)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text ?? "")
        if let searchStr = searchController.searchBar.text{
            getSearchedData(strSearch: searchStr)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        
        if let searchStr = searchBar.text{
            getSearchedData(strSearch: searchStr)
        }
        self.navigationItem.titleView = nil
    }
    
    //MARK:- function
    
    func addData(strData: String) {
        
        let data = Data(context: context)
        data.name = strData
        data.date = NSDate()
        appDel.saveContext()
        print("Saved")
        getData()
        
    }
    
    func getData() {
        do {
            datas = try context.fetch(Data.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
        tableView.reloadData()
    }
    
    func getSearchedData(strSearch: String) {
        do{
            let searchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
            searchRequest.predicate = NSPredicate(format: "%K CONTAINS[c] %@", "name", strSearch)
            datas = try context.fetch(searchRequest) as! [Data]
            print(datas.count)
        } catch{
            print("Fetching Failed")
        }
    }
    
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
    
    func fetchPaginatedData(offset : Int) {
        do{
            
            fetch.fetchLimit = count
            fetch.fetchOffset = offset
            datas = try context.fetch(fetch) as! [Data]
            
            print(datas.count)
        } catch{
            print("Fetching failed")
        }
        tableView.reloadData()
    }
    
    func fetchSortData() {
        do{
            fetch.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            datas = try context.fetch(fetch) as! [Data]
        }catch{
            print("fetching error")
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! DataCell
        let data = datas[indexPath.row]
        
        // Configure the cell...
        cell.data = data
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let data = datas[indexPath.row]
            context.delete(data)
            appDel.saveContext()
            getData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    //manage pagination
    //    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        if (indexPath.row + 1) == datas.count{
    //            let i = count + 1
    //            fetchPaginatedData(offset: i)
    //        }
    //    }
    //manage pagination
    //    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        if tableView.contentOffset.y >= tableView.contentSize.height - tableView.bounds.size.height{
    //            fetchPaginatedData(offset: 1)
    //            print("yes")
    //        } else {
    //            print("no")
    //        }
    //    }
    
    //FIXME:- Action
    
    @IBAction func btnAddTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Some Title", message: "Enter a text", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "enter string"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields![0]{ // Force unwrapping because we know it exists.
                print("Text field: " + textField.text!)
                if let strdata = textField.text{
                    self.addData(strData: strdata)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: {_ in
            print("cancel")
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnSearchTapped(_ sender: Any) {
        
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
        
    }
    
    @IBAction func btnFilterTapped(_ sender: UIButton) {
        fetchSortData()
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
// MARK: - Properties
public extension UITableView {
    
    /// SwifterSwift: Index path of last row in tableView.
    public var indexPathForLastRow: IndexPath? {
        return indexPathForLastRow(inSection: lastSection)
    }
    
    /// SwifterSwift: Index of last section in tableView.
    public var lastSection: Int {
        return numberOfSections > 0 ? numberOfSections - 1 : 0
    }
    
    /// SwifterSwift: Number of all rows in all sections of tableView.
    public var numberOfRows: Int {
        var section = 0
        var rowCount = 0
        while section < numberOfSections {
            rowCount += numberOfRows(inSection: section)
            section += 1
        }
        return rowCount
    }
    
}
// MARK: - Methods
public extension UITableView {
    
    /// SwifterSwift: IndexPath for last row in section.
    ///
    /// - Parameter section: section to get last row in.
    /// - Returns: optional last indexPath for last row in section (if applicable).
    public func indexPathForLastRow(inSection section: Int) -> IndexPath? {
        guard section >= 0 else {
            return nil
        }
        guard numberOfRows(inSection: section) > 0  else {
            return IndexPath(row: 0, section: section)
        }
        return IndexPath(row: numberOfRows(inSection: section) - 1, section: section)
    }
    
    /// Reload data with a completion handler.
    ///
    /// - Parameter completion: completion handler to run after reloadData finishes.
    func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
    /// SwifterSwift: Remove TableFooterView.
    public func removeTableFooterView() {
        tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    /// SwifterSwift: Remove TableHeaderView.
    public func removeTableHeaderView() {
        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    
    /// SwifterSwift: Scroll to bottom of TableView.
    ///
    /// - Parameter animated: set true to animate scroll (default is true).
    public func scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: animated)
    }
    
    /// SwifterSwift: Scroll to top of TableView.
    ///
    /// - Parameter animated: set true to animate scroll (default is true).
    public func scrollToTop(animated: Bool = true) {
        setContentOffset(CGPoint.zero, animated: animated)
    }
    
}


