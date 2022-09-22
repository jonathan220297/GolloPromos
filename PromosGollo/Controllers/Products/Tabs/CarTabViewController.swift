//
//  CarTabViewController.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 13/9/22.
//

import UIKit

class CarTabViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var carTableView: UITableView!
    
    // MARK: - Lifecycle
    init() {
        super.init(nibName: "CarTabViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.title = "Car"
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Functions
    func configureTableView() {
        carTableView.register(
            UINib(
                nibName: "CarProductTableViewCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "CarProductTableViewCell"
        )
    }
}

extension CarTabViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCarProductCell(tableView, cellForRowAt: indexPath)
    }
    
    func getCarProductCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CarProductTableViewCell", for: indexPath) as? CarProductTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
}
