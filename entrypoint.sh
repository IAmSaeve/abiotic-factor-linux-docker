#!/bin/bash

# Ensure errors are caught and halts script execution
# See this overview for an explanation:
# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425
set -euxo pipefail

app_update() {
    # steamcmd is installed to the "steam" users home
    # https://github.com/CM2Walki/steamcmd?tab=readme-ov-file#how-to-use-this-image
    ./steamcmd.sh \
    +@NoPromptForPassword 1 \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir /server \
    +login anonymous \
    +app_update 2857200 validate \
    +quit
}

SetUsePerfThreads="-useperfthreads "
if [[ $UsePerfThreads == "false" ]]; then
    SetUsePerfThreads=""
fi

SetNoAsyncLoadingThread="-NoAsyncLoadingThread "
if [[ $NoAsyncLoadingThread == "false" ]]; then
    SetNoAsyncLoadingThread=""
fi

MaxServerPlayers="${MaxServerPlayers:-6}"
Port="${Port:-7777}"
QueryPort="${QueryPort:-27015}"
ServerPassword="${ServerPassword:-ChangeThisPasswordPlease}"
SteamServerName="${SteamServerName:-LinuxServer}"
WorldSaveName="${WorldSaveName:-MyWorldSave}"
AdditionalArgs="${AdditionalArgs:-}"
AutoUpdate="${AutoUpdate:-"false"}"

# Check for updates/perform initial installation
if [ ! -d "/server/AbioticFactor/Binaries/Win64" ] || [[ $AutoUpdate == "true" ]]; then
    app_update | tee /tmp/app_update.log

    if grep -q "state is 0x6" /tmp/app_update.log; then
        echo "Update failed with 'state is 0x6', wiping server files and retrying (your saved games will be preserved)"
        find /server/* -not -path "/server/AbioticFactor/Saved*" -not -path "/server/AbioticFactor" -delete
        app_update
    fi
fi

pushd /server/AbioticFactor/Binaries/Win64 > /dev/null

wine AbioticFactorServer-Win64-Shipping.exe \
    $SetUsePerfThreads \
    $SetNoAsyncLoadingThread \
    -MaxServerPlayers=$MaxServerPlayers \
    -PORT=$Port \
    -QueryPort=$QueryPort \
    -ServerPassword=$ServerPassword \
    -SteamServerName="$SteamServerName" \
    -WorldSaveName="$WorldSaveName" \
    -tcp \
    $AdditionalArgs

popd > /dev/null
