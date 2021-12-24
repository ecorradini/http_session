package it.ppndrd.http_session

import androidx.annotation.NonNull
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import it.ppndrd.http_session.session.Session

/** HttpSessionPlugin */
class HttpSessionPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var session: Session? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "http_session")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }
    else if(call.method == "post") {
      val url: String = call.argument("url")!!
      val dataString: String = call.argument("data")!!
      val data: Map<String, String> = Gson().fromJson(
        dataString, object : TypeToken<HashMap<String?, Any?>?>() {}.type
      )
      session!!.post(url, HashMap(data)) { response ->
        if(response != "") {
          result.success(response);
        }
        else {
          result.error("UNAVAILABLE", "Response not available.", null)
        }
      }
    }
    else if(call.method == "get") {
      val url: String = call.argument("url")!!
      session!!.get(url) { response ->
        if(response != "") {
          result.success(response);
        }
        else {
          result.error("UNAVAILABLE", "Response not available.", null)
        }
      }
    }
    else if(call.method == "multipart") {
      val url: String = call.argument("url")!!
      val fileFieldName: String = call.argument("fileFieldName")!!
      val fileUrl: String = call.argument("fileUrl")!!
      val dataString: String = call.argument("data")!!
      val data: Map<String, String> = Gson().fromJson(
        dataString, object : TypeToken<HashMap<String?, Any?>?>() {}.type
      )
      session!!.multiPartRequest(url, fileFieldName, fileUrl, HashMap(data)) { response ->
        if(response != "") {
          result.success(response);
        }
        else {
          result.error("UNAVAILABLE", "Response not available.", null)
        }
      }
    }
    else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
