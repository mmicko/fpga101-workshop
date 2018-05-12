#include <stdint.h>
#include <string.h>

extern uint32_t _sidata, _sdata, _edata;

void executable_init_sections() 
{
    for (uint32_t *src = &_sidata, *dest = &_sdata; dest < &_edata;) {
        *dest++ = *src++;
    }
}
