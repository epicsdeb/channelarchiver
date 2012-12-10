
#include <stdio.h>
#include <float.h>
#include <string.h>
#include <math.h>
#include <xmlrpc.h>

void test(double fltval)
{
  xmlrpc_env env;
  xmlrpc_mem_block *ser;
  xmlrpc_value *val;
  char *blk;

  printf("Starting with %f\n", fltval);

  for(;fabs(fltval)>DBL_EPSILON;fltval/=10) {

    xmlrpc_env_init(&env);

    ser=XMLRPC_MEMBLOCK_NEW(char,&env,0);
    val=xmlrpc_double_new(&env, fltval);

    xmlrpc_serialize_value(&env, ser, val);

    blk=XMLRPC_MEMBLOCK_CONTENTS(char,ser);
    blk[XMLRPC_MEMBLOCK_SIZE(char,ser)]='\0';

    printf("%7g as (%u) '%s'\n", fltval, strlen(blk), blk);

    XMLRPC_MEMBLOCK_FREE(char,ser);
    xmlrpc_DECREF(val);
  }

}

int main(int argc, char* argv[])
{
  test(100);
  test(10000001);
  test(-100);
  test(-10000001);
  return 0;
}
