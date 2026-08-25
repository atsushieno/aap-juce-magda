package org.androidaudioplugin.juce

import android.content.Context
import androidx.startup.Initializer
import java.io.File

class JuceAppInitializer : Initializer<Unit> {
    override fun create(context: Context) {
        copyLanguageAssets(context)
        com.rmsl.juce.Java.initialiseJUCE(context.applicationContext)
    }

    private fun copyLanguageAssets(context: Context) {
        val destination = File(context.applicationInfo.dataDir, "MAGDA/lang")
        destination.mkdirs()
        for (name in context.assets.list("") ?: emptyArray()) {
            if (name.endsWith(".json"))
                context.assets.open(name).use { input ->
                    File(destination, name).outputStream().use { output -> input.copyTo(output) }
                }
        }
    }

    override fun dependencies(): MutableList<Class<out Initializer<*>>> = mutableListOf()
}
