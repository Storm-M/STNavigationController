//
//  ViewController.swift
//  STNavigationController
//
//  Created by storm.miao on 04/20/2023.
//  Copyright (c) 2023 storm.miao. All rights reserved.
//

import UIKit
import STNavigationController

class ViewController: UIViewController {
    
    let imageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .green
        v.image = .init(named: "demo_0")
        return v
    }()
    
    lazy var button: UIButton = {
        let v = UIButton()
        v.backgroundColor = .green
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("下一页", for: .normal)
        v.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return v
    }()
    
    lazy var closeButton: UIButton = {
        let v = UIButton()
        v.backgroundColor = .green
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("关闭转场动画", for: .normal)
        v.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return v
    }()
    
    @objc func buttonAction() {
        let vc = ViewController2.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func closeButtonAction() {
        (navigationController as? STUINavigationController)?.isUseCustomAnimation = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "No Title"
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        view.addSubview(button)
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            button.heightAnchor.constraint(equalToConstant: 40),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: button.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            closeButton.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalTo: button.widthAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

