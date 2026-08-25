#include <juce_events/juce_events.h>

#if JUCE_ANDROID
#include <jni.h>

extern "C" JNIEXPORT void JNICALL
Java_com_rmsl_juce_JuceActivity_appNewIntent(JNIEnv*, jobject, jobject) {}

extern "C" JNIEXPORT void JNICALL
Java_com_rmsl_juce_JuceActivity_appOnResume(JNIEnv*, jobject) {}
#endif

namespace juce {

// JUCE's Android message pump is driven by the Activity/Looper.  The modal
// APIs used by this GUI host still need this desktop-compatible entry point;
// Android dispatches messages through the normal looper while the caller is
// allowed to yield briefly.
bool MessageManager::runDispatchLoopUntil(int millisecondsToRunFor) {
    if (millisecondsToRunFor > 0)
        Thread::sleep(millisecondsToRunFor);
    return true;
}

} // namespace juce
