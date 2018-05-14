/*
 * This file is part of the MicroPython project, http://micropython.org/
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2015 Damien P. George
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <stdio.h>

#include "py/obj.h"
#include "py/mphal.h"
#include "modpyb.h"

STATIC mp_obj_t pyb_delay(mp_obj_t ms_in) {
    mp_int_t ms = mp_obj_get_int(ms_in);

	uint32_t cycles_begin, cycles_now, cycles = 0;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));

	while (cycles < (ms * 12000)) {
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
	}
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(pyb_delay_obj, pyb_delay);

#define reg_tone ((volatile uint32_t*)0x06000000)

STATIC mp_obj_t pyb_tone(mp_obj_t freq_in, mp_obj_t ms_in) {
	mp_int_t freq = mp_obj_get_int(freq_in);
    mp_int_t ms = mp_obj_get_int(ms_in);

	reg_tone[0] = 12000000L / freq / 2;
	uint32_t cycles_begin, cycles_now, cycles = 0;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));

	while (cycles < (ms * 12000)) {
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
	}
	reg_tone[0] = 0;
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_2(pyb_tone_obj, pyb_tone);

STATIC const mp_rom_map_elem_t pyb_module_globals_table[] = {
    { MP_ROM_QSTR(MP_QSTR___name__), MP_ROM_QSTR(MP_QSTR_pyb) },

    { MP_ROM_QSTR(MP_QSTR_LED), MP_ROM_PTR(&pyb_led_type) },
	{ MP_ROM_QSTR(MP_QSTR_LCD), MP_ROM_PTR(&pyb_lcd_type) },
    { MP_ROM_QSTR(MP_QSTR_Switch), MP_ROM_PTR(&pyb_switch_type) },

    { MP_ROM_QSTR(MP_QSTR_delay), MP_ROM_PTR(&pyb_delay_obj) },
	{ MP_ROM_QSTR(MP_QSTR_tone), MP_ROM_PTR(&pyb_tone_obj) },
};

STATIC MP_DEFINE_CONST_DICT(pyb_module_globals, pyb_module_globals_table);

const mp_obj_module_t pyb_module = {
    .base = { &mp_type_module },
    .globals = (mp_obj_dict_t*)&pyb_module_globals,
};
