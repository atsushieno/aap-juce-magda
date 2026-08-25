// For binary compatibility with JUCE JNI, we have to name this class under
// this package.  MAGDA's CMake target contains the JUCE JNI implementation.
package com.rmsl.juce

import android.content.Context

class Java {
    companion object {
        init {
            System.loadLibrary("magda_daw_app")
        }

        @JvmStatic
        external fun initialiseJUCE(applicationContext: Context)
    }
}
