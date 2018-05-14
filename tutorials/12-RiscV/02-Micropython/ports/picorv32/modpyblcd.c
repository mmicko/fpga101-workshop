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

#include "py/runtime.h"
#include "board.h"
#include "modpyb.h"

typedef struct _pyb_lcd_obj_t {
    mp_obj_base_t base;
} pyb_lcd_obj_t;

STATIC const pyb_lcd_obj_t pyb_lcd_obj = {{&pyb_lcd_type}};

STATIC mp_obj_t pyb_lcd_make_new(const mp_obj_type_t *type, size_t n_args, size_t n_kw, const mp_obj_t *args) {
    // check arguments
    mp_arg_check_num(n_args, n_kw, 0, 0, false);
    // return constant object
    return (mp_obj_t)&pyb_lcd_obj;
}

mp_obj_t pyb_lcd_clear(mp_obj_t self_in) {
	lcd_clear();
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(pyb_lcd_clear_obj, pyb_lcd_clear);

mp_obj_t pyb_lcd_pos_x(mp_obj_t self_in) {
    return mp_obj_new_int(lcd_pos_x());
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(pyb_lcd_pos_x_obj, pyb_lcd_pos_x);

mp_obj_t pyb_lcd_pos_y(mp_obj_t self_in) {
    return mp_obj_new_int(lcd_pos_y());
}
STATIC MP_DEFINE_CONST_FUN_OBJ_1(pyb_lcd_pos_y_obj, pyb_lcd_pos_y);

mp_obj_t pyb_lcd_move(mp_obj_t self_in,mp_obj_t xpos_in, mp_obj_t ypos_in) {
    mp_int_t xpos = mp_obj_get_int(xpos_in);
    mp_int_t ypos = mp_obj_get_int(ypos_in);
    lcd_move(xpos,ypos);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_3(pyb_lcd_move_obj, pyb_lcd_move);

/// \method write(str)
///
/// Write the string `str` to the screen.  It will appear immediately.
STATIC mp_obj_t pyb_lcd_write(mp_obj_t self_in, mp_obj_t str) {
    size_t len;
    const char *data = mp_obj_str_get_data(str, &len);
    lcd_write(data, len);
    return mp_const_none;
}
STATIC MP_DEFINE_CONST_FUN_OBJ_2(pyb_lcd_write_obj, pyb_lcd_write);

STATIC const mp_rom_map_elem_t pyb_lcd_locals_dict_table[] = {
    { MP_ROM_QSTR(MP_QSTR_clear), MP_ROM_PTR(&pyb_lcd_clear_obj) },
	{ MP_ROM_QSTR(MP_QSTR_x), MP_ROM_PTR(&pyb_lcd_pos_x_obj) },
    { MP_ROM_QSTR(MP_QSTR_y), MP_ROM_PTR(&pyb_lcd_pos_y_obj) },
	{ MP_ROM_QSTR(MP_QSTR_write), MP_ROM_PTR(&pyb_lcd_write_obj) },
    { MP_ROM_QSTR(MP_QSTR_move), MP_ROM_PTR(&pyb_lcd_move_obj) },
};

STATIC MP_DEFINE_CONST_DICT(pyb_lcd_locals_dict, pyb_lcd_locals_dict_table);

const mp_obj_type_t pyb_lcd_type = {
    { &mp_type_type },
    .name = MP_QSTR_lcd,
    .make_new = pyb_lcd_make_new,
    .locals_dict = (mp_obj_t)&pyb_lcd_locals_dict,
};
