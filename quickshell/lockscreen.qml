import Quickshell
import Quickshell.Wayland
import "modules/ii/lockscreen" as LS

ShellRoot {
    LS.LockContext {
        id: lockContext
        onUnlocked: {
            lock.locked = false;
            Qt.quit();
        }
    }

    WlSessionLock {
        id: lock
        locked: true
        WlSessionLockSurface {
            LS.LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}
