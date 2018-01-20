From: Joe Perches <joe@perches.com>
Date: Fri, 19 Jan 2018 17:53:59 -0800
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: Fix comment style
In-Reply-To: <1516290692-11642-2-git-send-email-fabian_huegel@web.de>
References: <20180115150259.GA17991@kroah.com>
 <1516290692-11642-1-git-send-email-fabian_huegel@web.de>
 <1516290692-11642-2-git-send-email-fabian_huegel@web.de>
Message-ID: <1516413239.14739.0.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fabian Huegel <fabian_huegel@web.de>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Lai Siyao <lai.siyao@intel.com>, "John L
 . Hammond" <john.hammond@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Ben Evans <bevans@cray.com>, NeilBrown <neilb@suse.com>
Cc: linux-kernel@i4.cs.fau.de, Christoph Volkert <linux@christoph-volkert.de>, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Thu, 2018-01-18 at 16:51 +0100, Fabian Huegel wrote:
> Most multi-line comments started on the first line, but the preferred
> linux kernel style is to start multi-line comments on the second line.
> Some comments became less readable after the change, so we changed them
> to single-line comments.
[]
> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
> 
> @@ -182,7 +179,8 @@ struct config_llog_data {
>  	struct obd_export	  *cld_mgcexp;
>  	struct mutex		    cld_lock;
>  	int			 cld_type;
> -	unsigned int		cld_stopping:1, /* we were told to stop
> +	unsigned int		cld_stopping:1, /*
> +						 * we were told to stop
>  						 * watching
>  						 */
>  				cld_lostlock:1; /* lock not requeued */

probably better for both of these to be bool
instead of bitfield.
