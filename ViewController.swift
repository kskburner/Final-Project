// Kadir S. Karagoz
// Swift IOS Development - Final Project
// Rutgers University, Spring 2021
// 9 May, 2021

import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var newTicker: UITextField!
    
    // Declare target url
    var url: URL?
    var timer: Timer?
    var params = "https://min-api.cryptocompare.com/data/pricemulti?fsyms="
    
    var tickers = [
        "BTC",
        "ETH"
    ]
    
    var tableData = [String]()
    
    // Function to call the API & handle the response
    private func getPrice(url: URL, completion: @escaping(_ value: [String]?) -> Void) {
        // Check if an error occurred
        // If error handle it, if not return response data
        let request = URLSession.shared.dataTask(with: url) { [self] (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            // try / catch block to parse JSON response, catch & handle if error occurs
            do {
                let json = try JSON(data: data)
                var param = ""
                tableData = [String]()
                for ticker in tickers {
                    param = ticker
                    let price = json[ticker]["USD"]
                    param = param + " ->  \(price)"
                    tableData.append(param)
                }
                completion(tableData)
            } catch {
                completion(nil)
            }
        }
        request.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        for ticker in tickers {
            params = params + "," + ticker
        }
        params = params + "&tsyms=USD"
        url = URL(string: params)
        
        timer = Timer.scheduledTimer(timeInterval: 3,
                                     target: self,
                                     selector: #selector(runCall),
                                     userInfo: nil,
                                     repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func runCall() {
        guard let url = url else { return }
        print(url)
        getPrice(url: url) { (value) in
            DispatchQueue.main.async {
                print(value)
            }
        }
        self.tableView.reloadData()
    }
    
    
    // Function to format response from API
    private func format(value: NSNumber?) -> String? {
        let formatTool = NumberFormatter()
        formatTool.locale = Locale(identifier: "en_US")
        formatTool.numberStyle = .currency
        
        guard let value = value,
              let output = formatTool.string(from: value) else {
                  return nil
        }
        return output
    }
    
    @IBAction func onClick(_ sender: Any) {
        if let new_ticker = newTicker.text {
            let new = String(new_ticker)
            newTicker.text = ""
            tickers.append(new)
            print(tickers)
            
            var base = "https://min-api.cryptocompare.com/data/pricemulti?fsyms="
            for ticker in tickers {
                base =  base + "," + ticker
            }
            params = base + "&tsyms=USD"
            url = URL(string: params)
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = tableData[indexPath.row]
        
        return cell
    }
}
