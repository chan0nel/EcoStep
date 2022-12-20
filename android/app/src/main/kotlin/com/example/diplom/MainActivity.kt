package com.example.diplom

import com.yandex.mapkit.MapKitFactory;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;


class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    MapKitFactory.setApiKey("f9146513-4739-4a0a-9546-52727633b82e"); // Your generated API key
    super.configureFlutterEngine(flutterEngine);
  }
}
