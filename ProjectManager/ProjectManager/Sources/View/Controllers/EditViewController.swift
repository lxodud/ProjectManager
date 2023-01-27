//
//  EditViewController.swift
//  ProjectManager
//
//  Created by Hamo, Wonbi on 2023/01/19.
//

import UIKit

final class EditViewController: ProjectViewController {
    private let viewModel: EditViewModel
    
    init(viewModel: EditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        viewModel.changeEditMode(editing)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction(handler: tapDoneButton)
        )
    }
    
    func toggleUserInteractionEnabled() {
        [textView, textField, datePicker].forEach {
            $0.isUserInteractionEnabled.toggle()
        }
    }
    
    private func bindViewModel() {
        viewModel.componentsHandler = { [weak self] viewProject in
            guard let viewProject = viewProject else { return }
            self?.navigationItem.title = viewProject.state.name
            self?.textField.text = viewProject.title
            self?.datePicker.date = viewProject.deadline
            self?.textView.text = viewProject.description
        }
        
        viewModel.editingHandler = { [weak self] in
            self?.toggleUserInteractionEnabled()
        }
    }
}

// MARK: Action Method
extension EditViewController {
    private func tapCancelButton(_ sender: UIAction) {
        dismiss(animated: true)
    }
    
    private func tapDoneButton(_ sender: UIAction) {
        guard let title = textField.text,
              let description = textView.text
        else {
            return
        }
        
        viewModel.updateProject(title: title, deadline: datePicker.date, description: description)
        dismiss(animated: true)
    }
}

// MARK: UI Configuration
extension EditViewController {
    private func configureNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction(handler: tapCancelButton)
        )
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
}
