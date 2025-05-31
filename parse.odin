#+feature dynamic-literals
package md

import "core:fmt"
import "core:strings"

Writer :: struct {
	heading_level : uint,
	b, heading: strings.Builder	
}

peek :: proc(s:[dynamic]state) -> state { return s[len(s)-1] }

state :: enum {
	newline,
	count_heading,
	heading,
	paragraph,
}

options :: struct {
	is_meta: bool, // Cannot be inside the stack
	do_pop: bool, // Pop a paragraph
	can_concatenate: bool, // Can be merge if same element
}

genus := map[state]options {
	.newline = { true, false, false },
	.count_heading = { true, false, false },
	.heading = {false, true, false },
	.paragraph = {false, true, true }
}

update_stack_state :: proc(s: ^[dynamic]state, st: state, w: ^Writer, open, close: proc(w: ^Writer, s:state) ) {
	for len(s)>0 && genus[peek(s^)].is_meta {
		pop(s)
	}

	if len(s) > 0 && genus[st].can_concatenate && st==peek(s^){
		return
	}

	if genus[st].do_pop do for len(s)>0  {
		close(w, pop(s))
	}
	open(w, st )
	append(s, st)
}

parse :: proc(md: string, open,close: proc(w: ^Writer, s: state) ) -> string {
	/*
	The parser works with a stack of states, when a state needs
	to be push it check which elements needs to be poped from the
	stack, and write the HTML
	*/

	w:Writer
	w.heading_level = 0
	defer strings.builder_destroy( &w.heading )

	s: [dynamic]state = {state.newline}
	defer delete(s)

	for c in md do switch c {
	case '#':
		switch peek(s)  {
		case .newline:
			update_stack_state(&s, .count_heading, &w, open, close )
			w.heading_level = 1
		case .count_heading:
			w.heading_level += 1
		case .heading:
			strings.write_rune(&w.heading, c )
		case .paragraph:
			strings.write_rune(&w.b, c )
		}
	case '\n':
		update_stack_state(&s, .newline, &w, open, close )
	case:
		switch peek(s) {
		case .newline:
			update_stack_state(&s, .paragraph, &w, open,close )
			strings.write_rune(&w.b, c )
		case .count_heading:
			update_stack_state(&s, .heading, &w, open, close )
		case .heading:
			strings.write_rune(&w.heading, c )
		case .paragraph:
			strings.write_rune(&w.b, c )
		}
	}

	for len(s)>0 {
		close(&w, pop(&s))
	}
	return strings.to_string(w.b)
}
