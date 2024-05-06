// c 2024-03-03
// m 2024-03-08

string       loginLocal;
string       myName;
const string title = "\\$97F" + Icons::Flag + "\\$G Current Checkpoint Time";

void Main() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    myName = App.LocalPlayerInfo.Name;

    startnew(CacheLocalLogin);

    ChangeFont();
}

void OnSettingsChanged() {
    if (currentFont != S_Font)
        ChangeFont();
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
        || Playground.GameTerminals[0].GUIPlayer is null
        || Playground.UIConfigs.Length == 0
        || Playground.UIConfigs[0] is null
        || Playground.UIConfigs[0].UISequence != CGamePlaygroundUIConfig::EUISequence::Playing
    )
        return;

    CSmPlayer@ ViewingPlayer = VehicleState::GetViewingPlayer();
    if (ViewingPlayer is null || ViewingPlayer.ScriptAPI.Login != loginLocal)
        return;

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData = MLFeed::GetRaceData_V4();
    if (raceData is null)
        return;

    const MLFeed::PlayerCpInfo_V2@ cpInfo = raceData.GetPlayer_V2(myName);
    if (cpInfo is null)
        return;

    if (!S_ShowNoCp) {
        uint totalCps = 0;

        for (uint i = 0; i < Playground.Arena.MapLandmarks.Length; i++) {
            CGameScriptMapLandmark@ Landmark = Playground.Arena.MapLandmarks[i];

            if (Landmark is null || Landmark.Waypoint is null || Landmark.Waypoint.IsFinish || Landmark.Waypoint.IsMultiLap)
                continue;

            totalCps++;
            break;
        }

        if (totalCps == 0)
            return;
    }

    if (cpInfo.cpCount == int(raceData.CPsToFinish))  // player finished
        return;

    const string text = Time::Format(Math::Max(0, cpInfo.CurrentRaceTimeRaw - cpInfo.lastCpTime));

    nvg::FontSize(S_FontSize);
    nvg::FontFace(font);
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);

    const vec2 size = nvg::TextBounds(text);

    const float posX = Draw::GetWidth() * S_X;
    const float posY = Draw::GetHeight() * S_Y;

    if (S_Background) {
        nvg::FillColor(S_BackgroundColor);
        nvg::BeginPath();
        nvg::RoundedRect(
            posX - size.x * 0.5f - S_BackgroundXPad,
            posY - size.y * 0.5f - S_BackgroundYPad - 2.0f,
            size.x + S_BackgroundXPad * 2.0f,
            size.y + S_BackgroundYPad * 2.0f,
            S_BackgroundRadius
        );
        nvg::Fill();
    }

    if (S_Drop) {
        nvg::FillColor(S_DropColor);
        nvg::Text(posX + S_DropOffset, posY + S_DropOffset, text);
    }

    nvg::FillColor(S_FontColor);
    nvg::Text(posX, posY, text);
}

// courtesy of "Auto-hide Opponents" plugin - https://github.com/XertroV/tm-autohide-opponents
void CacheLocalLogin() {
    while (true) {
        sleep(100);

        loginLocal = GetLocalLogin();

        if (loginLocal.Length > 10)
            break;
    }
}
