//+private
//+build wasi
package time

import "base:intrinsics"

import "core:sys/wasm/wasi"

_IS_SUPPORTED :: true

_now :: proc "contextless" () -> Time {
	ts, err := wasi.clock_time_get(wasi.CLOCK_REALTIME, 0)
	when !ODIN_DISABLE_ASSERT {
		if err != nil {
			intrinsics.trap()
		}
	}
	return Time{_nsec=i64(ts)}
}

_sleep :: proc "contextless" (d: Duration) {
	ev: wasi.event_t
	n, err := wasi.poll_oneoff(
		&{
			tag   = .CLOCK,
			clock = {
				id      = wasi.CLOCK_MONOTONIC,
				timeout = wasi.timestamp_t(d),
			},
		},
		&ev,
		1,
	)

	when !ODIN_DISABLE_ASSERT {
		if err != nil || n != 1 || ev.error != nil || ev.type != .CLOCK {
			intrinsics.trap()
		}
	}
}

_tick_now :: proc "contextless" () -> Tick {
	ts, err := wasi.clock_time_get(wasi.CLOCK_MONOTONIC, 0)
	when !ODIN_DISABLE_ASSERT {
		if err != nil {
			intrinsics.trap()
		}
	}
	return Tick{_nsec=i64(ts)}
}

_yield :: proc "contextless" () {
	wasi.sched_yield()
}
