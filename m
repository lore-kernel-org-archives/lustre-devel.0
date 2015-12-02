From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 2 Dec 2015 12:23:50 +0300
Subject: [lustre-devel] [PATCH 11/40] staging: lustre: DLC Feature
	dynamic net config
In-Reply-To: <1448062576-23757-12-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-12-git-send-email-jsimmons@infradead.org>
Message-ID: <20151202092349.GK18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 20, 2015 at 06:35:47PM -0500, James Simmons wrote:
> +
> +	return 0;
>  
>   failed4:
> -	lnet_ping_target_fini();
> - failed3:
>  	the_lnet.ln_refcount = 0;
> +	lnet_ping_md_unlink(pinfo, &md_handle);
> +	lnet_ping_info_free(pinfo);
> + failed3:
>  	lnet_acceptor_stop();
> +	rc = LNetEQFree(the_lnet.ln_ping_target_eq);
> +	LASSERT(rc == 0);
        ^^^^^^^^^^^^^^^^

>   failed2:
>  	lnet_destroy_routes();
>  	lnet_shutdown_lndnis();
> @@ -1263,8 +1609,12 @@ LNetNIInit(lnet_pid_t requested_pid)
>  	lnet_unprepare();
>   failed0:
>  	LASSERT(rc < 0);
        ^^^^^^^^^^^^^^^

These asserts contradict each other.


But mostly please remove all the GW-BASIC style numbered labeled names
from this patch.  You wouldn't name your variables "int var1, var2,
var3" so for label names you should give them meaningful names as well.
Don't name them after the goto location, name them after the label
location to say the first thing that the label does.

err_fini:
err_acceptor_stop:
err_destroy_routes:
err_empty_list:

regards,
dan carpenter
