#!/usr/bin/env bash

# Anope provision script, written by Som
set -e
set -u

_author="Som / somsubhra1 [at] xshellz.com"
_package="Anope"
_version="1.8.9"

echo "Running provision for package $_package version: $_version by $_author"

cd ~

dir="anope-1.8.7"

if [ -d $dir ]
then
 echo "$dir is already present in $HOME. Aborting!"
 exit
fi

if pgrep services >/dev/null 2>&1
then
 echo "Anope is already running. Aborting installation!"
 exit 
fi

if pgrep unrealircd >/dev/null 2>&1
then
 echo "UnrealIRCd is running."
else
 echo "UnrealIRCd is not running currently. You need to start unrealIRCd first to install anope. Aborting!"
 exit
fi
wget http://ircd.zemra.org/anope/services/anope-1.8.9.tar.gz

tar xzvf anope-1.8.9.tar.gz

cd 'anope-1.8.9'

#Starting configuration

/usr/bin/expect - <<-EOF
spawn ./Config
set timeout 15
expect "In what directory do you want the binaries to be installed?"
send "\r"
expect "Where do you want the data files to be installed?"
send "\r"
expect "Which group should all Services data files be owned by?"
send "\r"
expect "What should the default umask for data files be (in octal)?"
send "\r"
expect "Allow anope to automatically check for mysql libraries?"
send "\r"
set timeout 240
expect -ex "$prompt"
expect eof
EOF

echo "Anope has been successfully configured. Continuing installation"

#Starting installation
make
make install
cd ~
cd services

echo "Anope Installed. Creating services.conf"

#Creation of conf file

cat << EOF > services.conf

# https://www.xshellz.com/

RemoteServer $serverip $port "$pass"

ServerName "$servername"
ServerDesc "$server services"

ServiceUser "$serviceshost"

HelpChannel "#help"
LogChannel "#services"

NetworkName "$server"

UserKey1 4856993
UserKey2 1928894
UserKey3 4394782

NSEnforcerUser enforcer@$serviceshost

ServicesRoot "$rootusers"


############ DO NOT EDIT ANYTHING BELOW THIS LINE ############
############ UNLESS YOU KNOW WHAT YOU ARE DOING ############

IRCDModule "unreal32"
EncModule "enc_none"

HostCoreModules "hs_help hs_on hs_off hs_group hs_list hs_set hs_setall hs_del hs_delall"
MemoCoreModules "ms_send ms_cancel ms_list ms_read ms_del ms_set ms_info ms_rsend ms_check ms_staff ms_sendall ms_help"
HelpCoreModules "he_help"
BotCoreModules "bs_help bs_botlist bs_assign bs_set bs_kick bs_badwords bs_act bs_info bs_say bs_unassign bs_bot bs_fantasy bs_fantasy_kick bs_fantasy_kickban bs_fantasy_owner bs_fantasy_seen"
OperCoreModules "os_help os_global os_stats os_oper os_admin os_staff os_mode os_kick os_clearmodes os_akill os_sgline os_sqline os_szline os_chanlist os_userlist os_logonnews os_randomnews os_opernews os_session os_noop os_jupe os_ignore os_set os_reload os_update os_restart os_quit os_shutdown os_defcon os_chankill os_svsnick os_oline os_umode os_modload os_modunload os_modlist os_modinfo"
NickCoreModules "ns_help ns_register ns_group ns_identify ns_access ns_set ns_saset ns_drop ns_recover ns_release ns_sendpass ns_ghost ns_alist ns_info ns_list ns_logout ns_status ns_update ns_getpass ns_getemail ns_forbid ns_suspend"
ChanCoreModules "cs_help cs_register cs_identify cs_set cs_xop cs_access cs_akick cs_drop cs_sendpass cs_ban cs_clear cs_modes cs_getkey cs_invite cs_kick cs_list cs_logout cs_topic cs_info cs_getpass cs_forbid cs_suspend cs_status"

NickServName "NickServ" "Nickname Server"
ChanServName "ChanServ" "Channel Server"
MemoServName "MemoServ" "Memo Server"
BotServName "BotServ" "Bot Server"
HelpServName "HelpServ" "Help Server"
OperServName "OperServ" "Operator Server"
GlobalName "Global" "Global Noticer"
HostServName	"HostServ" "vHost Server"

PIDFile services.pid
MOTDFile services.motd

NickServDB nick.db
PreNickServDB prenick.db
ChanServDB chan.db
BotServDB bot.db
OperServDB oper.db
NewsDB news.db
ExceptionDB exception.db
HostServDB hosts.db

NickLen 31

