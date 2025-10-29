import { createPoll } from "ags/time"
import { Gtk } from "ags/gtk4"
import GLib from "gi://GLib"

// The single, efficient source of truth for the current time.
// It initializes with the current time and updates every second.
const timeSource = createPoll(
  GLib.DateTime.new_now_local(),
  1000,
  () => GLib.DateTime.new_now_local(),
)

// Derived values. These are accessors that automatically update
// whenever 'timeSource' changes.
const dayOfWeek = timeSource(time => time.format("%A")!.toUpperCase())
const fullDate = timeSource(time => time.format("%d %B, %Y.")!.toUpperCase())
const time = timeSource(time => time.format("- %H:%M -")!)

export default function Clock() {
  return (
    <box class="clock-container" orientation={Gtk.Orientation.VERTICAL}>
      <label class="day-of-week" label={dayOfWeek} halign={Gtk.Align.CENTER} />
      <label class="full-date" label={fullDate} halign={Gtk.Align.CENTER} />
      <label class="time" label={time} halign={Gtk.Align.CENTER} />
    </box>
  )
}