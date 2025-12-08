#include "kruskal.h"

/* noinline ? */
static int find(int x, int par[]) 
{
  if (par[x] != x)
  {
    return find(par[x], par);
  }

  return x;
}

int kruskal(/* secret */ int g[], int mst[], int par[], int len)
{
  for (int i=0; i < len; ++i)
  {
    mst[i] = -1;
    par[i] = i;
  }

  int idx = 0;
  
  for (int i=1; i < len; i += 2)
  {
    int src = find(g[i], par);
    int tgt = find(g[i + 1], par);

    /* Begin of sensitive region */

    if (src != tgt)
    {
      par[src] = tgt;
      idx++;
    }
    else
    {
      src = -1;
      tgt = -1;
    }

    /* End of sensitive region */
    
    mst[i] = src;
    mst[i+1] = tgt;
  }

  mst[0] = idx;

  return idx;
}
