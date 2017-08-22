//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation

/// This viewcontroller shows a selectable list of environments for a specific API entry
class EnvironmentEntryDetailViewController: UITableViewController {
    private enum CellIdentifiers {
        static let EnvironmentCellIdentifier = "EnvironmentCellIdentifier"
    }
    
    private enum Segue: String {
        case add = "AddSegue"
    }
    
    // Pass the following
    var entryName: String!
    var store: DataStore = EnvironmentManagerViewcontroller.sharedEnvironmentManager.store
    
    var viewModel: EntryViewModel!
    
    
    override func viewDidLoad() {
        self.navigationItem.title = self.entryName
        viewModel = EntryViewModel(entry: currentEntry, customStore: CustomEntryStore(self.store))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueID = Segue(rawValue: segue.identifier ?? "") else {
            return
        }
        
        switch segueID {
        case .add:
            guard let destination = segue.destination as? AddEnvironmentViewController else {
                return
            }
            destination.entryName = entryName
            return
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.customEnvironments.count > 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.baseEnviromnments.count
        }
        else {
            return viewModel.customEnvironments.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.EnvironmentCellIdentifier)!

        let environment: Entry.Environment
        if indexPath.section == 0 {
            environment = viewModel.baseEnviromnments[indexPath.row]
        }
        else {
            environment = viewModel.customEnvironments[indexPath.row]
        }
        
        let sortedEnvironmentNames: [Int: [Entry.Environment]] = [0: self.viewModel.baseEnviromnments, 1: self.viewModel.customEnvironments]
        cell.textLabel?.text = environment.environment
        cell.detailTextLabel?.text = environment.baseUrl.absoluteString
        cell.accessoryType = self.viewModel.currentlySelectedEnvironment == sortedEnvironmentNames[indexPath.section]?[indexPath.row].environment ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectEnvironment(indexPath)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Environments"
        case 1:
            return "Custom Environments"
        default:
            return ""
        }
    }
    
    // TODO: Edit to delete "custom" section only
    
    private var currentEntry: Entry {
        return EnvironmentManagerViewcontroller.sharedEnvironmentManager.entry(forService: entryName)!
    }
}



// MARK: - Segue
extension EnvironmentEntryDetailViewController {
    @IBAction func addEnvironment(_ segue: UIStoryboardSegue) {
        guard let source = segue.source as? AddEnvironmentViewController else {
            return
        }
        guard let newEnvironment = source .newEnvironment else {
            return
        }
        self.viewModel.addEnvironment(Entry.Environment(pair: newEnvironment))
        self.tableView.reloadData()
    }
}


class EntryViewModel {
    var baseEntry: Entry
    var customEntryStore: CustomEntryStore
    
    var name: String {
        return baseEntry.name
    }
    
    var baseEnviromnments: [Entry.Environment] {
        // Filter out any environments that are also in the custom environment
        // TOOD: the right solution is to have baseEntry just not include any of the custom environments
        return baseEntry.environments
//        return self.baseEntry.environments.filter{ (element) in
//            return customEnvironments.contains(where: { $0.environment == element.environment})
//        }
    }
    
    var customEnvironments: [Entry.Environment] {
        return self.customEntryStore[name]?.environments ?? []
    }
    
    init(entry: Entry, customStore: CustomEntryStore) {
        baseEntry = entry
        customEntryStore = customStore
    }
    
    private var allEnvironments: [Entry.Environment] {
        return baseEnviromnments + customEnvironments
    }
    
    var currentlySelectedEnvironment: String {
        return EnvironmentManagerViewcontroller.sharedEnvironmentManager.currentEnvironmentFor(apiName: name)!
    }
    
    // Mutators
    func addEnvironment(_ environment: Entry.Environment) {
        self.customEntryStore.addEnvironment((environment.environment, environment.baseUrl), to: name)
    }
    
    func removeEnvironment(_ environmentName: String) {
        var entry = self.customEntryStore[name]
        entry?.removeEnvironment(environmentName)
        self.customEntryStore[name] = entry
    }
    
    func selectEnvironment(_ indexPath: IndexPath) {
        let environment: Entry.Environment?
        if indexPath.section == 0 {
            environment = baseEntry.environments[indexPath.row]
        }
        else {
            environment = customEntryStore[name]?.environments[indexPath.row]
        }
        EnvironmentManagerViewcontroller.sharedEnvironmentManager.select(environment: environment?.environment ?? "", forAPI: name)
    }
}
