const { Gtk, Gdk } = imports.gi;
import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
const { Box, Button, CenterBox, Entry, EventBox, Icon, Label, Overlay, Revealer, Scrollable, Stack } = Widget;
const { execAsync, exec } = Utils;

const EXPAND_INPUT_THRESHOLD = 30;
const APILIST = {
}
const APIS = userOptions.sidebar.pages.apis.order.map((apiName) => APILIST[apiName]);
let currentApiId = 0;


const apiWidgets = Widget.Box({
    attribute: {
    },
    vertical: true,
    className: 'spacing-v-10',
    homogeneous: false,
    children: [
        //apiContentStack,
        //apiCommandStack,
        //textboxArea,
    ],
});

export default apiWidgets;
