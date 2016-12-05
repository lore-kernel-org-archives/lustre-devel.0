From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 5 Dec 2016 23:54:36 +0300
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: headers: Move
 functions out of lustre_idl.h
In-Reply-To: <1480707650-24089-6-git-send-email-jsimmons@infradead.org>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
	<1480707650-24089-6-git-send-email-jsimmons@infradead.org>
Message-ID: <20161205205435.GD31243@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Ben Evans <bevans@cray.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Dec 02, 2016 at 02:40:49PM -0500, James Simmons wrote:
> -/* If LDLM_ENQUEUE, 1 slot is already occupied, 1 is available.
> - * Otherwise, 2 are available.
> - */
> -#define ldlm_request_bufsize(count, type)				\
> -({								      \
> -	int _avail = LDLM_LOCKREQ_HANDLES;			      \
> -	_avail -= (type == LDLM_ENQUEUE ? LDLM_ENQUEUE_CANCEL_OFF : 0); \
> -	sizeof(struct ldlm_request) +				   \
> -	(count > _avail ? count - _avail : 0) *			 \
> -	sizeof(struct lustre_handle);				   \
> -})
> -

> +/**
> + * ldlm_request_bufsize
> + *
> + * @count:	number of ldlm handles
> + * @type:	ldlm opcode
> + *
> + * If opcode=LDLM_ENQUEUE, 1 slot is already occupied,
> + * LDLM_LOCKREQ_HANDLE -1 slots are available.
> + * Otherwise, LDLM_LOCKREQ_HANDLE slots are available.
> + *
> + * Return:	size of the request buffer
> + */
> +int ldlm_request_bufsize(int count, int type)
> +{
> +	int avail = LDLM_LOCKREQ_HANDLES;
> +
> +	if (type == LDLM_ENQUEUE)
> +		avail -= LDLM_ENQUEUE_CANCEL_OFF;
> +
> +	if (count > avail)
> +		avail = (count - avail) * sizeof(struct lustre_handle);
> +	else
> +		avail = 0;
> +
> +	return sizeof(struct ldlm_request) + avail;
> +}
> +

This is a nice cleanup.

regards,
dan carpenter
