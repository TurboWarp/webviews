package org.turbowarp.packager.demo

import android.annotation.SuppressLint
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.webkit.WebView

class MainActivity : AppCompatActivity() {
    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val web = WebView(this);
        web.settings.javaScriptEnabled = true;
        web.loadUrl("file:///android_asset/project.html")
        setContentView(web)
    }
}
