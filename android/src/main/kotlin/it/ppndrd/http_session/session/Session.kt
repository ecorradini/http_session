package it.ppndrd.http_session.session

import android.content.Context
import com.android.volley.DefaultRetryPolicy
import com.android.volley.Request
import com.android.volley.RequestQueue
import com.android.volley.toolbox.Volley
import java.io.File
import java.net.CookieHandler
import java.net.CookieManager
import java.util.HashMap

class Session(private val context: Context) {
    private var session: RequestQueue = Volley.newRequestQueue(this.context)

    init {
        session = Volley.newRequestQueue(context)
        val cookieManager = CookieManager()
        CookieHandler.setDefault(cookieManager)
    }

    fun get(url: String, result: (String)->Unit) {
        val request = StringRequest(
            Request.Method.GET,
            url,
            HashMap(),
            { result(it) },
            { result("") }
        )
        session.add(request)
    }

    fun post(url: String, data: HashMap<String, String>, result: (String)->Unit) {
        val request = StringRequest(
            Request.Method.POST,
            url,
            data,
            { result(it) },
            { result("") }
        )
        request.retryPolicy = DefaultRetryPolicy(
            DefaultRetryPolicy.DEFAULT_TIMEOUT_MS * 10,
            DefaultRetryPolicy.DEFAULT_MAX_RETRIES,
            DefaultRetryPolicy.DEFAULT_BACKOFF_MULT
        )
        request.setShouldCache(false)
        session.add(request)
    }

    fun multiPartRequest(url: String, fileFieldName: String, fileUrl: String, data: HashMap<String, String>, result: (String)->Unit) {
        val img = File(fileUrl)
        if (img.exists()) {
            val multipartRequest = MultipartRequest(url, { result("") }, { result(it) }, img, data, fileFieldName)
            multipartRequest.retryPolicy = DefaultRetryPolicy(
                0,
                DefaultRetryPolicy.DEFAULT_MAX_RETRIES,
                DefaultRetryPolicy.DEFAULT_BACKOFF_MULT
            )
            session.add(multipartRequest)
        } else {
            result("")
        }
    }
}