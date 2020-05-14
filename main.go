package main

// goon <spec>
//
// continues processing current shell executing at <spec>. it is similar to
// sleep(1) and at(1).
//
// @hour - run at next full hour
// @minute - run at next full minute
// @tens - run at the next full 10 minutes
// @quarter - run at the next quarter
// :15 - continue at <current_hour>:15
// 20:15 - go on at 20:15
// 11:15PM - go on at 11:15PM

import (
	"fmt"
	"os"
	"strings"
	"time"
)

func main() {

	if len(os.Args) < 2 {
		fmt.Println("usage: goon <spec>")
		os.Exit(0)
	}

	spec := strings.TrimSpace(os.Args[1])
	t := time.Now()
	when, err := parse(spec, t)
	dur := when.Sub(t)

	fmt.Println("go on at", when, "; in", dur, err)
	time.Sleep(dur)
}

func parse(spec string, t time.Time) (time.Time, error) {
	if len(spec) == 0 {
		return t, fmt.Errorf("can't parse %q", spec)
	}

	// shortcuts
	if spec[0] == '@' {
		return parseAtSpec(spec, t)
	}

	// try duration
	if d, _ := time.ParseDuration(spec); d > 0 {
		return t.Add(d), nil
	}

	return parseAsTime(spec, t)
}

func parseAtSpec(spec string, t time.Time) (time.Time, error) {
	switch spec {
	case "@hour":
		return t.Add(time.Hour).Truncate(time.Hour), nil
	case "@minute":
		return t.Add(time.Minute).Truncate(time.Minute), nil
	case "@tens":
		return t.Add(10 * time.Minute).Truncate(10 * time.Minute), nil
	case "@quarter":
		return t.Add(15 * time.Minute).Truncate(15 * time.Minute), nil
	case "@midnight":
		return t.Add(24 * time.Hour).Truncate(24 * time.Hour), nil
	case "@noon":
		return parseAsTime("12:00", t)
	}

	return time.Time{}, fmt.Errorf("can't parse %q", spec)
}

func parseAsTime(spec string, t time.Time) (time.Time, error) {
	if nt, err := time.Parse(":04", spec); err == nil {
		return time.Date(t.Year(), t.Month(), t.Day(), t.Hour(), nt.Minute(), 0, 0, t.Location()), nil
	}
	if nt, err := time.Parse("15:04", spec); err == nil {
		return time.Date(t.Year(), t.Month(), t.Day(), nt.Hour(), nt.Minute(), 0, 0, t.Location()), nil
	}
	if nt, err := time.Parse("15:04:05", spec); err == nil {
		return time.Date(t.Year(), t.Month(), t.Day(), nt.Hour(), nt.Minute(), nt.Second(), 0, t.Location()), nil
	}
	if nt, err := time.Parse(time.Kitchen, spec); err == nil {
		return time.Date(t.Year(), t.Month(), t.Day(), nt.Hour(), nt.Minute(), 0, 0, t.Location()), nil
	}
	if nt, err := time.Parse(time.RFC3339, spec); err == nil {
		return nt, nil
	}
	return t, fmt.Errorf("can't parse %q", spec)
}
