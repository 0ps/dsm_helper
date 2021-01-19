package fit.flutter.dsm_helper

import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine( flutterEngine:
                                         FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}