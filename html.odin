package md

import "core:fmt"
import "core:strings"

close_html :: proc( w: ^Writer, s: state) {
	#partial switch s {
	case .paragraph:
		strings.write_string(&w.b, "</p>" )
	case .heading:
		head := fmt.aprintf( "<h%d>%s</h%d>", w.heading_level, strings.to_string(w.heading), w.heading_level )
		defer delete(head)

		strings.builder_reset( &w.heading )
		strings.write_string(&w.b, head )
	}
}

open_html :: proc( w: ^Writer, s:state) {
	#partial switch s {
	case .paragraph:
		strings.write_string(&w.b, "<p>" )
	}
}

to_html :: proc(md: string) -> string {
	return parse(md, open_html, close_html)
}
