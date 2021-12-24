import Flutter
import UIKit

public class SwiftHttpSessionPlugin: NSObject, FlutterPlugin {

    var session: Session?

    public static func register(with registrar: FlutterPluginRegistrar) {
        session = Session()
        let channel = FlutterMethodChannel(name: "http_session", binaryMessenger: registrar.messenger())
        let instance = SwiftHttpSessionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "post" {
            guard let args = call.arguments as? [String:Any] else {
                result(FlutterError(code: "-1", message: "no args", details: nil))
                return
            }
            let url: String = args["url"] as! String
            let dataString: String  = args["data"] as! String
            let data: [String:String] = self.convertToDictionary(text: dataString) ?? [String:String]()
            self.session!.post(url: url, data: data) { response in
                result(response)
            }
        }
        else if call.method == "get" {
            guard let args = call.arguments as? [String:Any] else {
                result(FlutterError(code: "-1", message: "no args", details: nil))
                return
            }
            let url: String = args["url"] as! String
            self.session!.get(url: url) { response in
                result(response)
            }
        }
        else if call.method == "multipart" {
            guard let args = call.arguments as? [String:Any] else {
                result(FlutterError(code: "-1", message: "no args", details: nil))
                return
            }
            let url: String = args["url"] as! String
            let fileFieldName: String = args["fileFieldName"] as! String
            let fileUrl: String = args["fileUrl"] as! String
            let dataString: String  = args["data"] as! String
            let data: [String:String] = self.convertToDictionary(text: dataString) ?? [String:String]()
            self.session!.multiPartRequest(url: url, fileFieldName: fileFieldName, fileUrl: fileUrl, data: data) { response in
                result(response)
            }
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }
}
