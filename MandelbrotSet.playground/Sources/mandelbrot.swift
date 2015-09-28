import UIKit

let resolution = 400
let iteration = 300

struct vec2{
  var x: Double
  var y: Double
 
  func length() -> Double{
   return sqrt(pow(x,2)+pow(y,2))
  }
}

func + (left:vec2,right:vec2) -> vec2{
  return vec2(x:(left.x + right.x),y:(left.y + right.y))
}

struct Result{
  var div: Bool//発散したかどうか
  var elapsed: Int?//発散した場合の計算回数
}

/// 結果格納クラス
public class ResultArray{
  var array: [Result]
  init(){
    self.array = Array(
      count:resolution * resolution,
      repeatedValue:Result(div: false,elapsed: nil)
    )
  }
 
  func indexIsValid(x:Int,y:Int)->Bool{
    return x>=0 && x<resolution && y>=0 && y<resolution
  }
  
  subscript(x:Int,y:Int) -> Result{
    get{
      assert(indexIsValid(x, y:y))
      return array[x * resolution + y]
    }
    set{
      assert(indexIsValid(x, y:y))
      array[x * resolution + y] = newValue
    }
  }
}

/// 複素数座標上の発散を計算
/// - parameter c :複素数座標
/// - returns: 発散の計算結果
func calcDiv(c:vec2) -> Result{
  var result:Result = Result(div:false,elapsed:nil)
  var z = vec2(x:0.0,y:0.0)
  for i in 0..<iteration{
    let nz = vec2(
      x: pow(z.x,2.0) - pow(z.y,2.0),
      y: 2.0 * z.x * z.y
    )
    z = nz + c
    if z.length() > 2.0{
      result = Result(div: true, elapsed: i)
      break
    }
  }
  return result
}

/// マンデルブロ集合の計算
/// - returns: 計算結果
public func calc() -> ResultArray{
  let result=ResultArray()
  for i in 0..<resolution{
    for j in 0..<resolution{
      let c = vec2(
        x: Double(i)/Double(resolution)*4.0-2.0,
        y: (Double(j)/Double(resolution)*4.0-2.0) * (-1)
      )
      result[i,j] = calcDiv(c)
    }
  }
  return result
}

/// マンデルブロ集合の描画
/// - parameters result: 計算結果
/// - returns : 描画データ
public func draw(result:ResultArray) -> UIView{
  let size = CGSize(width: resolution, height: resolution)
  let view = UIView(frame: CGRect(origin:CGPointZero, size: size))
  view.backgroundColor=UIColor(white:0.9,alpha:1.0)
  UIGraphicsBeginImageContextWithOptions(size, false,0)
  for i in 0..<resolution{
    for j in 0..<resolution{
      let rect = CGRectMake(CGFloat(i * 1), CGFloat(j * 1), 1, 1)
      let component: [CGFloat] = {
        if(result[i,j].div){
          let e: CGFloat = CGFloat(Float(result[i,j].elapsed!)*2.0/Float(iteration))
          return [1.0,1.0-e,1.0-e,1.0]
        }else{
          return [0.0,0.0,0.0,1.0]
        }
      }()
      let color = CGColorCreate(CGColorSpaceCreateDeviceRGB(), component)!
      UIColor(CGColor: color).setFill()
      UIRectFill(rect)
    }
  }
  let image = UIGraphicsGetImageFromCurrentImageContext().CGImage
  view.layer.contents = image
  return view
}