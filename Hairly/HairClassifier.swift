import CoreML
import Vision
import UIKit

class HairClassifier {
    static let shared = HairClassifier() // シングルトンインスタンス
    
    private var model: Hairly_ML_1?

    init() {
        do {
            let config = MLModelConfiguration()
            model = try Hairly_ML_1(configuration: config) // CoreMLモデルをロード
            print("✅ CoreMLモデルをロードしました: \(String(describing: model))") // 確認用ログ
        } catch {
            print("❌ CoreMLモデルのロードに失敗: \(error)")
        }
    }

    // 📌 画像を分類するメソッド
    func classify(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let model = model else {
            print("❌ モデルがロードされていません")
            completion(nil)
            return
        }

        guard let pixelBuffer = image.toCVPixelBuffer() else {
            print("❌ UIImage から PixelBuffer への変換に失敗")
            completion(nil)
            return
        }

        do {
            let prediction = try model.prediction(image: pixelBuffer)
            let result = prediction.target // 🔥 髪型のラベル
            print("✅ 認識結果: \(result)") // 確認用ログ
            completion(result)
        } catch {
            print("❌ 画像解析エラー: \(error.localizedDescription)")
            completion(nil)
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
