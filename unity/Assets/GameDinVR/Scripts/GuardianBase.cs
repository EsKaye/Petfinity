using UnityEngine;

/// <summary>
/// Base class for all guardians to handle Lilybear bus whispers.
/// </summary>
public class GuardianBase : MonoBehaviour {
    [Header("Identity")] public string GuardianName = "Guardian";
    [Header("Role")] public string Role = "Undefined";

    protected virtual void OnEnable() {
        if (LilybearOpsBus.I != null) LilybearOpsBus.I.OnWhisper += HandleWhisper;
    }

    protected virtual void OnDisable() {
        if (LilybearOpsBus.I != null) LilybearOpsBus.I.OnWhisper -= HandleWhisper;
    }

    protected virtual void HandleWhisper(string from, string to, string message) {
        if (to == GuardianName || to == "*") {
            Debug.Log($"[{GuardianName}] received from {from}: {message}");
            OnMessage(from, message);
        }
    }

    public virtual void OnMessage(string from, string message) {}

    protected void Whisper(string to, string message) {
        LilybearOpsBus.I?.Say(GuardianName, to, message);
    }
}
