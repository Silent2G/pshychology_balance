package com.aipsychologybalance

import android.os.Bundle
import android.os.StrictMode
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Firebase Sessions SDK performs network I/O on its own background threads, which
        // triggers StrictMode NetworkViolation. Permit network while keeping disk checks.
        StrictMode.setThreadPolicy(
            StrictMode.ThreadPolicy.Builder()
                .detectDiskReads()
                .detectDiskWrites()
                .penaltyLog()
                .build()
        )
        super.onCreate(savedInstanceState)
    }
}
