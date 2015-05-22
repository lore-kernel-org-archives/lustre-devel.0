From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 22 May 2015 14:15:36 +0300
Subject: [lustre-devel] [PATCH 1/3] staging:lustre: remove tcpip
	abstraction from libcfs
In-Reply-To: <1432248378-28912-2-git-send-email-jsimmons@infradead.org>
References: <uja.ornl@gmail.com>
	<1432248378-28912-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20150522111536.GA19434@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch does a lot of stuff all at once and it is hard to review.  It
could easily be broken into patches which are easy to review.

> @@ -1378,15 +1378,15 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
>  	ksocknal_txlist_done(ni, &zombies, 1);
>  	ksocknal_peer_decref(peer);
>  
> - failed_1:
> +failed_1:

Do unrelated white space changes in a different patch.  It just makes
reviewing complicated to mix easy to review white space changes in with
everything else.

>  	if (hello != NULL)
>  		LIBCFS_FREE(hello, offsetof(ksock_hello_msg_t,
>  					    kshm_ips[LNET_MAX_INTERFACES]));
>  
>  	LIBCFS_FREE(conn, sizeof(*conn));
>  
> - failed_0:
> -	libcfs_sock_release(sock);
> +failed_0:
> +	sock_release(sock);

Do a rename patch by itself.  You can rename a bunch of functions at the
same time, that's fine.  Personally, you can even move the functions
between files, that's also fine with me and doesn't complicate my
review.

Ok in this next section we move functions around and rename them but
also introduce some bad changes in the new function.

> +static int
> +lnet_sock_ioctl(int cmd, unsigned long arg)
> +{
> +	struct file *sock_filp;
> +	struct socket *sock;
> +	int fd = -1;
> +	int rc;
> +
> +	rc = sock_create(PF_INET, SOCK_STREAM, 0, &sock);
> +	if (rc != 0) {
> +		CERROR("Can't create socket: %d\n", rc);
> +		return rc;
> +	}
> +
> +	sock_filp = sock_alloc_file(sock, 0, NULL);
> +	if (!sock_filp) {


sock_alloc_file() never returns NULL, only valid pointers on success or
ERR_PTRs on failue.


> +		rc = -ENOMEM;
> +		sock_release(sock);
> +		goto out;
> +	}
> +
> +	rc = kernel_sock_unlocked_ioctl(sock_filp, cmd, arg);

This is an unrelated cleanup.  Do it in a different patch.

> +
> +	fput(sock_filp);
> +out:
> +	if (fd >= 0)
> +		sys_close(fd);

This is a new change as well.  "fd" is always -1 so this is dead code.

> +	return rc;
> +}
> +

Here is the old function:

> -static int
> -libcfs_sock_ioctl(int cmd, unsigned long arg)
> -{
> -	mm_segment_t	oldmm = get_fs();
> -	struct socket  *sock;
> -	int		rc;
> -	struct file    *sock_filp;
> -
> -	rc = sock_create (PF_INET, SOCK_STREAM, 0, &sock);
> -	if (rc != 0) {
> -		CERROR ("Can't create socket: %d\n", rc);
> -		return rc;
> -	}
> -
> -	sock_filp = sock_alloc_file(sock, 0, NULL);
> -	if (IS_ERR(sock_filp)) {

This check was correct in the original.

> -		sock_release(sock);
> -		rc = PTR_ERR(sock_filp);
> -		goto out;
> -	}
> -
> -	set_fs(KERNEL_DS);
> -	if (sock_filp->f_op->unlocked_ioctl)
> -		rc = sock_filp->f_op->unlocked_ioctl(sock_filp, cmd, arg);
> -	set_fs(oldmm);
> -
> -	fput(sock_filp);
> -out:
> -	return rc;
> -}

This patch has some bug fixes as well.  Those should be sent as one
patch per bugfix with a proper changelog.

regards,
dan carpenter
