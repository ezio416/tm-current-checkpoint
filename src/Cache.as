// c 2024-04-01
// m 2024-04-08

void CacheLocalLogin() {
    while (true) {
        sleep(101);

        localLogin = GetLocalLogin();
        if (localLogin.Length > 10)
            break;
    }
}

void CacheLocalName() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (true) {
        sleep(103);

        if (App.LocalPlayerInfo is null)
            continue;

        localName = App.LocalPlayerInfo.Name;
        if (localName.Length == 0)
            continue;

        break;
    }
}
