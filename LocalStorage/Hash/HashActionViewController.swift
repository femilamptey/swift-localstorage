//
//  HashActionViewController.swift
//  Hash
//
//  Created by Günther Eberl on 04.02.18.
//  Copyright © 2018 Günther Eberl. All rights reserved.
//

import UIKit
import MobileCoreServices
import os.log
import CommonCryptoModule


// Logger configuration.
let logHashExtension = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "hash-extension")


extension Data {
    public func md2() -> Data {
        var digest = Data(count: Int(CC_MD2_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_MD2(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
    
    public func md4() -> Data {
        var digest = Data(count: Int(CC_MD4_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_MD4(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
    
    public func md5() -> Data {
        var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_MD5(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
    
    public func sha1() -> Data {
        var digest = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_SHA1(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
    
    public func sha224() -> Data {
        var digest = Data(count: Int(CC_SHA224_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_SHA224(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
    
    public func sha256() -> Data {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_SHA256(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
    
    public func sha384() -> Data {
        var digest = Data(count: Int(CC_SHA384_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_SHA384(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
    
    public func sha512() -> Data {
        var digest = Data(count: Int(CC_SHA512_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { resultBytes in
            self.withUnsafeBytes { originBytes in
                CC_SHA512(originBytes, CC_LONG(count), resultBytes)
            }
        }
        return digest
    }
}


class HashActionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var settingsTableView: UITableView!
    
    @IBOutlet weak var calculateButton: UIButton!
    @IBAction func onCalculateButton(_ sender: UIButton) { self.hashFile() }
    
    @IBOutlet weak var digestTextView: UITextView!
    
    @IBOutlet weak var copyButton: UIButton!
    @IBAction func onCopyButton(_ sender: UIButton) { self.copyHash() }
    
    let userDefaults = UserDefaults.standard
    var fileData: Data?

    override func viewDidLoad() {
        os_log("viewDidLoad", log: logHashExtension, type: .debug)
        super.viewDidLoad()
        
        ensureUserDefaults()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HashActionViewController.reloadHashFunction),
                                               name: .hashFunctionChanged, object: nil)
    
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
               // Search for "Uniform Type Identifiers Reference" for a full list of UTIs.

                // For: All kinds of files on the file system.
                if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                    provider.loadItem(forTypeIdentifier: "public.file-url",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
                
                // For: public.jpeg, public.tiff, public.fax, public.jpeg-2000 , public.camera-raw-image, ...
                if provider.hasItemConformingToTypeIdentifier("public.image") {
                    provider.loadItem(forTypeIdentifier: "public.image",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
                
                // For: public.video, com.apple.quicktime-movie, public.avi, public.mpeg, public.mpeg-4 , ...
                if provider.hasItemConformingToTypeIdentifier("public.movie") {
                    provider.loadItem(forTypeIdentifier: "public.movie",
                                      options: [:],
                                      completionHandler: self.loadFile)
                }
            }
        }
    }
    
    func loadFile(coding: NSSecureCoding?, error: Error!) {
        os_log("loadFile", log: logHashExtension, type: .debug)
        
        let errorLoadFile = NSLocalizedString("hash-error-load-file",
                                              value: "Error: Unable to load file",
                                              comment: "Text inside multiline TextView")
        
        if error != nil {
            os_log("%@", log: logHashExtension, type: .error, error.localizedDescription)
            self.digestTextView.text = errorLoadFile
            return
        }
        
        if coding != nil {
            if let url = coding as? URL {
                do {
                    self.fileData = try Data(contentsOf: url)
                } catch let error {
                    os_log("%@", log: logHashExtension, type: .error, error.localizedDescription)
                    self.calculateButton.isEnabled = false
                    self.digestTextView.text = errorLoadFile
                }
            }
        }
    }
    
    func hashFile() {
        os_log("hashFile", log: logHashExtension, type: .debug)
        
        if self.fileData != nil {
            
            let hashFunction: String = userDefaults.string(forKey: UserDefaultStruct.hashFunction)!
            var hashDigest: String
            
            if hashFunction == "CRC32" {
                
                let crcObj = CRC32(data: self.fileData!)
                let crcDecimal: UInt32 = crcObj.crc
                var crcHex: String = String(crcDecimal, radix: 16)
                while crcHex.count < 8 {
                    crcHex = "0" + crcHex
                }
                hashDigest = crcHex
            
            } else if hashFunction == "MD2" {
                let md2Data: Data = self.fileData!.md2()
                hashDigest = md2Data.map { String(format: "%02hhx", $0) }.joined()
                
            } else if hashFunction == "MD4" {
                let md4Data: Data = self.fileData!.md4()
                hashDigest = md4Data.map { String(format: "%02hhx", $0) }.joined()
                
            } else if hashFunction == "MD5" {
                let md5Data: Data = self.fileData!.md5()
                hashDigest = md5Data.map { String(format: "%02hhx", $0) }.joined()
                
            } else if hashFunction == "SHA1" {
                let sha1Data: Data = self.fileData!.sha1()
                hashDigest = sha1Data.map { String(format: "%02hhx", $0) }.joined()
                
            } else if hashFunction == "SHA224" {
                let sha224Data: Data = self.fileData!.sha224()
                hashDigest = sha224Data.map { String(format: "%02hhx", $0) }.joined()
                
            } else if hashFunction == "SHA256" {
                let sha256Data: Data = self.fileData!.sha256()
                hashDigest = sha256Data.map { String(format: "%02hhx", $0) }.joined()
            
            } else if hashFunction == "SHA384" {
                let sha384Data: Data = self.fileData!.sha384()
                hashDigest = sha384Data.map { String(format: "%02hhx", $0) }.joined()
                
            } else if hashFunction == "SHA512" {
                let sha512Data: Data = self.fileData!.sha512()
                hashDigest = sha512Data.map { String(format: "%02hhx", $0) }.joined()
                
            } else {
                let errorUndefinedFunction = NSLocalizedString("hash-error-undefined-function",
                                                               value: "Error: Undefined hash function",
                                                               comment: "Text inside multiline TextView")
                self.digestTextView.text = errorUndefinedFunction
                self.copyButton.isEnabled = false
                return
            }

            self.digestTextView.text = self.addLineBreaks(input: hashDigest)
            self.copyButton.isEnabled = true
        } else {
            let errorUnableToHash = NSLocalizedString("hash-error-unable-hash",
                                                      value: "Error: Unable to hash file",
                                                      comment: "Text inside multiline TextView")
            self.digestTextView.text = errorUnableToHash
            self.copyButton.isEnabled = false
        }
    }
    
    func addLineBreaks(input: String) -> String {
        os_log("addLineBreaks", log: logHashExtension, type: .debug)
        
        var output: String = ""
        for (n, char) in input.enumerated() {
            if n > 0 {
                if n % 16 == 0 {
                    output += "\n"
                } else if n % 4 == 0 {
                    output += " "
                }
            }
            output += String(char)
        }
        return output
    }
    
    func removeLineBreaks(input: String) -> String {
        os_log("removeLineBreaks", log: logHashExtension, type: .debug)
        
        var output: String = input
        output = output.replacingOccurrences(of: " ", with: "")
        output = output.replacingOccurrences(of: "\n", with: "")
        return output
    }
    
    func copyHash() {
        os_log("copyHash", log: logHashExtension, type: .debug)
        
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = self.removeLineBreaks(input: self.digestTextView.text)
    }

    @objc func reloadHashFunction() {
        os_log("reloadHashFunction", log: logHashExtension, type: .debug)
        
        self.digestTextView.text = ""
        self.copyButton.isEnabled = false
        self.settingsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let functionCell = tableView.dequeueReusableCell(withIdentifier: "protoCell")!
        
        let cellHashFunction = NSLocalizedString("hash-cell-function",
                                                 value: "Hash function",
                                                 comment: "Title of cell")
        functionCell.textLabel?.text = cellHashFunction
        
        functionCell.detailTextLabel?.text = userDefaults.string(forKey: UserDefaultStruct.hashFunction)!
        return functionCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func done() {
        // Return any edited content to the host app.
        // Since we don't do anything to the file, we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
}
