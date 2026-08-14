import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.tr("Power Profile")
    toggled: TlpProfiles.profile !== PowerProfile.Balanced
    icon: switch(TlpProfiles.profile) {
        case PowerProfile.PowerSaver: return "energy_savings_leaf"
        case PowerProfile.Balanced: return "airwave"
        case PowerProfile.Performance: return "local_fire_department"
    }
    statusText: switch(TlpProfiles.profile) {
        case PowerProfile.PowerSaver: return "Ahorro"
        case PowerProfile.Balanced: return "Balanceado"
        case PowerProfile.Performance: return "Rendimiento"
    }

    mainAction: () => {
        TlpProfiles.cycle()
    }
    tooltipText: Translation.tr("Click to cycle through power profiles")
}