StrictPasswords
BadPassLimit 5
BadPassTimeout 1h
UpdateTimeout 5m
ExpireTimeout 30m
ReadTimeout 5s
WarningTimeout 4h
TimeoutCheck 3s
KeepLogs 7
KeepBackups 3
ForceForbidReason
HideStatsO
GlobalOnCycle
GlobalOnCycleMessage "Services are restarting - they will be back shortly"
GlobalOnCycleUP "Services are now back online - have a nice day"

UseSVSHOLD
UseSVS2MODE
UnRestrictSAdmin

#NSDefKill
#NSDefKillQuick
NSDefSecure
NSDefPrivate
NSDefHideEmail
NSDefHideUsermask
#NSDefHideQuit
#NSDefMsg
NSDefMemoSignon
NSDefMemoReceive
NSDefAutoop

NSDefLanguage 1
NSRegDelay 30s
NSResendDelay 90s
NSExpire 90d
NSMaxAliases 5
NSAccessMax 100
NSReleaseTimeout 1m
NSAllowKillImmed
NSListOpersOnly
NSListMax 50
NSGuestNickPrefix "Unknown"
NSSecureAdmins
NSStrictPrivileges
NSModeOnID
NSRestrictGetPass
NSNickTracking
NSAddAccessOnReg

CSDefKeepTopic
CSDefOpNotice
CSDefPeace
#CSDefPrivate
#CSDefRestricted
CSDefSecure
CSDefSecureOps
CSDefSecureFounder
CSDefSignKick
#CSDefSignKickLevel
#CSDefTopicLock
#CSDefXOP

CSMaxReg 20
CSExpire 14d
CSDefBantype 2
CSAccessMax 1024
CSAutokickMax 32
CSAutokickReason "User has been banned from the channel"
CSInhabit 15s
CSListOpersOnly
CSListMax 50
CSRestrictGetPass

MSMaxMemos 20
MSSendDelay 30s
MSNotifyAll

#BSDefDontKickOps
#BSDefDontKickVoices
BSDefGreet
BSDefFantasy
BSDefSymbiosis

BSMinUsers 1
BSBadWordsMax 32
BSKeepData 10m
BSSmartJoin
BSGentleBWReason
BSFantasyCharacter "!"

SuperAdmin
LogMaxUsers
AutoKillExpiry 30d
ChanKillExpiry 30d
SGLineExpiry 30d
SQLineExpiry 30d
SZLineExpiry 30d
AkillOnAdd
KillOnSGline
KillOnSQline
DisableRaw
WallOper
WallBadOS
WallOSGlobal
WallOSMode
WallOSClearmodes
WallOSKick
WallOSAkill
WallOSSGLine
WallOSSQLine
WallOSSZLine
WallOSNoOp
WallOSJupe
WallOSRaw
WallAkillExpire
WallSGLineExpire
WallSQLineExpire
WallSZLineExpire
WallExceptionExpire
WallGetpass
WallSetpass
WallForbid
WallDrop

LimitSessions
DefSessionLimit 3
MaxSessionLimit 100
ExceptionExpiry 1d
SessionLimitExceeded "The session limit for your host %s has been exceeded."
MaxSessionKill 10
SessionAutoKillExpiry 30m
AddAkiller
OSOpersOnly

DefConLevel 5

DefCon4 23
# No channel reg + No Nick Reg + No MLOCK changes + Use Reduced Session Limit

DefCon3 31
# As DefCon4 + Services will Force Chan Mode's on channels

DefCon2 159
# As DefCon3 + Services will silently ignore everyone but opers

DefCon1 415
# As DefCon2 + AKILL all new clients trying to connect

DefConSessionLimit 2
DefConAkillExpire 15m
DefConChanModes "+R"
DefConTimeOut 30m
GlobalOnDefcon
DefConOffMessage "Services are now back to normal, sorry for any inconvenience"
DefConAkillReason "This network is currently not accepting connections, please try again later"

ModuleDelayedAutoload "cs_appendtopic cs_enforce ns_maxemail os_info hs_request"

NSEmailMax 5

OSInfoDBName "os_info.db"
OSIgnoreDBName "os_ignore.db"

HSRequestMemoUser
HSRequestMemoOper
HSRequestDBName "hs_request.db"
EOF

echo "Created services.conf. Attempting to start Anope..."

cd ~
cd services
chmod +x services
chmod +x anoperc
./services

#cleanup

cd ~
rm anope-1.8.9.tar.gz

#Check if anope ran successfully or not.
if pgrep services >/dev/null 2>&1
then
 echo "Anope is running successfully"
else
 echo "Error occured"
 exit 
fi
echo "Provision done, successfully."
