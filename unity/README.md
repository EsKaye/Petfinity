# Unity Integration

This folder hosts the VRChat-ready Unity scripts for Petfinity.  The
`LilybearOpsBus` enables cross-guardian messaging, with sample guardians under
`Assets/GameDinVR/Scripts/Guardians`.

An optional `OSCTextBridge` component listens for `/osc` traffic (relayed by
Serafina) and updates in-world text elements so guardians can react to Discord
events.

See [Serafina](../serafina/README.md) for the Discord layer that can drive these
interactions and the shared [Inter-Repo Handshake](../INTER_REPO_HANDSHAKE.md)
spec for cross-repo discovery. Project-wide context is documented in the root
[README](../README.md) and [LAUNCH_CHECKLIST](../LAUNCH_CHECKLIST.md).

## Usage

1. Add the scripts in `Assets/GameDinVR/Scripts` to a Unity project.
2. Place `LilybearOpsBus` in the scene.
3. Attach guardian components to empty GameObjects and press *Play* to observe
   log chatter.
4. (Optional) Add `OSCTextBridge` to a GameObject with a `TextMesh` to display
   condensed council reports sent from Serafina.
