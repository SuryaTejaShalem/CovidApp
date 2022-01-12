//
//  ViewController.swift
//  CovidReady
//
//  Created by user187877 on 4/27/21.
//

import UIKit
import Charts

class ViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var TotalCases: UILabel!
    
    @IBOutlet weak var RecoveredCases: UILabel!
    
    @IBOutlet weak var Deaths: UILabel!
    
    @IBOutlet weak var CasesPercentage: UILabel!
    
    @IBOutlet weak var RecoverredPercentage: UILabel!
    
    @IBOutlet weak var CovidChart: BarChartView!
    
    
    var cases:[Double:Double] = [:]
    
    var sumOfCases:Double = 0
    var sumOfDeaths:Double = 0
    var sumOfRecovered:Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.CovidChart.delegate = self
        self.CovidChart.chartDescription.enabled = true
        self.CovidChart.legend.enabled = true
       
        
        
        self.CovidChart.marker = MarkerImage()
        
       let xAxis = CovidChart.xAxis
        
        xAxis.granularity = 50000000
        
        xAxis.labelRotationAngle = -90
        xAxis.spaceMin = 20000000
        xAxis.spaceMax = 20000000
        
        
        let yAxis = CovidChart.leftAxis
        yAxis.labelPosition = .outsideChart
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 50000000
      
        
        let rightAxis = CovidChart.rightAxis
        rightAxis.labelPosition = .outsideChart
        rightAxis.axisMinimum = 0
        rightAxis.axisMaximum = 50000000
        
        
        getCovidData()
        
    }
    
    func getCovidData(){
        let session = URLSession.shared
        let session2 = URLSession.shared
       
       
    let queryUrl = URL(string: "https://corona.lmao.ninja/v2/all?yesterday")!
        
        print("https://corona.lmao.ninja/v2/all?yesterday")
        
        
    let task = session.dataTask(with: queryUrl){
               data, response, error in
               
               //check if there was an error or empty data sent
               if error != nil || data == nil {
                   print("Client error!")
                   return
               }
               
               //check HTTP error code
               let r = response as? HTTPURLResponse
               guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                   print("Server error \(String(describing: r?.statusCode))")
                   return
               }
               //data format check
               guard let mime = response.mimeType, mime == "application/json" else {
                   print("Incorrect MIME type: \(String(describing: r?.mimeType))")
                   return
               }
               
               do{
                   let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                   //here you can process the data that your received
                   print(json ?? "Error - No JSON received")
                   
                let deaths = json?["deaths"] as? Double
                let recovered = json?["recovered"] as? Double
                let cases = json?["cases"] as? Double
                
                
             
                   
                  DispatchQueue.main.async {
                    
                    self.TotalCases.text = "\(cases!)"
                    self.RecoveredCases.text = "\(recovered!)"
                    self.Deaths.text = "\(deaths!)"
                
                   }
                   
               }catch {
                   print("Error in JSON")
               }
           }
           
           task.resume()
        
        let queryURL2 = URL(string: "https://corona.lmao.ninja/v2/countries/Canada?yesterday=true&strict=true&query")!

        let task2 = session2.dataTask(with: queryURL2){
                   data, response, error in
                   
                   //check if there was an error or empty data sent
                   if error != nil || data == nil {
                       print("Client error!")
                       return
                   }
                   
                   //check HTTP error code
                   let r = response as? HTTPURLResponse
                   guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                       print("Server error \(String(describing: r?.statusCode))")
                       return
                   }
                   //data format check
                   guard let mime = response.mimeType, mime == "application/json" else {
                       print("Incorrect MIME type: \(String(describing: r?.mimeType))")
                       return
                   }
                   
                   do{
                       let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                       //here you can process the data that your received
                       print(json ?? "Error - No JSON received")
                       
                    
                    let recovered = json?["recovered"] as? Double
                    let cases = json?["cases"] as? Double
                    let population = json?["population"] as? Double
                    
                    
                 
                       
                      DispatchQueue.main.async {
                        
                        
                        let casepercent = (cases!/population!)*100
                        let recpercent = (recovered!/cases!)*100
                        
                        self.CasesPercentage.text = "\(casepercent)"
                        self.RecoverredPercentage.text = "\(recpercent)"
                        
                    
                       }
                       
                   }catch {
                       print("Error in JSON")
                   }
               }
               
               task2.resume()
        
         let session3 = URLSession.shared
        
         let queryURL3 = URL(string: "https://corona.lmao.ninja/v2/continents?yesterday=true&sort")!

         let task3 = session3.dataTask(with: queryURL3){
                    data, response, error in
                    
                    //check if there was an error or empty data sent
                    if error != nil || data == nil {
                        print("Client error!")
                        return
                    }
                    
                    //check HTTP error code
                    let r = response as? HTTPURLResponse
                    guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                        print("Server error \(String(describing: r?.statusCode))")
                        return
                    }
                    //data format check
                    guard let mime = response.mimeType, mime == "application/json" else {
                        print("Incorrect MIME type: \(String(describing: r?.mimeType))")
                        return
                    }
                    
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [Any]
                        //here you can process the data that your received
                        print(json ?? "Error - No JSON received")
                        
                        for continent in json!{
                            let oneContinent = continent as? [String:Any]
                           // let continentName = oneContinent!["continent"] as? String
                            let cases = oneContinent!["cases"] as? Double
                            let recovered = oneContinent!["recovered"] as? Double
                            
                           self.cases[recovered!] = cases
                        }
                        var z = -1
                        let yVals = (self.cases).map {(i)
                            -> BarChartDataEntry in
                            let val = i.value
                            z+=1
                            let b = BarChartDataEntry(x: Double(i.key),
                                                      y: val)
                            return b
                        }
                    /* let recovered = json?["recovered"] as? Double
                     let cases = json?["cases"] as? Double
                     */
                     
                  
                        
                       DispatchQueue.main.async {
                         
                        var set1 : BarChartDataSet! = nil
                        if let set = self.CovidChart.data?.first
                            as? BarChartDataSet {
                                set1 = set
                                set1?.replaceEntries(yVals)
                        } else {
                            set1 = BarChartDataSet(entries: yVals,label: "Data Set")
                            //setting colors for graph
                            set1.colors = //[NSUIColor(red: 46/255.0, green: 46/255.0, blue: 213/255.0, alpha: 1.0)]
                            //ChartColorTemplates.liberty()
                                ChartColorTemplates.colorful()
                            set1.drawValuesEnabled = false
                            set1.barBorderColor = .blue
                            set1.barBorderWidth = 1
                            let data = BarChartData(dataSet: set1)
                            data.barWidth = Double(1)
                            self.CovidChart.data = data
                            self.CovidChart.fitBars = true
                        }
                        //3600 is 1day
                        self.CovidChart.barData?.barWidth = 36000
                        self.CovidChart.data?.notifyDataChanged()
                        self.CovidChart.notifyDataSetChanged()
                        self.CovidChart.setNeedsDisplay()
                     
                        }
                        
                    }catch {
                        print("Error in JSON")
                    }
                }
                
                task3.resume()
         
            }
           }
    

    
  
    

