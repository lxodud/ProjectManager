//
//  ProjectListViewController.swift
//  ProjectManager
//
//  Created by Hamo, Wonbi on 2023/01/17.
//

import UIKit

protocol ProjectListActionDelegate: AnyObject {
    func deleteProject(willDelete project: Project)
    func editProject(willEdit project: Project)
}

final class ProjectListViewController: UIViewController {
    private enum Section {
        case main
    }
    
    private let header: HeaderView
    private let tableView = UITableView()
    private var dataSource: UITableViewDiffableDataSource<Section, Project>?
    weak var delegate: ProjectListActionDelegate?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    init(state: State) {
        header = HeaderView(title: state.name)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLayout()
        configureTableView()
        configureDataSource()
    }
}

// MARK: Interface Method
extension ProjectListViewController {
    func updateList(with data: [Project]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Project>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource?.apply(snapshot)
    }
}

// MARK: Action Method
extension ProjectListViewController {
    private func makeDeleteContextualAction(with project: Project) -> UIContextualAction {
        let context = UIContextualAction(
            style: .destructive,
            title: "Delete",
            handler: { _, _, completionHandler in
                self.delegate?.deleteProject(willDelete: project)
                
                completionHandler(true)
            }
        )
        
        return context
    }
}

// MARK: Diffable DataSource
extension ProjectListViewController {
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Project>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, project in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ProjectCell.reuseIdentifier,
                    for: indexPath
                ) as? ProjectCell else {
                    return UITableViewCell()
                }
                
                let viewModel = ProjectCellViewModel()
                cell.setupViewModel(viewModel)
                viewModel.makeCellData(project)
                
                return cell
            }
        )
    }
}

// MARK: TableView Delegate
extension ProjectListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard let project = dataSource?.itemIdentifier(for: indexPath) else { return nil }
        let action = makeDeleteContextualAction(with: project)
        let configuration = UISwipeActionsConfiguration(actions: [action])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let project = dataSource?.itemIdentifier(for: indexPath) else { return }
        delegate?.editProject(willEdit: project)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: UI Configure
extension ProjectListViewController {
    private func configureView() {
        tableView.backgroundColor = .systemGray6
        
        [header, tableView].forEach {
            stackView.addArrangedSubview($0)
        }
        
        view.addSubview(stackView)
    }
    
    private func configureLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            header.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.09)
        ])
    }
    
    private func configureTableView() {
        tableView.register(ProjectCell.self, forCellReuseIdentifier: ProjectCell.reuseIdentifier)
        tableView.delegate = self
    }
}
