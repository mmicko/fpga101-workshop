#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "py/compile.h"
#include "py/runtime.h"
#include "py/repl.h"
#include "py/gc.h"
#include "py/mperrno.h"
#include "lib/utils/pyexec.h"

#include "board.h"

#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)

// Receive single character
char mp_hal_stdin_rx_chr(void) {
	int32_t c = -1;

	while (c == -1) {
		c = reg_uart_data;
	}
    return c;
}

// Send string of given length
void mp_hal_stdout_tx_strn(const char *str, mp_uint_t len) {
    while (len--) {
        reg_uart_data = *str++;
    }
}

char getchar_prompt(char *prompt)
{
	int32_t c = -1;

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));

	if (prompt)
		printf(prompt);

	while (c == -1) {
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > 12000000) {
			if (prompt)
				printf(prompt);
			cycles_begin = cycles_now;
		}
		c = reg_uart_data;
	}
	return c;
}         

void do_str(const char *src, mp_parse_input_kind_t input_kind) {
    nlr_buf_t nlr;
    if (nlr_push(&nlr) == 0) {
        mp_lexer_t *lex = mp_lexer_new_from_str_len(MP_QSTR__lt_stdin_gt_, src, strlen(src), 0);
        qstr source_name = lex->source_name;
        mp_parse_tree_t parse_tree = mp_parse(lex, input_kind);
        mp_obj_t module_fun = mp_compile(&parse_tree, source_name, MP_EMIT_OPT_NONE, true);
        mp_call_function_0(module_fun);
        nlr_pop();
    } else {
        // uncaught exception
        mp_obj_print_exception(&mp_plat_print, (mp_obj_t)nlr.ret_val);
    }
}

static char *stack_top;
extern uint32_t _heap_start;

int main(int argc, char **argv) {
	reg_uart_clkdiv = 1250;
    led_init();
    lcd_clear();

    int stack_dummy;
    
    stack_top = (char*)&stack_dummy;
    
	while (getchar_prompt("Press ENTER to continue..\r\n") != '\r') { /* wait */ }

	printf("\n");
	printf("  ____  _          ____         ____\r\n");
	printf(" |  _ \\(_) ___ ___/ ___|  ___  / ___|\r\n");
	printf(" | |_) | |/ __/ _ \\___ \\ / _ \\| |\r\n");
	printf(" |  __/| | (_| (_) |__) | (_) | |___\r\n");
	printf(" |_|   |_|\\___\\___/____/ \\___/ \\____|\r\n");
	printf("\n");


    gc_init((char*)&_heap_start , (char*)(&_heap_start) + (0x20000 - _heap_start));
    mp_init();
    pyexec_friendly_repl();
    mp_deinit();
    return 0;
}

void gc_collect(void) {
	printf("gc_collect\n");
    // WARNING: This gc_collect implementation doesn't try to get root
    // pointers from CPU registers, and thus may function incorrectly.
    void *dummy;
    gc_collect_start();
    gc_collect_root(&dummy, ((mp_uint_t)stack_top - (mp_uint_t)&dummy) / sizeof(mp_uint_t));
    gc_collect_end();
    gc_dump_info();
}

mp_lexer_t *mp_lexer_new_from_file(const char *filename) {
    mp_raise_OSError(MP_ENOENT);
}

mp_import_stat_t mp_import_stat(const char *path) {
    return MP_IMPORT_STAT_NO_EXIST;
}

mp_obj_t mp_builtin_open(size_t n_args, const mp_obj_t *args, mp_map_t *kwargs) {
    return mp_const_none;
}
MP_DEFINE_CONST_FUN_OBJ_KW(mp_builtin_open_obj, 1, mp_builtin_open);

void nlr_jump_fail(void *val) {
    while (1);
}

void NORETURN __fatal_error(const char *msg) {
    while (1);
}

#ifndef NDEBUG
void MP_WEAK __assert_func(const char *file, int line, const char *func, const char *expr) {
    printf("Assertion '%s' failed, at file %s:%d\n", expr, file, line);
    __fatal_error("Assertion failed");
}
#endif

