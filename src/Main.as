// c 2024-03-03
// m 2024-03-04

string       myName;
const string title = "\\$97F" + Icons::Flag + "\\$G Current Checkpoint Time";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

void Main() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    myName = App.LocalPlayerInfo.Name;
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);

    if (
        App.RootMap is null
        || Playground is null
        || Playground.GameTerminals.Length == 0
        || Playground.GameTerminals[0] is null
    )
        return;

    CSmPlayer@ Player = cast<CSmPlayer@>(Playground.GameTerminals[0].GUIPlayer);
    if (Player is null)
        return;

    CSmScriptPlayer@ ScriptPlayer = cast<CSmScriptPlayer@>(Player.ScriptAPI);
    if (ScriptPlayer is null)
        return;

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData = MLFeed::GetRaceData_V4();
    if (raceData is null)
        return;

    const MLFeed::PlayerCpInfo@ cpInfo = raceData.GetPlayer_V2(myName);
    if (cpInfo is null)
        return;

    int curCpTime = Math::Max(0, ScriptPlayer.CurrentRaceTime - cpInfo.lastCpTime);

    UI::Begin(title, S_Enabled, UI::WindowFlags::None);
        UI::Text(Time::Format(curCpTime));
    UI::End();
}