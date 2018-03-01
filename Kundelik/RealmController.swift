//
//  RealmController.swift
//  Kundelik
//
//  Created by Темирлан Алпысбаев on 3/1/18.
//  Copyright © 2018 Alpysbayev. All rights reserved.
//

import RealmSwift

class RealmController {
    
    static let shared = RealmController()
    private var realm: Realm?
    
    private init() {
        do {
            self.realm = try Realm()
        } catch {
            guard let vc = UIApplication.shared.keyWindow?.viewController() else {
                return
            }
            
            Alert.showError(textError: "Ошибка базы данных", above: vc)
        }
    }
    
    func add(eventTitle: String) {
        let event = Event()
        event.title = eventTitle
        
        do{
            try realm?.write {
                realm?.add(event)
            }
        } catch (let error) {
            print(error)
        }
    }
    
    func getEvents() -> Results<Event>? {
        guard let events = realm?.objects(Event.self) else {
            return nil
        }
        
        return events
    }
    
    func removeEvents() {
        
    }
    
}
