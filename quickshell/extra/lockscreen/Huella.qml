import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Io

Item{
  id:main
  property var name:""
  property var func:null

   readonly property var huella:Process {
    id:test
    running:true
    command: [ "sh", "/home/plof/.config/quickshell/extra/lockscreen/huella.sh" ]
		//manageLifetime: false
    stdout: SplitParser {
      onRead: data => {
        info.visible=data==="LID"? false:true
        if (data==="reading"){
          name= "Reading fingerprint..."
        }
        
        if (data==="error"){
          name= "Error"
        }

        if (data==="no-match"){
          name="No match"
        }
      }
    }

    onExited:{
      console.log("el codigo fue:"+exitCode)
      if (exitCode==0){
        func.unlocked()
      }
    }
  }


    Rectangle{
      id:info
      height:30
      width:300
      color:"transparent"
      //color:"red"
      Text{
        text:name
        font.pointSize: 13
        color:"white"
      }
    }
}
