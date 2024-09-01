//
//  Analytics.swift
//  Circlr
//
//  Created by Vasisht Muduganti on 8/30/24.
//

import UIKit
import Charts
import DGCharts
import SwiftUI

class Analytics: UIViewController {
    
    let defaults = UserDefaults.standard
    var dailyLaps = 0
    var weeklyLaps = 0
    var totalLaps = 0
    override func viewWillAppear(_ animated: Bool) {
        dailyLaps = defaults.integer(forKey: "dailyLaps")
        weeklyLaps = defaults.integer(forKey: "weeklyLaps")
        totalLaps = defaults.integer(forKey: "totalLaps")
    }
    var dailyLapsHeading:UILabel?
    var dailyLapsSubheading:UILabel?
    
    var weeklyLapsHeading:UILabel?
    var weeklyLapsSubheading:UILabel?
    
    var totalLapsHeading:UILabel?
    var totalLapsSubheading:UILabel?
    func updateValues(){
        dailyLaps = defaults.integer(forKey: "dailyLaps")
        weeklyLaps = defaults.integer(forKey: "weeklyLaps")
        totalLaps = defaults.integer(forKey: "totalLaps")
        
        dailyLapsSubheading?.text = "\(dailyLaps)"
        weeklyLapsSubheading?.text = "\(weeklyLaps)"
        totalLapsSubheading?.text = "\(totalLaps)"
        
        var list = [LapModel]()
        var daysInorder = [String]()
        var startDay = defaults.integer(forKey: "startDay")
        lapArray = defaults.array(forKey: "lapArray") as? [Int]
        print("quasmo \(lapArray)")
        for i in startDay...7{
            daysInorder.append(String(dayEnumerated[i]!.prefix(3)))
        }
        for i in 1..<startDay{
            daysInorder.append(String(dayEnumerated[i]!.prefix(3)))
        }
        
        for i in 0..<daysInorder.count{
            list.append(LapModel(day: daysInorder[i], lapCount: lapArray![i]))
        }
        displayedList = list
        controller?.rootView.list = displayedList!
    }
    var lapArray:[Int]?
    var dayEnumerated = [1:"Monday",2:"Tuesday", 3:"Wednesday", 4:"Thursday", 5:"Friday", 6:"Saturday",7:"Sunday"]
    var controller:UIHostingController<LapChart>?
    var displayedList:[LapModel]?
    override func viewDidLoad() {
        /*var list = [
            LapModel(day: "Mon", lapCount: 4),
            LapModel(day: "Tue", lapCount: 4),
            LapModel(day: "Wed", lapCount: 8),
            LapModel(day: "Thu", lapCount: 2),
            LapModel(day: "Fri", lapCount: 4),
            LapModel(day: "Sat", lapCount: 6),
            LapModel(day: "Sun", lapCount: 3)
        ]*/
        var list = [LapModel]()
        var daysInorder = [String]()
        var startDay = defaults.integer(forKey: "startDay")
        lapArray = defaults.array(forKey: "lapArray") as? [Int]
        print("quasmo \(lapArray)")
        for i in startDay...7{
            daysInorder.append(String(dayEnumerated[i]!.prefix(3)))
        }
        for i in 1..<startDay{
            daysInorder.append(String(dayEnumerated[i]!.prefix(3)))
        }
        
        for i in 0..<daysInorder.count{
            list.append(LapModel(day: daysInorder[i], lapCount: lapArray![i]))
        }
        displayedList = list
        controller = UIHostingController(rootView: LapChart(list: displayedList!))
        guard let chartView = controller?.view else{
            return
        }
        
        view.addSubview(chartView)
        
        chartView.frame = CGRect(x: 20, y: 70, width: view.frame.width - 20, height: view.frame.height/2.5)
        dailyLaps = defaults.integer(forKey: "dailyLaps")
        weeklyLaps = defaults.integer(forKey: "weeklyLaps")
        totalLaps = defaults.integer(forKey: "totalLaps")
        var remainingSpace = (view.frame.height - chartView.frame.origin.y + chartView.frame.height)
        var availableHeight = remainingSpace
        
        
        dailyLapsHeading = UILabel()
        dailyLapsHeading?.text = "Todays Laps"
                dailyLapsHeading?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        dailyLapsHeading?.translatesAutoresizingMaskIntoConstraints = false

                // Create the Daily Laps subheading label
                dailyLapsSubheading = UILabel()
                dailyLapsSubheading?.text = "\(dailyLaps)" // Example count
                dailyLapsSubheading?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                dailyLapsSubheading?.translatesAutoresizingMaskIntoConstraints = false

                // Create the Weekly Laps heading label
                weeklyLapsHeading = UILabel()
                weeklyLapsHeading?.text = "Weekly Laps"
                weeklyLapsHeading?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
                weeklyLapsHeading?.translatesAutoresizingMaskIntoConstraints = false

                // Create the Weekly Laps subheading label
                weeklyLapsSubheading = UILabel()
                weeklyLapsSubheading?.text = "\(weeklyLaps)"
                weeklyLapsSubheading?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                weeklyLapsSubheading?.translatesAutoresizingMaskIntoConstraints = false

                // Create the Total Laps heading label
                totalLapsHeading = UILabel()
        totalLapsHeading?.text = "Total Laps"
                totalLapsHeading?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        totalLapsHeading?.translatesAutoresizingMaskIntoConstraints = false

                // Create the Total Laps subheading label
                totalLapsSubheading = UILabel()
        totalLapsSubheading?.text = "\(totalLaps)"
                totalLapsSubheading?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                totalLapsSubheading?.translatesAutoresizingMaskIntoConstraints = false

                // Add labels to the view
        view.addSubview(dailyLapsHeading!)
        view.addSubview(dailyLapsSubheading!)
                view.addSubview(weeklyLapsHeading!)
                view.addSubview(weeklyLapsSubheading!)
                view.addSubview(totalLapsHeading!)
                view.addSubview(totalLapsSubheading!)

                // Calculate the spacing between labels
                let spacingBetweenLabels: CGFloat = 20 // The vertical spacing between the labels

                // Set constraints for the Daily Laps heading and subheading
                NSLayoutConstraint.activate([
                    dailyLapsHeading!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: chartView.frame.origin.y + chartView.frame.height),
                    dailyLapsHeading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                    dailyLapsSubheading!.topAnchor.constraint(equalTo: dailyLapsHeading!.bottomAnchor, constant: 8),
                    dailyLapsSubheading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ])

                // Set constraints for the Weekly Laps heading and subheading
                NSLayoutConstraint.activate([
                    weeklyLapsHeading!.topAnchor.constraint(equalTo: dailyLapsSubheading!.bottomAnchor, constant: spacingBetweenLabels),
                    weeklyLapsHeading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                    weeklyLapsSubheading!.topAnchor.constraint(equalTo: weeklyLapsHeading!.bottomAnchor, constant: 8),
                    weeklyLapsSubheading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ])

                // Set constraints for the Total Laps heading and subheading
                NSLayoutConstraint.activate([
                    totalLapsHeading!.topAnchor.constraint(equalTo: weeklyLapsSubheading!.bottomAnchor, constant: spacingBetweenLabels),
                    totalLapsHeading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                    totalLapsSubheading!.topAnchor.constraint(equalTo: totalLapsHeading!.bottomAnchor, constant: 8),
                    totalLapsSubheading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ])
        
    }
}
