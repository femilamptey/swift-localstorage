//
//  FilesViewController.swift
//  localstorage
//
//  Created by Günther Eberl on 05.04.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import os.log
import YMTreeMap


class FilesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let userDefaults = UserDefaults.standard
    let values = TestValues_Files.AllValues  // TODO use user's filesystem values, not files test values.
    
    @IBAction func onSettingsButton(_ sender: UIButton) {self.showSettings()}
    @IBOutlet var mainView: UIView!
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        os_log("viewDidLoad", log: logTabFolders, type: .debug)
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TypesViewController.setTheme),
                                               name: .darkModeChanged, object: nil)

        self.setTheme()
        
        // The following line is needed, the Storyboard connection alone is not sufficient.
        self.collectionView?.register(FilesCollectionViewCell.self, forCellWithReuseIdentifier: "FilesCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        os_log("viewWillAppear", log: logTabFolders, type: .debug)
        super.viewWillAppear(animated)
        
        let treeMap = YMTreeMap(withValues: self.values)
        treeMap.alignment = .RetinaSubPixel

        if let layout = self.collectionView.collectionViewLayout as? FilesCollectionViewLayout {
            let bounds = self.mainView?.bounds ?? .zero
            layout.rects = treeMap.tessellate(inRect: bounds)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // This fires when switching from landscape to portrait mode.
        os_log("viewWillTransition", log: logTabFolders, type: .debug)
        super.viewWillTransition(to: size, with: coordinator)

        let treeMap = YMTreeMap(withValues: self.values)
        if let layout = self.collectionView.collectionViewLayout as? FilesCollectionViewLayout {
            layout.rects = treeMap.tessellate(inRect: CGRect(origin: .zero, size: size))
        }
    }
    
    override func didReceiveMemoryWarning() {
        os_log("didReceiveMemoryWarning", log: logTabFolders, type: .info)
        super.didReceiveMemoryWarning()
    }
    
    @objc func setTheme() {
        os_log("setTheme", log: logTabFolders, type: .debug)
        if self.userDefaults.bool(forKey: UserDefaultStruct.darkMode) {
            self.applyColors(fg: "ColorFontWhite", bg: "ColorBgBlack")
            self.navigationController?.navigationBar.barStyle = .black
        } else {
            self.applyColors(fg: "ColorFontBlack", bg: "ColorBgWhite")
            self.navigationController?.navigationBar.barStyle = .default
        }
    }
    
    func applyColors(fg: String, bg: String) {
        os_log("applyColors", log: logTabFolders, type: .debug)
        let bgColor: UIColor = UIColor(named: bg)!
        self.mainView.backgroundColor = bgColor
    }
    
    func showSettings() {
        os_log("showSettings", log: logTabFolders, type: .debug)
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
        self.present(controller, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilesCell", for: indexPath)
        
        if let cell = cell as? FilesCollectionViewCell {
            let file = TestValues_Files.FileInfos[indexPath.item]
            cell.tintColor = self.color(forType: file.type)
            cell.symbolLabel.text = file.name
            cell.valueLabel.text = getSizeString(byteCount: Int64(TestValues_Files.AllValues[indexPath.item]))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        // Change background color when user touches cell
        if let cell = collectionView.cellForItem(at: indexPath) as? FilesCollectionViewCell {
            cell.tintColor = UIColor.red
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        // Change background color back when user releases touch
        if let cell = collectionView.cellForItem(at: indexPath) as? FilesCollectionViewCell {
            let file = TestValues_Files.FileInfos[indexPath.item]
            cell.tintColor = self.color(forType: file.type)
        }
    }
    
    func color(forType type: String) -> UIColor {
        if type == LocalizedTypeNames.audio {
            return UIColor(named: "ColorTypeAudio")!
        } else if type == LocalizedTypeNames.videos {
            return UIColor(named: "ColorTypeVideos")!
        } else if type == LocalizedTypeNames.documents {
            return UIColor(named: "ColorTypeDocuments")!
        } else if type == LocalizedTypeNames.images {
            return UIColor(named: "ColorTypeImages")!
        } else if type == LocalizedTypeNames.code {
            return UIColor(named: "ColorTypeCode")!
        } else if type == LocalizedTypeNames.archives {
            return UIColor(named: "ColorTypeArchives")!
        } else {  // type == LocalizedTypeNames.other
            return UIColor(named: "ColorTypeOther")!
        }
    }

}