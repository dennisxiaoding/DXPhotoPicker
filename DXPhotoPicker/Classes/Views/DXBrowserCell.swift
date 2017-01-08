//
//  DXBrowserCell.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/14.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

@available(iOS 8.0, *)
class DXBrowserCell: UICollectionViewCell, UIScrollViewDelegate, DXTapDetectingImageViewDelegate {
    
    // MARK: properties
    
    weak var photoBrowser: DXPhotoBrowser?
    var asset: PHAsset? {
        didSet {
            displayImage()
        }
    }
    
    private var requestID: PHImageRequestID?
    
    private lazy var zoomingScrollView: UIScrollView = {
        let scroll = UIScrollView(frame: CGRect(x: 10, y: 0, width: self.dx_width - 20, height: self.dx_height))
        scroll.delegate = self
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.decelerationRate = UIScrollViewDecelerationRateFast
        return scroll
    }()
    
    private lazy var photoImageView: DXTapDetectingImageView = {
        let imageView = DXTapDetectingImageView(frame: CGRect.zero)
        imageView.tapDelegate = self
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        return imageView
    }()
    
    // MARK: life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        if requestID != nil {
            PHImageManager.default().cancelImageRequest(requestID!)
            requestID = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Center the image as it becomes smaller than the size of the screen
        photoImageView.center = CGPoint(x: self.zoomingScrollView.dx_width/2, y: self.zoomingScrollView.dx_height/2)
        
        // Center the image as it becomes smaller than the size of the screen
        let boundsSize = zoomingScrollView.dx_size
        var frameToCenter = photoImageView.frame
        
        // Horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0);
        } else {
            frameToCenter.origin.x = 0;
        }
        
        // Vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0);
        } else {
            frameToCenter.origin.y = 0;
        }
        
        // Center
        if (!photoImageView.frame.equalTo(frameToCenter)) {
            photoImageView.frame = frameToCenter;
        }
    }
    
    // MARK: priviate
    
    private func setupView() {
        contentView.addSubview(zoomingScrollView)
        zoomingScrollView.addSubview(photoImageView)
    }
    
    private func displayImage() {
        zoomingScrollView.maximumZoomScale = 1
        zoomingScrollView.minimumZoomScale = 1;
        zoomingScrollView.zoomScale = 1
        zoomingScrollView.contentSize = CGSize(width: 0, height: 0);
        photoImageView.frame = zoomingScrollView.bounds
        requestID = DXPickerHelper.fetchImage(viaAsset:asset,
                                              targetSize: zoomingScrollView.dx_size,
                                              needHighQuality: true,
                                              imageResultHandler: { [unowned self](image) -> Void in
            self.requestID = nil
            guard image != nil else {
                return
            }
            self.photoImageView.image = image
            self.photoImageView.isHidden = false
            var photoImageViewFrame = CGRect.zero
            photoImageViewFrame.origin = CGPoint.zero
            photoImageViewFrame.size = image!.size;
            self.photoImageView.frame = photoImageViewFrame;
            self.zoomingScrollView.contentSize = photoImageViewFrame.size;
            // Set zoom to minimum zoom
            self.setMaxMinZoomScalesForCurrentBounds()
            self.setNeedsLayout()
            })
    }
    
    private func setMaxMinZoomScalesForCurrentBounds() {
        // reset
        zoomingScrollView.maximumZoomScale = 1
        zoomingScrollView.minimumZoomScale = 1
        zoomingScrollView.zoomScale = 1
        guard photoImageView.image != nil else { return }
        // rest position
        photoImageView.frame = CGRect(x: 0, y: 0, width: photoImageView.dx_width, height: photoImageView.dx_height)
        // caculate the Min
        let boundSize = zoomingScrollView.bounds.size
        let imageSize = photoImageView.image!.size
        let xScale = boundSize.width / imageSize.width      // the scale needed to perfectly fit the image width-wise
        let yScale = boundSize.height / imageSize.height    // the scale needed to perfectly fit the image height-wise
        var minScale = min(xScale, yScale)                  // use minimum of these to allow the image to become fully visible
        // caculate Max
        var maxScale: CGFloat = 1.5
        if UI_USER_INTERFACE_IDIOM() == .pad {
            maxScale = 3
        }
        // Image is smaller than screen so no zooming!
        if (xScale >= 1 && yScale >= 1) {
            minScale = 1.0
        }
        // Set min/max zoom
        zoomingScrollView.maximumZoomScale = maxScale
        zoomingScrollView.minimumZoomScale = minScale
        // Initial zoom
        zoomingScrollView.zoomScale = initialZoomScaleWithMinScale()
    
        // If we're zooming to fill then centralise
        if (zoomingScrollView.zoomScale != minScale) {
            // Centralise
            zoomingScrollView.contentOffset = CGPoint(x: (imageSize.width * zoomingScrollView.zoomScale - boundSize.width) / 2.0,
                                                      y: (imageSize.height * self.zoomingScrollView.zoomScale - boundSize.height) / 2.0)
            // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
            self.zoomingScrollView.isScrollEnabled = false
        }
        // Layout
        setNeedsLayout()
    }
    
    private func initialZoomScaleWithMinScale() -> CGFloat {
        var zoomScale = zoomingScrollView.minimumZoomScale
        // Zoom image to fill if the aspect ratios are fairly similar
        let boundsSize = zoomingScrollView.bounds.size
        let imageSize = photoImageView.image!.size
        let boundsAR = boundsSize.width / boundsSize.height
        let imageAR = imageSize.width / imageSize.height
        let xScale = boundsSize.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (abs(boundsAR - imageAR) < 0.17) {
            zoomScale = max(xScale, yScale)
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = min(max(self.zoomingScrollView.minimumZoomScale, zoomScale), self.zoomingScrollView.maximumZoomScale)
        }
        return zoomScale
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        zoomingScrollView.isScrollEnabled = true
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: DXTapDetectingImageView
    
    func imageView(_ imageView: DXTapDetectingImageView?, singleTapDetected touch: UITouch?) {
        func handleSingleTap(touchPoint: CGPoint) {
            guard photoBrowser != nil else {
                return
            }
            photoBrowser?.perform(#selector(DXPhotoBrowser.toggleControls), with: nil, afterDelay: 0.2)
        }
        
        guard touch != nil else {
            DXLog("touch error")
            return
        }
        handleSingleTap(touchPoint: touch!.location(in: imageView))
    }
    
    func imageView(_ imageView: DXTapDetectingImageView?, doubleTapDetected touch: UITouch?) {
    
        func handleDoubleTap(touchPoint: CGPoint) {
            guard photoBrowser != nil else {
                return
            }
            NSObject.cancelPreviousPerformRequests(withTarget: photoBrowser!)
            if (zoomingScrollView.zoomScale != zoomingScrollView.minimumZoomScale && zoomingScrollView.zoomScale != initialZoomScaleWithMinScale()) {
                zoomingScrollView.setZoomScale(zoomingScrollView.minimumZoomScale, animated: true)
            } else {
                let newZoomScale = (zoomingScrollView.maximumZoomScale + zoomingScrollView.minimumZoomScale) / 2
                let xsize = zoomingScrollView.dx_width / newZoomScale
                let ysize = zoomingScrollView.dx_height / newZoomScale
                zoomingScrollView.zoom(to: CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y - ysize/2, width: xsize, height: ysize), animated: true)
            }
        }
        guard touch != nil else {
            DXLog("touch error")
            return
        }
        handleDoubleTap(touchPoint: touch!.location(in: imageView))
    }
    
}
