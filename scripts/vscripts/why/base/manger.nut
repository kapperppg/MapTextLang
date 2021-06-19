::LOG_LEVEL<-0;
const LOG_CONSOLE=1;
const LOG_CHAT=2;
const LOG_MSG=4;
::logText <- function(text){
    if(LOG_LEVEL&1){
        printl(text);
    }
    if(LOG_LEVEL&2){
        ScriptPrintMessageChatAll(" \x04脚本debug\x01："+text);
    }
    if(LOG_LEVEL&4){
        ScriptPrintMessageCenterAll("<font color='#00ff00'>脚本debug："+text+"</font>");
    }
}
::logTableText <- function(table){
    local text="";
    foreach(k,v in table){
        text=text+k+":::"+v+",,";
    }
    if(LOG_LEVEL&1){
        printl(text);
    }
    if(LOG_LEVEL&2){
        ScriptPrintMessageChatAll(" \x04脚本debug\x01："+text);
    }
    if(LOG_LEVEL&4){
        ScriptPrintMessageCenterAll("<font color='#00ff00'>脚本debug："+text+"</font>");
    }
}
function Precache(){
    EntFireByHandle(self,"RunScriptCode","CheckPlayerInfo()",3,null,null);
};
function CheckPlayerInfo(){
    player <- null;
    while( (player = Entities.FindByClassname(player,"*")) != null ) {
        if (player.GetClassname() == "player") {
            if(GetPlayerByHandle(player)==null){
                player.__KeyValueFromString("rendercolor", "0 255 0");
            }
        }
    }
    ScriptPrintMessageChatAll(" \x02疑似因stripper生成加载存在延迟，变为绿色的玩家请重进服务器，以免神器等级保存不生效！！！\x01");
    ScriptPrintMessageChatAll(" \x02疑似因stripper生成加载存在延迟，变为绿色的玩家请重进服务器，以免神器等级保存不生效！！！\x01");
    ScriptPrintMessageChatAll(" \x02疑似因stripper生成加载存在延迟，变为绿色的玩家请重进服务器，以免神器等级保存不生效！！！\x01");
}
gameevents_proxy<-null;
GameEventsCapturedPlayer <- null;
function PlayerUse(uid,eid) {
    if (GameEventsCapturedPlayer != null && eid == 0) {
        local script_scope = GameEventsCapturedPlayer.GetScriptScope();
        script_scope.userid <- uid;
        if(uid!="BOT"){
            SetPlayerHandle(uid,GameEventsCapturedPlayer);
        }
        GameEventsCapturedPlayer = null;
    }
}
class Player{
    userid=0;
    name=null;
    steamid=null;
    handle = null;
    connected = true;
    itemInfo = null;
    constructor(_u,_s,_n){userid=_u;steamid=_s;name=_n;}
}
PLAYER_LIST<-[];
function GetPlayerByUid(uid){
    for(local i=0;i<PLAYER_LIST.len();i++){
        if(PLAYER_LIST[i].userid==uid){
            return PLAYER_LIST[i];
        }
    }
    return null;
}
function GetPlayerByHandle(handle){
    for(local i=0;i<PLAYER_LIST.len();i++){
        if(PLAYER_LIST[i].handle==handle){
            return PLAYER_LIST[i];
        }
    }
    return null;
}
function GetPlayerBySteamId(sid){
    for(local i=0;i<PLAYER_LIST.len();i++){
        if(PLAYER_LIST[i].steamid==sid){
            return PLAYER_LIST[i];
        }
    }
    return null;
}
function SetPlayerHandle(uid,handle){
    local pl=GetPlayerByUid(uid);
    if(pl==null)return false;
    pl.handle=handle;
    RestoreItemLevel(pl);
    return true;
}
function Think() {
    if("LevelInit" in self.GetScriptScope()){LevelInit();}
    if ( gameevents_proxy==null || !gameevents_proxy.IsValid() ) {
        gameevents_proxy <- Entities.CreateByClassname("info_game_event_proxy");
        gameevents_proxy.__KeyValueFromString("event_name","player_use");
        gameevents_proxy.__KeyValueFromInt("range",0);
    }
    player <- null;
    while( (player = Entities.FindByClassname(player,"*")) != null ) {
        if (player.GetClassname() == "player") {
            if (player.ValidateScriptScope()) {
                local script_scope=player.GetScriptScope()
                if (!("attemptogenerateuserid" in script_scope)&&!("userid" in script_scope)) {
                    script_scope.attemptogenerateuserid <- true;
                    GameEventsCapturedPlayer=player;
                    EntFireByHandle(gameevents_proxy,"GenerateGameEvent","",0.0,player,null);
                    return;
                }
            }
        }
    }
}
function Connected(uid,sid,name){
    if(sid=="BOT")return;
    local pl=GetPlayerBySteamId(sid);
    if(pl==null){
        PLAYER_LIST.push(Player(uid,sid,name));
        return;
    }
    pl.userid=uid;pl.name=name;pl.connected=true;
}
function Disconnected(sid){
    local pl=GetPlayerBySteamId(sid);
    pl.userid=null;pl.handle=null;pl.connected=false;
}
function RoundStart(){
    for(local i=0;i<PLAYER_LIST.len();i++){
        local pl=PLAYER_LIST[i];
        if(pl.connected&&pl.handle!=null&&pl.handle.IsValid()){
            pl.itemInfo=pl.handle.GetName();
        }
    }
}
function ItemPickup(uid,itemName){
    local pl=GetPlayerByUid(uid);
    if(pl!=null&&pl.handle!=null&&pl.handle.IsValid()){
        pl.itemInfo=pl.handle.GetName();
    }
}
function RestoreItemLevel(pl){
    try{
        if(pl.itemInfo!=null&&pl.itemInfo!=""){
            pl.handle.__KeyValueFromString("targetname", pl.itemInfo);
        }
    }catch(e){
        logText(e);
    }
}
