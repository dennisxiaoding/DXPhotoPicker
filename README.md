# DXPhotoPickerController

![logo](https://github.com/AwesomeDennis/DXPhotoPicker/blob/master/ScreenShot/Icon.png)

## About
DXPhotoPickerController is a component that funtioned like imagepicker in WeChat. It's very similar to UIImagePickerController which makes its usage simple and concise.

DXPhotoPickerController is a swift version of [DXImagePicker](https://github.com/AwesomeDennis/DNImagePicker).

I don't make it as a pod because of the flexible UI requirements. Only supported the simple demo and you can customize your own style.

<center> ![image](https://github.com/AwesomeDennis/DXPhotoPicker/blob/master/ScreenShot/ScreenShot.gif) </center>

## Usage
`DXPhotoPickerController` is similar to `UIImagePickerController` in its usage.

### Example
```
	let picker = DXPhotoPickerController()
    picker.photoPickerDelegate = self
    self.presentViewController(picker, animated: true, completion: nil)
```
```
    // MARK: DXPhototPickerControllerDelegate
    func photoPickerDidCancel(photoPicker: DXPhotoPickerController) {
        photoPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    func photoPickerController(photosPicker: DXPhotoPickerController?, sendImages:   	[PHAsset]?, isFullImage: Bool) {
        photosPicker?.dismissViewControllerAnimated(true, completion: nil)
        print(sendImages)
    }
```

The call back delegte methods `func photoPickerController(photosPicker: DXPhotoPickerController?, sendImages:   	[PHAsset]?, isFullImage: Bool)` param `isFullImage` suggested if the image you choose is the high quality image.

## Requirements
DXPhotoPickerController is written in Swift and links against `Photos.framework`. It therefore requires iOS 8 or later.

## Author
我叫丁晓， [Weibo](http://weibo.com/GreatDingXiao).
😄

## Inspired
[JKImagePicker](https://github.com/pjk1129/JKImagePicker) 
and [mwaterfall/MWPhotoBrowser](https://github.com/mwaterfall/MWPhotoBrowser) gave a me great help!

