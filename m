From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 17 Apr 2018 10:39:02 +0300
Subject: [lustre-devel] [PATCH 18/25] staging: lustre: libcfs: clear up
 failure patch in cfs_cpt_*_print
In-Reply-To: <1523851807-16573-19-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
 <1523851807-16573-19-git-send-email-jsimmons@infradead.org>
Message-ID: <20180417073902.slxgixniiytw7guk@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Dmitry Eremin <dmitry.eremin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

> -err:
> -	if (rc < 0)
> -		return rc;
> -
>  	return tmp - buf;
> +
> +err:
> +	return -E2BIG;


We finally fixed this bug!  Hooray!  But it's like you guys are
deliberately writing in terrible style.  You can just return directly
and then you would have avoided this bug altogether from square one!

People think that by adding little twists and moving code to the end
of the function the it will be less buggy.  It's not true.  It's like at
a hospital if they just swept the cockroaches under the bed, just
because it's at the end of the function where you can't see it or review
it doesn't mean it's not buggy.

regards,
dan carpenter
