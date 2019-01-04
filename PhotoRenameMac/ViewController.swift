//
//  ViewController.swift
//  PhotoRenameMac
//
//  Created by Alexalder on 30/12/2018.
//  Copyright © 2018 Alexalder. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var folderName: NSTextField!
    @IBOutlet weak var renameButton: NSButton!
    @IBOutlet weak var renameProgressBar: NSProgressIndicator!
    @IBOutlet weak var dateFormattingText: NSTextField!
    @IBOutlet weak var exampleText: NSTextField!
    
    var path : URL!
    var dateFormatter : MyDateFormatter?
    
    let cameraExtensions =  ["mov", "jpg", "png", "mp4", "gif", "heic"]
    
    @IBAction func browseFolder(sender: AnyObject) {
        chooseFolder()
    }
    
    @IBAction func renameFiles(sender: AnyObject) {
        renameAll()
    }
    
    func chooseFolder(){
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose an image folder";
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canChooseFiles          = false
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if (result != nil) {
                path = result!.absoluteURL
                folderName.stringValue = result!.path
                renameButton.isHidden = false
                renameProgressBar.doubleValue = 0
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func renameAll(){
        if (dateFormatter == nil){
            dateFormatter = MyDateFormatter(optionalDateFormat: dateFormattingText.stringValue)
        }
        
        let directoryContents = listDirectoryFiles(directory: path);
        
        let filesPaths = filterByExtentions(extentions: cameraExtensions, files: directoryContents)
        renameProgressBar.maxValue = Double(filesPaths.count)
        
        for file in filesPaths{
            guard let shotDate = getShotDate(photo: file) else{
                break
            }
            let newFileName = formatDate(photoDate: shotDate)
            renameFile(folder: path, oldURL: file, newName: newFileName)
            updateProgressbar()
        }
    }
    
    func listDirectoryFiles(directory : URL) -> [URL]{
        do{
            return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        } catch {
            return []
        }
    }
    
    func filterByExtentions(extentions: [String], files: [URL]) -> [URL]{
        return files.filter{extentions.contains($0.pathExtension.lowercased()) }
    }
    
    func getShotDate(photo: URL)-> Date?{
        var shotDate : Date? = nil
        if let exifShotDate = getExifShotDate(photo: photo as CFURL){
            shotDate = exifShotDate
        } else {
            if let fileShotDate = getFileShotDate(photo: photo){
                shotDate = fileShotDate
            }
        }
        return shotDate
    }
    
    func getExifShotDate(photo: CFURL) -> Date?{
        guard let imageSource = CGImageSourceCreateWithURL(photo, nil) else {return nil}
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String:Any]
        let exif = imageProperties?[kCGImagePropertyExifDictionary as String] as? [String:Any]
        return exif?[kCGImagePropertyExifDateTimeDigitized as String] as? Date
    }
    
    func getFileShotDate(photo: URL) -> Date?{
        do{
        return try photo.resourceValues(forKeys: [URLResourceKey.creationDateKey]).creationDate
        } catch {
            return nil
        }
    }

    func renameFile(folder: URL, oldURL: URL, newName: String){
        var newPath = folder.appendingPathComponent(newName).appendingPathExtension(oldURL.pathExtension.lowercased()).path
        var currentTry = 0
        while (FileManager.default.fileExists(atPath: newPath) && oldURL != URL(fileURLWithPath: newPath)){
            newPath = folder.appendingPathComponent(newName + String(currentTry)).appendingPathExtension(oldURL.pathExtension.lowercased()).path
            currentTry += 1
        }
        do{
            let newURL = URL(fileURLWithPath: newPath)
            try FileManager.default.moveItem(at: oldURL, to: newURL)
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    func formatDate(photoDate : Date) -> String{
        return dateFormatter!.string(from: photoDate)
    }
    
    func updateProgressbar(){
        renameProgressBar.doubleValue = renameProgressBar.doubleValue + 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renameButton.isHidden = true
        self.dateFormattingText.delegate = self
        showDateExample()
    }
    
    func showDateExample(){
        dateFormatter = MyDateFormatter(optionalDateFormat: dateFormattingText.stringValue)
        exampleText.stringValue = "Example: " + formatDate(photoDate: Date(timeIntervalSince1970: -468720000))
    }
    
    func controlTextDidChange(_ notification: Notification) {
        showDateExample()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

