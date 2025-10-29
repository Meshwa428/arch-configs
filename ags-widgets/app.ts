import app from "ags/gtk4/app"
import style from "./style.scss"
import "./fonts.css"
import DesktopWidget from "./widget/Desktop"

app.start({
  css: style,
  main() {
    app.add_window(DesktopWidget())
  },
})
