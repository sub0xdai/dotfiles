// obsfix repoints OBS Studio's global audio devices at the current PipeWire defaults and
// disables source monitoring, so Bluetooth headphones stop breaking audio capture.
//
// Two independent failures are repaired:
//
//  1. A Mic/Aux source bound to a Bluetooth headset microphone forces the card out of A2DP
//     into HSP/HFP, which removes the A2DP sink. Desktop Audio, pinned to that sink's
//     ".monitor" source, then records silence for the rest of the session.
//  2. A source whose capture device is also the audio monitoring device makes OBS
//     deduplicate and silence it. Observed in obs-studio/logs as "Device for 'Audio Output
//     Capture' source Desktop Audio is also used for audio monitoring."
//
// Only device_id, monitoring_type, and optionally the Mic/Aux fader are ever written. Every
// other field of a global audio device (mixers, enabled, muted, uuid, hotkeys, ...) is
// carried through verbatim.
//
// Run with OBS closed: OBS rewrites its scene collection on exit.
package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"math"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
)

const (
	sceneDirRel  = ".config/obs-studio/basic/scenes"
	desktopKey   = "DesktopAudioDevice1"
	micKey       = "AuxAudioDevice1"
	backupSuffix = ".pre-obsfix"
	monitorNone  = 0 // OBS_MONITORING_TYPE_NONE
)

// preservedFields must still be present after a rewrite. Writing a partial struct over a
// global audio device silently drops the rest, which resets the fader and track routing.
var preservedFields = []string{"uuid", "mixers", "enabled", "volume", "flags"}

// globalDevice reads the fields this tool reports on. Unmarshalling ignores the rest, so it
// is safe for reading; writes never go through this struct.
type globalDevice struct {
	Name       string                     `json:"name"`
	Monitoring int                        `json:"monitoring_type"`
	Settings   map[string]json.RawMessage `json:"settings"`
}

// collection is a whole OBS scene collection, held as raw JSON so unknown fields survive.
type collection struct {
	fields map[string]json.RawMessage
}

func loadCollection(path string) (*collection, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read: %w", err)
	}
	if len(raw) == 0 {
		return nil, errors.New("scene collection is empty")
	}
	fields := make(map[string]json.RawMessage)
	if err := json.Unmarshal(raw, &fields); err != nil {
		return nil, fmt.Errorf("parse: %w", err)
	}
	if len(fields) == 0 {
		return nil, errors.New("scene collection has no top-level fields")
	}
	return &collection{fields: fields}, nil
}

func (c *collection) device(key string) (globalDevice, error) {
	raw, ok := c.fields[key]
	if !ok {
		return globalDevice{}, fmt.Errorf("%s: not a global audio device", key)
	}
	var dev globalDevice
	if err := json.Unmarshal(raw, &dev); err != nil {
		return globalDevice{}, fmt.Errorf("%s: parse: %w", key, err)
	}
	return dev, nil
}

func (c *collection) fieldsOf(key string) (map[string]json.RawMessage, error) {
	raw, ok := c.fields[key]
	if !ok {
		return nil, fmt.Errorf("%s: not a global audio device", key)
	}
	fields := make(map[string]json.RawMessage)
	if err := json.Unmarshal(raw, &fields); err != nil {
		return nil, fmt.Errorf("%s: parse: %w", key, err)
	}
	return fields, nil
}

// linearVolume reads the fader of an already-parsed global audio device.
func linearVolume(fields map[string]json.RawMessage) (float64, error) {
	raw, ok := fields["volume"]
	if !ok {
		return 0, errors.New("volume field is absent")
	}
	var v float64
	if err := json.Unmarshal(raw, &v); err != nil {
		return 0, fmt.Errorf("parse volume: %w", err)
	}
	return v, nil
}

// deviceID returns the device_id currently stored for one global audio device.
func (c *collection) deviceID(key string) (string, error) {
	dev, err := c.device(key)
	if err != nil {
		return "", err
	}
	var id string
	if idRaw, ok := dev.Settings["device_id"]; ok {
		if err := json.Unmarshal(idRaw, &id); err != nil {
			return "", fmt.Errorf("%s: parse device id: %w", key, err)
		}
	}
	return id, nil
}

