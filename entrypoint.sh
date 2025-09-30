app_update() {
    steamcmd \
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
ServerPassword="${ServerPassword:-password}"
SteamServerName="${SteamServerName:-LinuxServer}"
WorldSaveName="${WorldSaveName:-Cascade}"
AdditionalArgs="${AdditionalArgs:-}"

# Check for updates/perform initial installation
if [ ! -d "/server/AbioticFactor/Binaries/Win64" ] || [[ $AutoUpdate == "true" ]]; then
    app_update | tee /tmp/app_update.log
    grep -q "state is 0x6" /tmp/app_update.log
    if [ $? -eq 0 ]; then
        echo "Update failed with 'state is 0x6', wiping server files and retrying (your saved games will be preserved)"
        find /server/* -not -path "/server/AbioticFactor/Saved*" -not -path "/server/AbioticFactor" -delete
        app_update
    fi
fi

pushd /server/AbioticFactor/Binaries/Win64 > /dev/null
wine AbioticFactorServer-Win64-Shipping.exe $SetUsePerfThreads$SetNoAsyncLoadingThread-MaxServerPlayers=$MaxServerPlayers \
    -PORT=$Port -QueryPort=$QueryPort -ServerPassword=$ServerPassword \
    -SteamServerName="$SteamServerName" -WorldSaveName="$WorldSaveName" -tcp $AdditionalArgs
popd > /dev/null
