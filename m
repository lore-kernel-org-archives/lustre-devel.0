From: NeilBrown <neilb@suse.com>
Date: Thu, 26 Apr 2018 16:14:10 +1000
Subject: [lustre-devel] [PATCH] staging: kernel.h: Prevent macro
 expantion bug in container_of_safe()
In-Reply-To: <20180426055827.GA18346@mwanda>
References: <20180426055827.GA18346@mwanda>
Message-ID: <87bme6mr4d.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Apr 26 2018, Dan Carpenter wrote:

> There aren't many users of this so it doesn't cause a problem, but we
> obviously want to use "__mptr" here instead of "ptr" to prevent the
> parameter from being executed twice.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index b5a8e78c6c75..593fb8d250a2 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -978,7 +978,7 @@ static inline void ftrace_dump(enum ftrace_dump_mode oops_dump_mode) { }
>  	BUILD_BUG_ON_MSG(!__same_type(*(ptr), ((type *)0)->member) &&	\
>  			 !__same_type(*(ptr), void),			\
>  			 "pointer type mismatch in container_of()");	\
> -	IS_ERR_OR_NULL(ptr) ? ERR_CAST(ptr) :				\
> +	IS_ERR_OR_NULL(__mptr) ? ERR_CAST(__mptr) :			\
>  		((type *)(__mptr - offsetof(type, member))); })
>  
>  /* Rebuild everything on CONFIG_FTRACE_MCOUNT_RECORD */

Arg, of course.  Thanks.
Acked-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180426/374eb610/attachment.sig>
