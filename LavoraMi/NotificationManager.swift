//
//  NotificationManager
//  LavoraMi
//
//  Created by Andrea Filice on 06/01/26.
//

import UserNotifications
import UIKit
import SwiftUI

class NotificationManager {
    @AppStorage("workScheduledNotifications") var workScheduledNotifications: Bool = true
    @AppStorage("workInProgressNotifications") var workInProgressNotifications: Bool = true
    @AppStorage("strikeNotifications") var strikeNotifications: Bool = true
    @AppStorage("enableNotifications") var enableNotifications: Bool = true
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Permesso notifiche concesso")
            } else if let error = error {
                print("Errore permessi: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleWorkAlerts(for work: WorkItem) {
        //WORK ENDED
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour], from: work.endDate)
        let notificationHour = dateComponents.hour ?? 0
        dateComponents.hour = (notificationHour >= 0 && notificationHour <= 10) ? 10 : dateComponents.hour
        dateComponents.minute = 0
        
        let contentDayOf = UNMutableNotificationContent()
        contentDayOf.title = "Lavori terminati!"
        contentDayOf.body = "I lavori in \(work.roads) delle linee \(work.lines.joined(separator: ", ")) dovrebbero terminare oggi. Consulta il sito di \(work.company) per aggiornamenti all'ultimo minuto."
        contentDayOf.sound = .default
        
        if let dateOf = calendar.date(from: dateComponents), dateOf > Date() {
            let triggerDayOf = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let requestDayOf = UNNotificationRequest(identifier: "\(work.id.uuidString)_END", content: contentDayOf, trigger: triggerDayOf)
            center.add(requestDayOf)
            print("Notifica programmata per la fine: \(dateOf.formatted())")
        }
        
        if let dayBeforeDate = calendar.date(byAdding: .day, value: -1, to: work.endDate) {
            
            var dayBeforeComponents = calendar.dateComponents([.year, .month, .day, .hour], from: dayBeforeDate)
            let notificationHour = dayBeforeComponents.hour ?? 0
            dayBeforeComponents.hour = (notificationHour >= 0 && notificationHour <= 10) ? 10 : dayBeforeComponents.hour
            dayBeforeComponents.minute = 0
            
            let debugDate = calendar.date(from: dayBeforeComponents)
            
            if dayBeforeDate > Date() {
                let contentDayBefore = UNMutableNotificationContent()
                contentDayBefore.title = "⚠️ I lavori finiscono domani!"
                contentDayBefore.body = "Domani terminano i lavori in \(work.roads) per \(work.lines.joined(separator: ", ")). Consulta il sito di \(work.company) per maggiori info."
                contentDayBefore.sound = .default
                
                let triggerDayBefore = UNCalendarNotificationTrigger(dateMatching: dayBeforeComponents, repeats: false)
                let requestDayBefore = UNNotificationRequest(identifier: "\(work.id.uuidString)_PRE", content: contentDayBefore, trigger: triggerDayBefore)
                center.add(requestDayBefore)
                print("Notifica programmata per il preavviso: \(String(describing: debugDate?.formatted()))")
            }
        }
        
        //WORK STARTED
        if(workScheduledNotifications){scheduleWorksBefore(for: work)}
    }
    
    func scheduleWorksBefore(for work: WorkItem){
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour], from: work.startDate)
        let notificationHour = dateComponents.hour ?? 0
        dateComponents.hour = (notificationHour >= 0 && notificationHour <= 10) ? 10 : dateComponents.hour
        dateComponents.minute = 0
        
        let contentDayOf = UNMutableNotificationContent()
        contentDayOf.title = "Lavori Iniziati!"
        contentDayOf.body = "I lavori in \(work.roads) delle linee \(work.lines.joined(separator: ", ")) sono iniziati oggi. Consulta il sito di \(work.company) per maggiori info."
        contentDayOf.sound = .default
        
        if let dateOf = calendar.date(from: dateComponents), dateOf > Date() {
            let triggerDayOf = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let requestDayOf = UNNotificationRequest(identifier: "\(work.id.uuidString)_START", content: contentDayOf, trigger: triggerDayOf)
            center.add(requestDayOf)
            print("Notifica PREAVVISO NUOVO LAVORO: \(dateOf.formatted())")
        }
        
        if let dayBeforeDate = calendar.date(byAdding: .day, value: -1, to: work.startDate) {
            
            var dayBeforeComponents = calendar.dateComponents([.year, .month, .day, .hour], from: dayBeforeDate)
            let notificationHour = dayBeforeComponents.hour ?? 0
            dayBeforeComponents.hour = (notificationHour >= 0 && notificationHour <= 10) ? 10 : dayBeforeComponents.hour
            dayBeforeComponents.minute = 0
            
            let debugDate = calendar.date(from: dayBeforeComponents)
            
            if dayBeforeDate > Date() {
                let contentDayBefore = UNMutableNotificationContent()
                contentDayBefore.title = "⚠️ I lavori iniziano domani!"
                contentDayBefore.body = "Domani iniziano i lavori in \(work.roads) per \(work.lines.joined(separator: ", ")). Consulta il sito di \(work.company) per maggiori info."
                contentDayBefore.sound = .default
                
                let triggerDayBefore = UNCalendarNotificationTrigger(dateMatching: dayBeforeComponents, repeats: false)
                let requestDayBefore = UNNotificationRequest(identifier: "\(work.id.uuidString)_PRESTART", content: contentDayBefore, trigger: triggerDayBefore)
                center.add(requestDayBefore)
                print("Notifica programmata per il preavviso: \(String(describing: debugDate?.formatted()))")
            }
        }
    }
    
    func removeWorkAlerts(for work: WorkItem) {
        let center = UNUserNotificationCenter.current()
        let identifiers = ["\(work.id.uuidString)_END", "\(work.id.uuidString)_PRE", "\(work.id.uuidString)_START", "\(work.id.uuidString)_PRESTART"]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Notifiche rimosse per: \(work.title)")
    }
    
    func syncNotifications(for works: [WorkItem], favorites: [String]) {
        _ = UNUserNotificationCenter.current()
        for work in works {
            
            if work.matchesFavorites(favorites) {
                if(workInProgressNotifications){
                    scheduleWorkAlerts(for: work)
                    print("Attivata notifica per fine lavori: \(work.title) (Match preferiti)")
                }
                if (workScheduledNotifications){
                    scheduleWorksBefore(for: work)
                    print("Attivata notifica per inizio lavori: \(work.title)")
                }
                else{removeWorkAlerts(for: work)}
            }
        }
    }
}
