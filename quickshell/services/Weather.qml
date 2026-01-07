pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root
    readonly property int fetchInterval: 600000
    readonly property string city: ""
    readonly property bool useUSCS: false
    property bool gpsActive: false

    property var location: ({
        valid: false,
        lat: 0,
        lon: 0
    })

    property var data: ({
        uv: 0,
        humidity: 0,
        sunrise: 0,
        sunset: 0,
        windDir: 0,
        wCode: 0,
        city: 0,
        wind: 0,
        precip: 0,
        visib: 0,
        press: 0,
        temp: 0,
        tempFeelsLike: 0,
        lastRefresh: 0,
    })

    function refineData(data) {}
    function getData() {}
    function formatCityName(cityName) { return "" }
}