// setDevice rewrites device_id and monitoring_type and nothing else.
func (c *collection) setDevice(key, deviceID string, monitoring int) error {
	if key == "" || deviceID == "" {
		return errors.New("empty key or device id")
	}
	dev, err := c.fieldsOf(key)
	if err != nil {
		return err
	}
	if _, ok := dev["id"]; !ok {
		return fmt.Errorf("%s: source has no id", key)
	}
	settings := make(map[string]json.RawMessage)
	if raw, ok := dev["settings"]; ok {
		if err := json.Unmarshal(raw, &settings); err != nil {
			return fmt.Errorf("%s: parse settings: %w", key, err)
		}
	}
	encodedID, err := json.Marshal(deviceID)
	if err != nil {
		return fmt.Errorf("%s: encode device id: %w", key, err)
	}
	settings["device_id"] = encodedID
	encodedSettings, err := json.Marshal(settings)
	if err != nil {
		return fmt.Errorf("%s: encode settings: %w", key, err)
	}
	dev["settings"] = encodedSettings
	dev["monitoring_type"] = json.RawMessage(strconv.Itoa(monitoring))
	patched, err := json.Marshal(dev)
	if err != nil {
		return fmt.Errorf("%s: encode: %w", key, err)
	}
	c.fields[key] = patched
	return nil
}

// setVolume sets a global audio device fader, in dB, leaving the other fields untouched.
func (c *collection) setVolume(key string, db float64) error {
	dev, err := c.fieldsOf(key)
	if err != nil {
		return err
	}
	linear := math.Pow(10, db/20)
	if math.IsNaN(linear) || linear <= 0 || linear > 100 {
		return fmt.Errorf("%s: gain %.1f dB is out of range", key, db)
	}
	dev["volume"] = json.RawMessage(strconv.FormatFloat(linear, 'f', -1, 64))
	patched, err := json.Marshal(dev)
	if err != nil {
		return fmt.Errorf("%s: encode: %w", key, err)
	}
	c.fields[key] = patched
	return nil
}

func (c *collection) save(path string) error {
	out, err := json.MarshalIndent(c.fields, "", "    ")
	if err != nil {
		return fmt.Errorf("encode: %w", err)
	}
	out = append(out, '\n')
	if len(out) < 2 {
		return errors.New("refusing to write an empty scene collection")
	}
	if err := os.WriteFile(path, out, 0o600); err != nil {
		return fmt.Errorf("write: %w", err)
	}
	info, err := os.Stat(path)
	if err != nil {
		return fmt.Errorf("verify write: %w", err)
	}
	if info.Size() != int64(len(out)) {
		return fmt.Errorf("verify write: on disk %d bytes, wrote %d", info.Size(), len(out))
	}
	return nil
}

// backup keeps one copy of the pre-obsfix state; later runs do not overwrite it.
func backup(path string) error {
	dest := path + backupSuffix
	switch _, err := os.Stat(dest); {
	case err == nil:
		return nil
	case !errors.Is(err, os.ErrNotExist):
		return fmt.Errorf("stat backup: %w", err)
	}
	raw, err := os.ReadFile(path)
	if err != nil {
		return fmt.Errorf("read for backup: %w", err)
	}
	if len(raw) == 0 {
		return errors.New("refusing to back up an empty file")
	}
	if err := os.WriteFile(dest, raw, 0o600); err != nil {
		return fmt.Errorf("write backup: %w", err)
	}
	return nil
}

// obsRunning reports whether OBS is live, since OBS overwrites its config on exit.
func obsRunning() (bool, error) {
	procs, err := os.ReadDir("/proc")
	if err != nil {
		return false, fmt.Errorf("read /proc: %w", err)
	}
	for _, p := range procs {
		if !p.IsDir() {
			continue
		}
		if _, err := strconv.Atoi(p.Name()); err != nil {
			continue
		}
		comm, err := os.ReadFile(filepath.Join("/proc", p.Name(), "comm"))
		if err != nil {
			continue // process exited while scanning
		}
		if strings.TrimSpace(string(comm)) == "obs" {
			return true, nil
		}
	}
	return false, nil
}

// pactlDefault returns the current default sink or source node name.
func pactlDefault(kind string) (string, error) {
	out, err := exec.Command("pactl", "get-default-"+kind).Output()
	if err != nil {
		return "", fmt.Errorf("pactl get-default-%s: %w", kind, err)
	}
	name := strings.TrimSpace(string(out))
	if name == "" {
		return "", fmt.Errorf("pactl get-default-%s: empty result", kind)
	}
	return name, nil
}

// rejectHeadsetMic stops the exact regression this tool exists to undo.
func rejectHeadsetMic(device string) error {
	if strings.HasPrefix(device, "bluez_input.") {
		return fmt.Errorf("refusing %s: a Bluetooth headset mic drops its card out of A2DP "+
			"and kills desktop audio capture; pass -mic=<device> to pick another mic", device)
	}
	return nil
}

