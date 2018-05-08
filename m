From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 8 May 2018 14:45:00 +0300
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obdclass: change
 object lookup to no wait mode
In-Reply-To: <1525285308-15347-5-git-send-email-jsimmons@infradead.org>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-5-git-send-email-jsimmons@infradead.org>
Message-ID: <20180508114500.qrtnjax4siupgv3n@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Lai Siyao <lai.siyao@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

>  	/*
>  	 * Allocate new object. This may result in rather complicated
>  	 * operations, including fld queries, inode loading, etc.
>  	 */
>  	o = lu_object_alloc(env, dev, f, conf);
> -	if (IS_ERR(o))
> +	if (unlikely(IS_ERR(o)))
>  		return o;
>  

This is an unrelated and totally pointless.  likely/unlikely annotations
hurt readability, and they should only be added if it's something which
is going to show up in benchmarking.  lu_object_alloc() is already too
slow for the unlikely() to make a difference and anyway IS_ERR() has an
unlikely built in so it's duplicative...

Anyway, I understand that Intel has been ignoring kernel.org instead of
sending forwarding their patches properly so you're doing a difficult
and thankless job...  Thanks for that.  I'm sure it's frustrating to
look at these patches for you as well.

regards,
dan carpenter
