//
//  ViewController.swift
//  Sample
//
//  Created by Aishwarya J patel on 11/5/23.
//

import UIKit
import UserNotifications
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UNUserNotificationCenterDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView :UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [RemainderList]()
    
    // MARK: - View life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        getAllItems()
        title = "RemainderList"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.reloadData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didDone))
    }
    
    @objc private func didDone(){
        scheduleNotification()
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        alert.view.addSubview(datePicker)
        
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            
            self.createItem(name: text, date: datePicker.date)
        }))
        present(alert, animated: true)
    }
    
    // MARK: - ScheduleNotification
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Don't forget to check your remainder list."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "reminderNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
    
    // MARK: -Necessary Code for Notification Sound and notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    //MARK: - UITableViewDelegateLifeCycle
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let formattedDate = dateFormatter.string(from: model.createdAt!)
        cell.textLabel?.text = "\(model.name ?? "") - \(formattedDate)"
        return cell
    }
    
    //MARK: - UITableviewDelegateMethods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit Item", message: "Edit yourItem", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                // Call your updateItem function here
                self.updateItem(item: item, newName: newName, newDate: Date())
            }))
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        present(sheet, animated: true)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleNotification()
    }
    
    
    //MARK: -CoreData Functionality
    func getAllItems(){
        do{
            models = try context.fetch(RemainderList.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch{
            
        }
    }
    
    func createItem(name: String, date: Date) {
        let newItem = RemainderList(context: context)
        newItem.name = name
        newItem.createdAt = date
        scheduleNotification()
            do {
            try context.save()
            getAllItems()
        } catch {
            
        }
    }
    
    
    func deleteItem(item:RemainderList){
        context.delete(item)
        do{
            try context.save()
            getAllItems()
        }
        catch{
            
        }
    }
    
    func updateItem(item: RemainderList, newName: String, newDate: Date) {
        item.name = newName
        item.createdAt = newDate
        do {
            try context.save()
            getAllItems()
        } catch {
            print("Error updating item: \(error)")
        }
    }
}
 




