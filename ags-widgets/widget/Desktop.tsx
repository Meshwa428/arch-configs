
import Clock from "./Clock"
import { Astal, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"

export default function DesktopWidget() {
  return (
    <window
      visible
      name="desktop-widget"
      class="desktop-widget"
      application={app}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.BACKGROUND}
    >
      <Gtk.Box halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
        <Clock />
      </Gtk.Box>
    </window>
  )
}
