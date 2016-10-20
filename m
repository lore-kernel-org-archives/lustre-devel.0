From: Xiong, Jinshan <jinshan.xiong@intel.com>
Date: Thu, 20 Oct 2016 14:50:58 +0000
Subject: [lustre-devel] [bug report] staging: lustre: clio: Revise read
 ahead implementation
In-Reply-To: <20161020105747.GA7003@elgon.mountain>
References: <20161020105747.GA7003@elgon.mountain>
Message-ID: <3D8A00C8-665D-4407-B27D-2B60FE7A3D55@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Oct 20, 2016, at 7:17 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> Hello Jinshan Xiong,
> 
> The patch 1e1db2a97be5: "staging: lustre: clio: Revise read ahead
> implementation" from Oct 2, 2016, leads to the following static
> checker warning:
> 
> 	drivers/staging/lustre/lustre/lov/lov_io.c:611 lov_io_read_ahead()
> 	error: 'sub' dereferencing possible ERR_PTR()
> 
> drivers/staging/lustre/lustre/lov/lov_io.c
>   589  static int lov_io_read_ahead(const struct lu_env *env,
>   590                               const struct cl_io_slice *ios,
>   591                               pgoff_t start, struct cl_read_ahead *ra)
>   592  {
>   593          struct lov_io *lio = cl2lov_io(env, ios);
>   594          struct lov_object *loo = lio->lis_object;
>   595          struct cl_object *obj = lov2cl(loo);
>   596          struct lov_layout_raid0 *r0 = lov_r0(loo);
>   597          unsigned int pps; /* pages per stripe */
>   598          struct lov_io_sub *sub;
>   599          pgoff_t ra_end;
>   600          loff_t suboff;
>   601          int stripe;
>   602          int rc;
>   603  
>   604          stripe = lov_stripe_number(loo->lo_lsm, cl_offset(obj, start));
>   605          if (unlikely(!r0->lo_sub[stripe]))
>   606                  return -EIO;
>   607  
>   608          sub = lov_sub_get(env, lio, stripe);
>                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> Do we need error handling here?

Indeed, this needs error handling. Thanks for pointing it out. I will push a patch soon.

Jinshan

> 
>   609  
>   610          lov_stripe_offset(loo->lo_lsm, cl_offset(obj, start), stripe, &suboff);
>   611          rc = cl_io_read_ahead(sub->sub_env, sub->sub_io,
>   612                                cl_index(lovsub2cl(r0->lo_sub[stripe]), suboff),
>   613                                ra);
>   614          lov_sub_put(sub);
>   615  
> 
> regards,
> dan carpenter
