//
//  ViewController.swift
//  controllers&Delegates
//
//  Created by 方仕賢 on 2022/5/4.
//

import UIKit
import UniformTypeIdentifiers
import MediaPlayer
import ContactsUI
import AVFoundation
import PhotosUI

class ViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    //photo
    let imageController = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    
    //color
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorBackgroundView: UIView!
    
    @IBOutlet weak var colorBackgroundColor: UIButton!
    @IBOutlet weak var colorViewButton: UIButton!
    
    var isView = true //確定是不是在 view 上著色
    
    //file
    @IBOutlet weak var fileImage: UIImageView!
    let fileController = UIDocumentPickerViewController(forOpeningContentTypes: [.jpeg,.png,.text], asCopy: true)
    
    @IBOutlet weak var fileTextView: UITextView!
    
    //music
    let musicController = MPMediaPickerController(mediaTypes: .music)
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var musicImageView: UIImageView!
    
    //contact
    @IBOutlet weak var contactorLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    //font
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var fontLabel: UILabel!
    @IBOutlet weak var fontView: UIView!
    
    //video
    @IBOutlet weak var videoView: UIView!
    var player = AVPlayer()
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    
    //multiSelect
    @IBOutlet weak var multiImageView: UIImageView!
    @IBOutlet weak var multiPhotosStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    //photo
    func showCameraOrPhotos(isCamera: Bool) {
        if isCamera {
            imageController.sourceType = .camera
        } else {
            imageController.sourceType = .photoLibrary
        }
        imageController.delegate = self
        present(self.imageController, animated: true)
    }
    
    @IBAction func useCamera(_ sender: Any) {
        showCameraOrPhotos(isCamera: true)
    }
    
    @IBAction func pickPhotos(_ sender: Any) {
        showCameraOrPhotos(isCamera: false)
    }
    
    //color
    @IBAction func chooseColor(_ sender: UIButton) {
        let colorController = UIColorPickerViewController()
        if sender == colorViewButton {
            isView = true
        } else {
            isView = false
        }
        colorController.delegate = self
        present(colorController, animated: true)
    }
    
    // file
    @IBAction func selectFile(_ sender: Any) {
        fileController.delegate = self
        present(fileController, animated: true)
    }
    
    // music
    @IBAction func selectMusic(_ sender: Any) {
        musicController.delegate = self
        present(musicController, animated: true)
    }
    
    //font
    @IBAction func enter(_ sender: Any) {
        if textField.text != "" {
            fontLabel.text = textField.text
            textField.text = ""
        } else {
            let controller = UIAlertController(title: "Type something", message: nil, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(controller, animated: true)
        }
    }
    
    @IBAction func selectFont(_ sender: Any) {
        let fontConfig = UIFontPickerViewController.Configuration()
        fontConfig.includeFaces = true
        let fontPicker = UIFontPickerViewController(configuration: fontConfig)
        fontPicker.delegate = self
        present(fontPicker, animated: true)
    }
    
    // contact
    @IBAction func selectContactor(_ sender: Any) {
        let controller = CNContactPickerViewController()
        controller.delegate = self
        present(controller, animated: true)
    }
    
    // video
    @IBAction func selectVideo(_ sender: Any) {
        if let path = Bundle.main.path(forResource: "海綿寶寶 魔勾", ofType: "mp4"), UIVideoEditorController.canEditVideo(atPath: path) {
            let controller = UIVideoEditorController()
            controller.videoPath = path
            controller.delegate = self
            present(controller, animated: true)
        }
    }
    
    @IBAction func pause(_ sender: Any) {
        player.pause()
        playButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    @IBAction func playVideo(_ sender: Any) {
        player.play()
        playButton.isHidden = true
        pauseButton.isHidden = false
    }
    
    // multi select
    @IBAction func selectPhotos(_ sender: Any) {
        var photoConfig = PHPickerConfiguration()
        photoConfig.filter = .images
        photoConfig.selectionLimit = 0
        let pickerController = PHPickerViewController(configuration: photoConfig)
        pickerController.delegate = self
        present(pickerController, animated: true)
    }
    
}

//video
extension ViewController: UIVideoEditorControllerDelegate {
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        player = AVPlayer(url: URL(fileURLWithPath: editedVideoPath))
        let playerLayer = AVPlayerLayer()
        playerLayer.frame = CGRect(x: 0, y: 70, width: view.bounds.width, height: view.bounds.height/3)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.player = player
        videoView.layer.addSublayer(playerLayer)
        player.play()
        pauseButton.isHidden = false
        dismiss(animated: true)
    }
}

extension ViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            numberLabel.text = phoneNumber
        }
        contactorLabel.text = contact.givenName
    }
}

extension ViewController: UIFontPickerViewControllerDelegate, UITextFieldDelegate {
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        if let fontDesciptor = viewController.selectedFontDescriptor {
            fontLabel.font = UIFont(descriptor: fontDesciptor, size: fontLabel.font.pointSize)
            dismiss(animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

extension ViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        musicPlayer.setQueue(with: mediaItemCollection)
        musicPlayer.play()
        musicNameLabel.text = musicPlayer.nowPlayingItem?.title
        singerLabel.text = musicPlayer.nowPlayingItem?.artist
        musicImageView.image = musicPlayer.nowPlayingItem?.artwork?.image(at: musicImageView.bounds.size)
        musicController.dismiss(animated: true)
    }
    
}

extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            if let image = UIImage(contentsOfFile: url.path) {
                fileImage.image = image
            }
            do {
                let text = try String(contentsOfFile: url.path)
                fileTextView.text = text
            }
            catch {
                print("no text")
            }
        }
    }
}

extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        if isView {
            colorView.backgroundColor = color
        } else {
            colorBackgroundView.backgroundColor = color
        }
        
        dismiss(animated: true)
    }
}

extension ViewController:  UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        imageView.image = image
        imageController.dismiss(animated: true)
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProviders = results.map(\.itemProvider)
        for (i,itemProvider) in itemProviders.enumerated() where itemProvider.canLoadObject(ofClass: UIImage.self) {
            let newImageView = UIImageView(frame: multiImageView.frame)
            newImageView.layer.contentsGravity = .resizeAspectFill
            multiPhotosStackView.insertArrangedSubview(newImageView, at: i)
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                DispatchQueue.main.async {
                    guard let image = image as? UIImage, let self = self else {
                        return
                    }
                    newImageView.image = image
                }
            }
        }
        dismiss(animated: true)
    }
}
