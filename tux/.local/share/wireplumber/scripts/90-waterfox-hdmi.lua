
local lutils = require ("linking-utils")
local log = Log.open_topic ("s-waterfox-hdmi")

local HDMI_SINK = "alsa_output.pci-0000_07_00.1.hdmi-stereo"

SimpleEventHook {
  name = "linking/find-waterfox-hdmi",

  -- Respect explicitly defined targets, but run before
  -- the normal fallback target selection.
  after = "linking/find-defined-target",
  before = "linking/find-audio-group-target",

  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-target" },
    },
  },

  execute = function (event)
    local source, om, si, si_props, si_flags, target =
        lutils:unwrap_select_target_event (event)

    -- Do not override a target already selected by an earlier hook.
    if target then
      return
    end

    -- Only affect Waterfox playback streams.
    if si_props["application.name"] ~= "Waterfox" then
      return
    end

    if si_props["media.class"] ~= "Stream/Output/Audio" then
      return
    end

    -- Find the HDMI sink's audio adapter.
    local hdmi = om:lookup {
      type = "siAudioAdapter",
      Constraint { "node.name", "=", HDMI_SINK },
    }

    if not hdmi then
      log:warning ("HDMI sink not found: " .. HDMI_SINK)
      return
    end

    log:info (si, "selecting HDMI sink for Waterfox")
    event:set_data ("target", hdmi)
  end
}:register ()
