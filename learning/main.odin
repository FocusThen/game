#+feature dynamic-literals
package main

import "core:fmt"

// Basically golang
main :: proc() {
	fmt.println("----------- Assignment --------------")
	// Assignment
	x: int = 123
	y: string = "hellop"
	// ---- same
	// x := 123
	// y := "hellop"
	// constant
	z :: "API_URL"
	fmt.printf("x: %d, y: %s, z: %s\n", x, y, z)

	fmt.println("----------- Loops --------------")
	// loooooooppps
	// no i++
	for i := 0; i < 10; i += 1 {
		fmt.println(i)
	}

	some_string := "Hello, 世界"
	for character in some_string {
		fmt.println(character)
	}

	some_array := [3]int{1, 2, 3}
	for value in some_array {
		fmt.println("array: ", value)
	}

	some_slice := []int{4, 5, 6}
	for value in some_slice {
		fmt.println("slice: ", value)
	}

	some_dynamic_array := [dynamic]int{1, 4, 9} // must be enabled with `#+feature dynamic-literals`
	defer delete(some_dynamic_array)
	for value in some_dynamic_array {
		fmt.println("dynamic array: ", value)
	}

	some_map := map[string]int {
		"A" = 1,
		"C" = 9,
		"B" = 4,
	} // must be enabled with `#+feature dynamic-literals`
	defer delete(some_map)
	for key, value in some_map {
		fmt.println("map keys: ", key, "map values: ", value)
	}

	fmt.println("----------- IF/ELSE --------------")
	if x >= 0 {
		fmt.println("x is positive")
	}


	fmt.println("----------- Switch --------------")
	// switch
	switch arch := ODIN_ARCH; arch {
	case .i386, .wasm32, .arm32:
		fmt.println("32 bit")
	case .amd64, .wasm64p32, .arm64, .riscv64:
		fmt.println("64 bit")
	case .Unknown:
		fmt.println("Unknown architecture")
	}

	fmt.println("----------- Defer --------------")

	a := 123
	defer fmt.println("Defer 1 - a: ", a)
	{
		defer a = 4
		a = 2
	}
  fmt.println("normal - a: ", a)

  a = 234
}