func sceneCollections(args []string) ([]string, error) {
	if len(args) > 0 {
		return args, nil
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, fmt.Errorf("locate home: %w", err)
	}
	dir := filepath.Join(home, sceneDirRel)
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("read scene dir: %w", err)
	}
	var paths []string
	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".json") {
			continue
		}
		paths = append(paths, filepath.Join(dir, e.Name()))
	}
	if len(paths) == 0 {
		return nil, fmt.Errorf("no scene collections in %s", dir)
	}
	sort.Strings(paths)
	return paths, nil
}

// verifyCollection is the runnable check: it must read back exactly what was written, and
// must find that no unrelated field went missing.
func verifyCollection(path, desktopDevice, micDevice string, micGainDB float64) error {
	c, err := loadCollection(path)
	if err != nil {
		return err
	}
	for key, want := range map[string]string{desktopKey: desktopDevice, micKey: micDevice} {
		got, err := c.deviceID(key)
		if err != nil {
			return err
		}
		if got != want {
			return fmt.Errorf("%s: device is %q, want %q", key, got, want)
		}
		dev, err := c.device(key)
		if err != nil {
			return err
		}
		if dev.Monitoring != monitorNone {
			return fmt.Errorf("%s: monitoring is %d, want %d", key, dev.Monitoring, monitorNone)
		}
		fields, err := c.fieldsOf(key)
		if err != nil {
			return err
		}
		for _, name := range preservedFields {
			if _, ok := fields[name]; !ok {
				return fmt.Errorf("%s: field %q was dropped by the rewrite", key, name)
			}
		}
		if key == micKey && !math.IsNaN(micGainDB) {
			got, err := linearVolume(fields)
			if err != nil {
				return fmt.Errorf("%s: %w", key, err)
			}
			want := math.Pow(10, micGainDB/20)
			if math.Abs(got-want) > 1e-6 {
				return fmt.Errorf("%s: volume is %.6f, want %.6f (%.1f dB)",
					key, got, want, micGainDB)
			}
		}
	}
	return nil
}

// fixCollection rewrites both global audio devices, then verifies the result on disk.
func fixCollection(path, desktopDevice, micDevice string, micGainDB float64) error {
	if err := backup(path); err != nil {
		return err
	}
	c, err := loadCollection(path)
	if err != nil {
		return err
	}
	if err := c.setDevice(desktopKey, desktopDevice, monitorNone); err != nil {
		return err
	}
	if err := c.setDevice(micKey, micDevice, monitorNone); err != nil {
		return err
	}
	if !math.IsNaN(micGainDB) {
		if err := c.setVolume(micKey, micGainDB); err != nil {
			return err
		}
	}
	if err := c.save(path); err != nil {
		return err
	}
	return verifyCollection(path, desktopDevice, micDevice, micGainDB)
}

func run(micOverride string, micGainDB float64, args []string) error {
	if running, err := obsRunning(); err != nil {
		return err
	} else if running {
		return errors.New("OBS is running; quit it first, it rewrites its config on exit")
	}

	sink, err := pactlDefault("sink")
	if err != nil {
		return err
	}
	desktopDevice := sink + ".monitor"

	micDevice := micOverride
	if micDevice == "" {
		if micDevice, err = pactlDefault("source"); err != nil {
			return err
		}
	}
	if err := rejectHeadsetMic(micDevice); err != nil {
		return err
	}

	paths, err := sceneCollections(args)
	if err != nil {
		return err
	}
	for _, path := range paths {
		if err := fixCollection(path, desktopDevice, micDevice, micGainDB); err != nil {
			return fmt.Errorf("%s: %w", path, err)
		}
		gain := "unchanged"
		if !math.IsNaN(micGainDB) {
			gain = fmt.Sprintf("%.1f dB", micGainDB)
		}
		fmt.Printf("%s\n  Desktop Audio -> %s\n  Mic/Aux       -> %s\n"+
			"  monitoring    -> none\n  Mic/Aux gain  -> %s\n",
			path, desktopDevice, micDevice, gain)
	}
	return nil
}

func main() {
	mic := flag.String("mic", "", "Mic/Aux device_id (default: the system default source)")
	micGain := flag.Float64("mic-gain", math.NaN(), "Mic/Aux fader in dB, e.g. 0 (default: unchanged)")
	flag.Parse()
	if err := run(*mic, *micGain, flag.Args()); err != nil {
		fmt.Fprintln(os.Stderr, "obsfix:", err)
		os.Exit(1)
	}
}
