From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 21 Nov 2015 21:45:36 +0300
Subject: [lustre-devel] [PATCH 06/40] staging: lustre: remove uses of
	IS_ERR_VALUE()
In-Reply-To: <1448062576-23757-7-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-7-git-send-email-jsimmons@infradead.org>
Message-ID: <20151121184536.GY18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 20, 2015 at 06:35:42PM -0500, James Simmons wrote:
> @@ -1577,15 +1578,20 @@ static int mdc_ioc_changelog_send(struct obd_device *obd,
>  	 * New thread because we should return to user app before
>  	 * writing into our pipe
>  	 */
> -	rc = PTR_ERR(kthread_run(mdc_changelog_send_thread, cs,
> -				 "mdc_clg_send_thread"));
> -	if (!IS_ERR_VALUE(rc)) {
> -		CDEBUG(D_CHANGELOG, "start changelog thread\n");
> -		return 0;
> +	task = kthread_run(mdc_changelog_send_thread, cs,
> +			   "mdc_clg_send_thread");
> +	if (IS_ERR(task)) {
> +		rc = PTR_ERR(task);
> +		CERROR("%s: can't start changelog thread: rc = %d\n",
> +		       obd->obd_name, rc);
> +		kfree(cs);
> +	} else {
> +		rc = 0;
> +		CDEBUG(D_CHANGELOG, "%s: started changelog thread\n",
> +		       obd->obd_name);
>  	}
>  
>  	CERROR("Failed to start changelog thread: %d\n", rc);
> -	kfree(cs);
>  	return rc;
>  }
>  

This will print an error when it succeeds.

It better to keep the error path and the success path as separate as
possible.  For the normal case, the success path is at indent level 1
and the fail path is at indent level 2.  Like this:

	ret = one();
	if (ret)
		return ret;
	ret = two();
	if (ret)
		return ret;

	return 0;

When it's written that way it is:

	success;
	if (ret)
		fail_path;

	success;
	if (ret)
		fail_path;
	success;


The current code looks like:

	success;
	if (ret) {
		fail;
	} else {
		success;
	}
	mixed;

You see what I mean?  Ideally the function should look like a list of
directives in a row at indent level 1 with only minimal indenting for
errors.

regards,
dan carpenter
