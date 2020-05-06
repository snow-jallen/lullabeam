defmodule Lullabeam.InputDevices.WirelessKeypad do
  @moduledoc """
  Interpret keystrokes coming from a generic wireless keypad, /dev/hidraw3

  Layout:

  ┌───┐ ┌───┐ ┌───┐ ┌───┐
  │Num│ │ / │ │ * │ │ - │
  └───┘ └───┘ └───┘ └───┘
  ┌───┐ ┌───┐ ┌───┐ ┌───┐
  │ 7 │ │ 8 │ │ 9 │ │ + │
  └───┘ └───┘ └───┘ └───┘
  ┌───┐ ┌───┐ ┌───┐ ┌───┐
  │ 4 │ │ 5 │ │ 6 │ │BS │
  └───┘ └───┘ └───┘ └───┘
  ┌───┐ ┌───┐ ┌───┐ ┌───┐
  │ 1 │ │ 2 │ │ 3 │ │ E │
  └───┘ └───┘ └───┘ │ n │
  ┌─────────┐ ┌───┐ │ t │
  │    0    │ │ . │ │ r │
  └─────────┘ └───┘ └───┘

  Mapping:

  ┌───┐ ┌───┐ ┌───┐ ┌───┐
  │ x │ │🌙 │ │🌕 │ │🌞 │
  └───┘ └───┘ └───┘ └───┘
  ┌───┐ ┌───┐ ┌───┐ ┌───┐
  │⟵ │ │ ⟶│ │ ? │ │ ? │
  └───┘ └───┘ └───┘ └───┘
  ┌───┐ ┌───┐ ┌───┐ ┌───┐
  │⏪ │ │ ⏯️ │⏩│ │🛑 │
  └───┘ └───┘ └───┘ └───┘
  ┌───┐ ┌───┐ ┌───┐ ┌───┐
  │ ? │ │ ? │ │ ? │ │   │
  └───┘ └───┘ └───┘ │   │
  ┌───┐ ┌───┐ ┌───┐ │ ? │
  │ x │ │ x │ │ ? │ │   │
  └───┘ └───┘ └───┘ └───┘

  🌙 = nap mode
  🌕 = bed mode
  🌞 = day mode
  ⟵  = previous folder
  ⟶  = next folder
  ⏪ = previous track
  ⏩ = next track
  ⏯️  = play / pause
  🛑 = stop

  Note: the "00" key register as two presses of "0".
  Because of this, it's best not to assign anything to "0".
  Also, numlock toggles an LED so I'd rather not use it.
  """
  def device_name do
    #"/dev/hidraw3"
    #"/dev/input/event4"
    "Hengchangtong keyboard mouse"
  end

  def interpret({:ev_key, :key_kpslash, 0 = _keyup}), do: {:cmd, {:set_mode, :nap}}
  def interpret({:ev_key, :key_kpasterisk, 0 = _keyup}), do: {:cmd, {:set_mode, :bed}}
  def interpret({:ev_key, :key_backspace, 0 = _keyup}), do: {:cmd, {:set_mode, :wake}}
  def interpret({:ev_key, :key_kp7, 0 = _keyup}), do: {:cmd, :prev_folder}
  def interpret({:ev_key, :key_kp8, 0 = _keyup}), do: {:cmd, :next_folder}
  def interpret({:ev_key, :key_kp4, 0 = _keyup}), do: {:cmd, :prev_track}
  def interpret({:ev_key, :key_kp5, 0 = _keyup}), do: {:cmd, :play_or_pause}
  def interpret({:ev_key, :key_kp6, 0 = _keyup}), do: {:cmd, :next_track}
  def interpret({:ev_key, :key_kpplus, 0 = _keyup}), do: {:cmd, :stop}

  # Unassigned:
  # [:key_kp0, :key_kp1, :key_kp2, :key_kp3, :key_kp9, :key_kpdot,
  # :key_numlock,  :key_kpenter, key_kpminus]
  def interpret(_e), do: :unknown
end
