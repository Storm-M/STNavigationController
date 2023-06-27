//
//  ViewController.swift
//  STNavigationController
//
//  Created by storm.miao on 04/20/2023.
//  Copyright (c) 2023 storm.miao. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {
    
    let imageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .green
        v.image = .init(named: "demo_1")
        return v
    }()
    
    lazy var button: UIButton = {
        let v = UIButton()
        v.backgroundColor = .blue
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setTitle("下一页", for: .normal)
        v.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return v
    }()
    
    @objc func buttonAction() {
        let vc = ViewController3()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "vc2"
        view.backgroundColor = .lightGray
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            button.heightAnchor.constraint(equalToConstant: 40),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 100),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:  -100)
        ])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

