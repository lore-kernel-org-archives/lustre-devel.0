From: =?UTF-8?Q?Giedrius_Statkevi=C4=8Dius?= <giedrius.statkevicius@gmail.com>
Date: Thu, 20 Oct 2016 14:43:36 -0000
Subject: [lustre-devel] [bug report] staging: lustre: clio: Revise read
	ahead implementation
In-Reply-To: <20161020105747.GA7003@elgon.mountain>
References: <20161020105747.GA7003@elgon.mountain>
Message-ID: <CABNMmsC4-fLCH+Mz9Y4ChnkkedoNj1HfrJcD8gi6BKZ4H7zWRQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thursday, October 20, 2016, Dan Carpenter <dan.carpenter@oracle.com>
wrote:
> Hello Jinshan Xiong,
>
> The patch 1e1db2a97be5: "staging: lustre: clio: Revise read ahead
> implementation" from Oct 2, 2016, leads to the following static
> checker warning:
>
>         drivers/staging/lustre/lustre/lov/lov_io.c:611 lov_io_read_ahead()
>         error: 'sub' dereferencing possible ERR_PTR()
>
> drivers/staging/lustre/lustre/lov/lov_io.c
>    589  static int lov_io_read_ahead(const struct lu_env *env,
>    590                               const struct cl_io_slice *ios,
>    591                               pgoff_t start, struct cl_read_ahead
*ra)
>    592  {
>    593          struct lov_io *lio = cl2lov_io(env, ios);
>    594          struct lov_object *loo = lio->lis_object;
>    595          struct cl_object *obj = lov2cl(loo);
>    596          struct lov_layout_raid0 *r0 = lov_r0(loo);
>    597          unsigned int pps; /* pages per stripe */
>    598          struct lov_io_sub *sub;
>    599          pgoff_t ra_end;
>    600          loff_t suboff;
>    601          int stripe;
>    602          int rc;
>    603
>    604          stripe = lov_stripe_number(loo->lo_lsm, cl_offset(obj,
start));
>    605          if (unlikely(!r0->lo_sub[stripe]))
>    606                  return -EIO;
>    607
>    608          sub = lov_sub_get(env, lio, stripe);
>                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hey Dan,
May I ask what static checker are you using?
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161020/c759927a/attachment-0001.htm>
