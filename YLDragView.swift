//
//  YLDragView.swift
//  Driver
//
//  Created by ym on 2020/11/23.
//

import UIKit

enum YLDragDirection {
    case All
    case Horizontal
    case Vertical
}

typealias YLDragViewBlock = (_ drageView: YLDragView) -> Void;

class YLDragView: UIView {
    public var clickDragViewBlock: YLDragViewBlock?;
    public var beginDragBlock: YLDragViewBlock?;
    public var duringDragBlock: YLDragViewBlock?;
    public var endDragBlock: YLDragViewBlock?;
    /**
     是不是能拖曳，默认为YES
     YES，能拖曳
     NO，不能拖曳
     */
    public var dragEnable: Bool = true;
    
    /**
     活动范围，默认为父视图的frame范围内（因为拖出父视图后无法点击，也没意义）
     如果设置了，则会在给定的范围内活动
     如果没设置，则会在父视图范围内活动
     注意：设置的frame不要大于父视图范围
     注意：设置的frame为0，0，0，0表示活动的范围为默认的父视图frame，如果想要不能活动，请设置dragEnable这个属性为NO
     */
    public var freeRect: CGRect = .zero;
    
    /**
     拖曳的方向，默认为any，任意方向
     */
    public var dragDirection: YLDragDirection = .All;
    
    /**
     是否自动黏贴边界，默认为YES,
     */
    public var isKeepBounds: Bool = true;
    
    /**
    起点
     */
    private var startPoint: CGPoint!;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.layer.cornerRadius = frame.size.height/2.0;
        self.layer.masksToBounds = true;
        self.backgroundColor = UIColor.clear;
        self.clipsToBounds = true;
        self.setUp();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if (newSuperview != nil) {
            if self.freeRect == .zero {
                self.freeRect = newSuperview!.bounds;
            }
            self.keepBounds();
        }
    }
    
    func setUp() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.clickDragView));
        self.addGestureRecognizer(tap);
        
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(pan:)));
        panGesture.minimumNumberOfTouches = 1;
        panGesture.maximumNumberOfTouches = 1;
        self.addGestureRecognizer(panGesture);
    }
    
    @objc func clickDragView() {
        if self.clickDragViewBlock != nil {
            self.clickDragViewBlock!(self);
        }
    }
    
    @objc func panAction(pan: UIPanGestureRecognizer) {
        if self.dragEnable == false {
            return;
        }
        switch pan.state {
        case .began:
            if self.beginDragBlock != nil {
                self.beginDragBlock!(self);
            }
            //注意完成移动后，将translation重置为0十分重要。否则translation每次都会叠加
            pan.setTranslation(.zero, in: self);
            //保存触摸起始点位置
            self.startPoint = pan.translation(in: self);
            break;
        case .changed:
            if self.duringDragBlock != nil {
                self.duringDragBlock!(self);
            }
            let point:CGPoint = pan.translation(in: self);
            var dx: CGFloat = 0;
            var dy: CGFloat = 0;
            switch self.dragDirection {
            case .All:
                dx = point.x - self.startPoint.x;
                dy = point.y - self.startPoint.y;
                break;
            case .Horizontal:
                dx = point.x - self.startPoint.x;
                dy = 0;
                break;
            case .Vertical:
                dx = 0;
                dy = point.y - self.startPoint.y;
                break;
            }
            
            //计算移动后的view中心点
            let newCenter: CGPoint = CGPoint(x: self.center.x + dx, y: self.center.y + dy);
            //移动view
            self.center = newCenter;
            //  注意完成上述移动后，将translation重置为0十分重要。否则translation每次都会叠加
            pan.setTranslation(.zero, in: self);
            break;
        case .ended:
            self.keepBounds();
            if self.endDragBlock != nil {
                self.endDragBlock!(self);
            }
            break;
        default:
            break;
        }
    }
    
    func keepBounds() {
        //中心点判断
        let centerX: CGFloat = CGFloat(freeRect.origin.x+(freeRect.size.width - self.frame.size.width)/2);
        var rect: CGRect = self.frame;
        if self.isKeepBounds == false {
            if (self.frame.origin.x < self.freeRect.origin.x) {
                UIView.beginAnimations("leftMove", context: nil);
                UIView.setAnimationCurve(.easeInOut);
                UIView.setAnimationDuration(0.5);
                rect.origin.x = freeRect.origin.x;
                self.frame = rect;
                UIView.commitAnimations();
            } else if(freeRect.origin.x+freeRect.size.width < self.frame.origin.x+self.frame.size.width) {
                UIView.beginAnimations("rightMove", context: nil);
                UIView.setAnimationCurve(.easeInOut);
                UIView.setAnimationDuration(0.5);
                rect.origin.x = freeRect.origin.x+freeRect.size.width-self.frame.size.width;
                self.frame = rect;
                UIView.commitAnimations();
            }
        } else {
            if (self.frame.origin.x < centerX) {
                UIView.beginAnimations("leftMove", context: nil);
                UIView.setAnimationCurve(.easeInOut);
                UIView.setAnimationDuration(0.5);
                rect.origin.x = freeRect.origin.x;
                self.frame = rect;
                UIView.commitAnimations();
            } else {
                UIView.beginAnimations("rightMove", context: nil);
                UIView.setAnimationCurve(.easeInOut);
                UIView.setAnimationDuration(0.5);
                rect.origin.x = freeRect.origin.x+freeRect.size.width - self.frame.size.width;
                self.frame = rect;
                UIView.commitAnimations();
            }
        }
        
        if (self.frame.origin.y < freeRect.origin.y) {
            UIView.beginAnimations("topMove", context: nil);
            UIView.setAnimationCurve(.easeInOut);
            UIView.setAnimationDuration(0.5);
            rect.origin.y = freeRect.origin.y;
            self.frame = rect;
            UIView.commitAnimations();
        } else if(freeRect.origin.y+freeRect.size.height < self.frame.origin.y+self.frame.size.height) {
            UIView.beginAnimations("bottomMove", context: nil);
            UIView.setAnimationCurve(.easeInOut);
            UIView.setAnimationDuration(0.5);
            rect.origin.y = freeRect.origin.y+freeRect.size.height-self.frame.size.height;
            self.frame = rect;
            UIView.commitAnimations();
        }
    }
}
