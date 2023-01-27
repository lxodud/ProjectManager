//
//  MainViewController.swift
//  ProjectManager
//
//  Created by Hamo, Wonbi on 2023/01/12.
//

import UIKit

final class MainViewController: UIViewController {
    private let toDoViewController: ProjectListViewController
    private let doingViewController: ProjectListViewController
    private let doneViewController: ProjectListViewController
    
    private let totalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var viewModel: MainViewModel
    
    init(viewModel: MainViewModel,
         toDoViewController: ProjectListViewController,
         doingViewController: ProjectListViewController,
         doneViewController: ProjectListViewController
    ) {
        self.viewModel = viewModel
        self.toDoViewController = toDoViewController
        self.doingViewController = doingViewController
        self.doneViewController = doneViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureView()
        configureLayout()
        configureProjectListActionDelegate()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.todoHandler = { [weak self] todoList in
            self?.toDoViewController.updateList(with: todoList)
        }
        
        viewModel.doingHandler = { [weak self] doingList in
            self?.doingViewController.updateList(with: doingList)
        }
        
        viewModel.doneHandler = { [weak self] doneList in
            self?.doneViewController.updateList(with: doneList)
        }
    }
    
    private func configureProjectListActionDelegate() {
        [toDoViewController, doingViewController, doneViewController].forEach {
            $0.setDelegate(self)
        }
    }
}

// MARK: Action Method
extension MainViewController {
    private func tapAddButton(_ sender: UIAction) {
        let addViewModel = AddViewModel()
        let addViewController = AddViewController(viewModel: addViewModel)
        
        addViewModel.setDelegate(viewModel)
        addViewController.modalPresentationStyle = .pageSheet
        
        let navigationController = UINavigationController(rootViewController: addViewController)
        present(navigationController, animated: true)
    }
}

// MARK: ProjectListAction Delegate
extension MainViewController: ProjectListActionDelegate {
    func changeProjectState(with state: State, to project: Project) {
        viewModel.changeStateProject(state: state, project: project)
    }
    
    func deleteProject(willDelete project: Project) {
        viewModel.deleteProject(with: project)
    }
    
    func editProject(willEdit project: Project) {
        let editViewModel = EditViewModel()
        let editViewController = EditViewController(viewModel: editViewModel)
        
        editViewModel.setProject(project)
        editViewModel.changeEditMode(false)
        editViewModel.setDelegate(viewModel)
        editViewController.modalPresentationStyle = .pageSheet
        
        let navigationController = UINavigationController(rootViewController: editViewController)
        present(navigationController, animated: true)
    }
}

// MARK: UI Configuration
extension MainViewController {
    private func configureNavigation() {
        navigationItem.title = "Project Manager"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction(handler: tapAddButton)
        )
    }
    
    private func configureView() {
        view.backgroundColor = .systemGray6
        
        [toDoViewController, doingViewController, doneViewController].forEach {
            addChild($0)
            totalStackView.addArrangedSubview($0.view)
        }
        
        view.addSubview(totalStackView)
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            totalStackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            totalStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            totalStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            totalStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}
