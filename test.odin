package md

import "core:fmt"
import "core:testing"

@(test)
basic :: proc(t: ^testing.T) {
	html := to_html(#load("README.md"))
	defer delete(html)

	fmt.printf(html)
}
