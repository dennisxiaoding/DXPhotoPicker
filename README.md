# DXPhotoPickerController

![logo](https://github.com/AwesomeDennis/DXPhotoPicker/blob/master/ScreenShot/Icon.png)

## About
DXPhotoPickerController is a component that funtioned like imagepicker in WeChat. It's very similar to UIImagePickerController which makes its usage simple and concise.

DXPhotoPickerController is a swift version of [DNImagePicker](https://github.com/AwesomeDennis/DNImagePicker).

I don't make it as a pod because of the flexible UI requirements. Only supported the simple demo and you can customize your own style.

<center> ![image](https://github.com/AwesomeDennis/DXPhotoPicker/blob/master/ScreenShot/ScreenShot.gif)  </center>

##Version
The current version can support Swift 3. If you want the Swift 2.2 one, [click here](https://github.com/AwesomeDennis/DXPhotoPicker/releases/tag/1.0)


## Usage
`DXPhotoPickerController` is similar to `UIImagePickerController` in its usage.

### Example
```
	let picker = DXPhotoPickerController()
    picker.photoPickerDelegate = self
    self.present(picker, animated: true, completion: nil)
```
```
    // MARK: DXPhototPickerControllerDelegate
    func photoPickerDidCancel(photoPicker: DXPhotoPickerController) {
        photoPicker.dismiss(animated: true, completion: nil)
    }

    func photoPickerController(photoPicker photosPicker: DXPhotoPickerController?,
                               sendImages: [PHAsset]?,
                               isFullImage: Bool) {
        photosPicker?.dismiss(animated: true, completion: nil)
        let vc = storyboard?.instantiateViewController(withIdentifier: "DXSelectedImageViewController") as! DXSelectedImageViewController
        vc.selectedImages = sendImages
        vc.isFullImage = isFullImage
        navigationController?.pushViewController(vc, animated: true)
    }


```

The call back delegte methods
```
	 func photoPickerController(photoPicker photosPicker: DXPhotoPickerController?,
                               sendImages: [PHAsset]?,
                               isFullImage: Bool)
```
 param `isFullImage` suggested if the image you choose is the high quality image.

## Requirements
DXPhotoPickerController is written in Swift and links against `Photos.framework`. It therefore requires iOS 8 or later.

##Tips
Add `Photo Library Usage Description` key in `Info.plist` after iOS 10, or it will crash.

## Author
我叫丁晓， [Weibo](http://weibo.com/GreatDingXiao).
😄

## Inspired
[mwaterfall/MWPhotoBrowser](https://github.com/mwaterfall/MWPhotoBrowser) gave a me great help!
