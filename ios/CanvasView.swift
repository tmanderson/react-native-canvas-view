class CanvasPath: NSObject {
  var color:UIColor = UIColor.black;
  var width:Int = 1;
  var points:[CGPoint] = [];

  init(with point:CGPoint, and color:UIColor?) {
    if color != nil {
      self.color = color!;
    }

    points.append(point);
  }

  init(with color:UIColor, width:Int, points:Array<Array<Double>>) {
    self.color = color;
    self.width = width;
    for point:Array in points {
      let x = point[0] as Double;
      let y = point[1] as Double;
      self.points.append(CGPoint(x: x, y: y));
    }
  }

  init(with points:Array<Array<Double>>) {
    for point:Array in points {
      let x = point[0] as Double;
      let y = point[1] as Double;
      self.points.append(CGPoint(x: x, y: y));
    }
  }

  func add(point:CGPoint) {
    points.append(point)
  }
}

@objc(CanvasView)
class CanvasView : UIView {
  var id:Int = 0;
  var active = true;
  var drawing = false;
  var strokeColor:UIColor = UIColor.black;
  var strokeWidth:Int = 1;

  var paths:[CanvasPath] = [];
  var path:CanvasPath?;

  @objc override init(frame: CGRect) {
    super.init(frame: frame);
  }

  @objc required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  func undo() {
    paths.remove(at: paths.count - 1);
    self.setNeedsDisplay();
  }

  @objc func getSnapshot() -> UIImage {
    UIGraphicsBeginImageContext(frame.size);
    layer.render(in: UIGraphicsGetCurrentContext()!);
    let image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

    return image!;
  }

  override func draw(_ rect: CGRect) {
    let ctx:CGContext = UIGraphicsGetCurrentContext()!;
    ctx.setFillColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor);
    ctx.fill(rect);

    for path:CanvasPath in paths {
      ctx.beginPath();
      ctx.setLineWidth(CGFloat(path.width));
      ctx.setStrokeColor(path.color.cgColor);
      for (i, point) in path.points.enumerated() {
        if i == 0 {
          ctx.move(to: point);
        } else {
          ctx.addLine(to: point);
        }
      }
      ctx.strokePath();
    }

    if path != nil {
      ctx.beginPath();
      ctx.setLineWidth(CGFloat(path!.width));
      ctx.setStrokeColor(path!.color.cgColor);
      for (i, point) in path!.points.enumerated() {
        if i == 0 {
          ctx.move(to: point);
        } else {
          ctx.addLine(to: point);
        }
      }
      ctx.strokePath();
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !active {
      return;
    }

    drawing = true;

    if let touch:UITouch = touches.first {
      if #available(iOS 9.1, *) {
        path = CanvasPath.init(with: touch.preciseLocation(in: self), and: strokeColor);
      } else {
        path = CanvasPath.init(with: touch.location(in: self), and: strokeColor);
      };

      path!.width = strokeWidth;

      self.setNeedsDisplay(self.bounds);
    }

  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (drawing != false) {
      if let touch:UITouch = touches.first {
        if #available(iOS 9.1, *) {
          path!.add(point: touch.preciseLocation(in: self));
        } else {
          path!.add(point: touch.location(in: self));
        };
        self.setNeedsDisplay(self.bounds);
      }
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !active {
      return;
    }

    drawing = false;

    if #available(iOS 9.1, *) {
      path!.add(point: touches.first!.preciseLocation(in: self));
    } else {
      path!.add(point: touches.first!.location(in: self));
    };
    paths.append(path!);
    self.setNeedsDisplay(self.bounds);
  }
}
