#include <juce_events/juce_events.h>

#if JUCE_ANDROID
#include <jni.h>

extern "C" JNIEXPORT void JNICALL
Java_com_rmsl_juce_JuceActivity_appNewIntent(JNIEnv*, jobject, jobject) {}

extern "C" JNIEXPORT void JNICALL
Java_com_rmsl_juce_JuceActivity_appOnResume(JNIEnv*, jobject) {}
#endif

namespace juce {

#if JUCE_MODAL_LOOPS_PERMITTED
// JUCE declares this entry point only when modal loops are permitted.  Keep
// the compatibility implementation for desktop-style builds, but omit it on
// Android where the JUCE header deliberately removes the declaration.
bool MessageManager::runDispatchLoopUntil(int millisecondsToRunFor) {
    if (millisecondsToRunFor > 0)
        Thread::sleep(millisecondsToRunFor);
    return true;
}
#endif

} // namespace juce
