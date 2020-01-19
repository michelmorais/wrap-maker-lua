#include "dummyCalc.h"

#include <stdio.h>

int sum(const int v1, const int v2)
{
    printf("calc of %d +%d = %d\n",v1,v2,v1 + v2);
    return v1 + v2;
}