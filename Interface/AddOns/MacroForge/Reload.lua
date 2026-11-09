local _,MF=...
StaticPopupDialogs.MACROFORGE_RELOAD={
    text="Your new macro works immediately. Reloading can flush addon preferences to disk. Reload now?",
    button1="Reload Now",button2="Later",timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3,
    OnAccept=function() MF.dirty=false; ReloadUI() end,
    OnCancel=function() MF.dirty=false end,
}
function MF:OnClose() if self.dirty then StaticPopup_Show("MACROFORGE_RELOAD") end end
