#include <stdio.h>
#include <stdlib.h>

extern void asmproc(void);

int main(void) {

    puts("Hello from main");
    puts("Calling asmproc");
    asmproc();
    puts("Returned from asmproc");
    return EXIT_SUCCESS;

}