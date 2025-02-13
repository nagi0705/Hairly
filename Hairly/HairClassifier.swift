import CoreML
import Vision
import UIKit

class HairClassifier {
    static let shared = HairClassifier()
    
    private var model: Hairly_ML_1?
    
    init() {
        do {
            let config = MLModelConfiguration()
            model = try Hairly_ML_1(configuration: config)
            print("✅ CoreMLモデルをロードしました: \(String(describing: model))")
        } catch {
            print("❌ CoreMLモデルのロードに失敗: \(error)")
        }
    }
    
    // 📌 画像を分類するメソッド（確率分布のログ出力を追加）
    func classify(image: UIImage, completion: @escaping (String?, HairStyle?) -> Void) {
        guard let model = model else {
            print("❌ モデルがロードされていません")
            completion(nil, nil)
            return
        }
        
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            print("❌ UIImage から PixelBuffer への変換に失敗")
            completion(nil, nil)
            return
        }
        
        do {
            let prediction = try model.prediction(image: pixelBuffer)
            let result = prediction.target // 🔥 認識された髪型のラベル
            let probabilities = prediction.targetProbability // 🔥 髪型ごとの確率分布
            
            // 🔥 確率分布をログに出力
            print("✅ 認識結果: \(result)")
            print("📊 髪型の確率分布: \(probabilities)") // ← ここで各髪型の確率をチェック

            // 髪型の説明データを取得
            let hairStyleInfo = HairStyleManager.shared.getHairStyleInfo(for: result)
            
            completion(result, hairStyleInfo)
        } catch {
            print("❌ 画像解析エラー: \(error.localizedDescription)")
            completion(nil, nil)
        }
    }
}

// 📌 UIImage → CVPixelBuffer 変換用の拡張
extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let width = 299
        let height = 299
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32BGRA,
                                         attributes as CFDictionary,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: width, height: height,
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        guard let cgImage = self.cgImage else {
            CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
            return nil
        }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)

        return buffer
    }
}
