using UnityEngine;

/// <summary>
/// Serafina - communications & routing guardian.
/// </summary>
public class SerafinaGuardian : GuardianBase {
    void Start() {
        GuardianName = "Serafina";
        Role = "Comms & Routing";
    }

    public override void OnMessage(string from, string message) {
        if (message.StartsWith("bless")) {
            Whisper("ShadowFlowers", "Please deliver a blessing to the hall.");
        }
    }
}
