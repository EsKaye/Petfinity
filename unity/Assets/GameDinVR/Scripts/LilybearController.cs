using UnityEngine;

/// <summary>
/// Lilybear - the voice & operations guardian.
/// Routes commands and logs them.
/// </summary>
public class LilybearController : GuardianBase {
    [TextArea] public string LastMessage;

    void Start() {
        GuardianName = "Lilybear";
        Role = "Voice & Operations";
    }

    public override void OnMessage(string from, string message) {
        LastMessage = $"{from}: {message}"; // display latest message for debugging

        // Simple command: /route <payload> broadcasts to all guardians
        if (message.StartsWith("/route ")) {
            var payload = message.Substring(7);
            Whisper("*", payload); // broadcast
        }
    }

    // Handy context menu test
    [ContextMenu("Test Whisper")]
    void TestWhisper() {
        Whisper("*", "The council is assembled.");
    }
}
