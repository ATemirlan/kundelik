//
//  BaseViewController.swift
//  Kundelik
//
//  Created by Темирлан Алпысбаев on 1/23/18.
//  Copyright © 2018 Alpysbayev. All rights reserved.
//

import UIKit
import RealmSwift

class BaseViewController: UIViewController, WeekPageControllerDelegate, DayPageControllerDelegate, CalendarProtocol, NewEventProtocol {

    @IBOutlet weak var dayContainer: UIView!
    @IBOutlet weak var weekContainer: UIView!
    
    var dayPageViewController: DayPageViewController!
    var weekPageViewController: WeekPageViewController!
    
    var choosedDate: Date! = Date()
    
    lazy var blurView: UIView = {
        self.blurView = UIView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: UIApplication.shared.keyWindow!.frame.size))
        self.blurView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return self.blurView
    }()
    
    var events: Results<Event>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setEmptyBackButton()
   
        RealmController.shared.getEvents { (events) in
            self.events = events
            self.setupNavigationController()
            self.setupWeekViewController()
            self.setupDaysViewController()
        }
    }
    
    func setupNavigationController() {
        title = choosedDate.toString()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupWeekViewController(with date: Date = Date()) {
        weekPageViewController = Router.weekPageViewController(with: weekContainer.frame)
        weekPageViewController.weekDelegate = self
        weekPageViewController.date = date
        addChildViewController(weekPageViewController)
        weekContainer.addSubview(weekPageViewController.view)
    }
    
    func setupDaysViewController(with date: Date = Date()) {
        dayPageViewController = Router.dayPageViewController(with: dayContainer.frame)
        dayPageViewController.dayDelegate = self
        dayPageViewController.date = date
        dayPageViewController.events = events
        addChildViewController(dayPageViewController)
        dayContainer.addSubview(dayPageViewController.view)
    }
    
    @IBAction func showCalendar(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: CalendarViewController.segueID, sender: choosedDate)
    }
    
    @IBAction func loginToKundelik(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: KundelikViewController.segueID, sender: nil)
    }
    
    @IBAction func addNewEvent(_ sender: UIButton) {
        performSegue(withIdentifier: "NewEventNavigationController", sender: choosedDate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CalendarViewController.segueID {
            view.addSubview(blurView)
            let calendarVC = segue.destination as! CalendarViewController
            calendarVC.delegate = self
            calendarVC.currentDate = sender as! Date
        } else if segue.identifier == "NewEventNavigationController" {
            let navvc = segue.destination as! UINavigationController
            
            for vc in navvc.viewControllers {
                if vc.className == NewEventTableViewController.className {
                    (vc as! NewEventTableViewController).delegate = self
                    (vc as! NewEventTableViewController).currentDate = sender as? Date
                }
            }
        }
    }
    
    // MARK: - New event Delegate
    
    func newEventAdded() {
        RealmController.shared.getEvents { (events) in
            self.events = events
            
            self.dayPageViewController.removeFromParentViewController()
            self.setupDaysViewController(with: self.choosedDate)
        }
    }
    
    // MARK: - Calendar Delegate
    
    func newDateChoosed(newDate: Date?) {
        blurView.removeFromSuperview()
        
        guard let date = newDate else {
            return
        }
        
        title = date.toString()
        choosedDate = date
        
        RealmController.shared.getEvents { (events) in
            self.events = events
            
            self.weekPageViewController.removeFromParentViewController()
            self.setupWeekViewController(with: date)
            
            self.dayPageViewController.removeFromParentViewController()
            self.setupDaysViewController(with: date)
        }
    }
    
    // MARK: - Day Delegate
    
    func pageChanged(date: Date) {
        choosedDate = date
        weekPageViewController.select(newDate: date)
    }
    
    // MARK: - Week Delegates
    
    func newDateSelected(date: Date) {
        changeDay(date: date)
    }
    
    func changeDay(date: Date) {
        guard date.toString() != choosedDate.toString() else {
            return
        }
        
        let newDay = Router.dayViewController(with: date, events: events)
        newDay.delegate = dayPageViewController
        
        dayPageViewController.setViewControllers([newDay], direction: date.compare(choosedDate).rawValue == 1 ? .forward : .reverse, animated: true, completion: { (completed) in
            newDay.delegate?.set(current: newDay)
        })
    }
    
}
