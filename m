From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 16 Dec 2016 21:53:55 +0300
Subject: [lustre-devel] [PATCH] staging : lustre : Remove braces from
	single-line body.
In-Reply-To: <1481913804.29291.92.camel@perches.com>
References: <1481911175-19592-1-git-send-email-khan.tabrez21@gmail.com>
	<1481913804.29291.92.camel@perches.com>
Message-ID: <20161216185355.GH8176@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Tabrez khan <khan.tabrez21@gmail.com>, oleg.drokin@intel.com, jsimmons@infradead.org, andreas.dilger@intel.com, devel@driverdev.osuosl.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Fri, Dec 16, 2016 at 10:43:24AM -0800, Joe Perches wrote:
> On Fri, 2016-12-16 at 23:29 +0530, Tabrez khan wrote:
> > Remove unnecessary braces {} from single line if statement.
> > This warning is found using checkpatch.pl.
> []
> > diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
> []
> > @@ -1134,9 +1134,9 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
> >  	}
> >  
> >  	/* Sanity checks for a reconnected import. */
> > -	if (!(imp->imp_replayable) != !(msg_flags & MSG_CONNECT_REPLAYABLE)) {
> > +	if (!(imp->imp_replayable) != !(msg_flags & MSG_CONNECT_REPLAYABLE))
> >  		CERROR("imp_replayable flag does not match server after reconnect. We should LBUG right here.\n");
> > -	}
> > +
> 
> There are one too many blank lines now.

I was expecting checkpatch.pl to catch the extra blank.  It was there in
the last patch as well.  Apparently it doesn't.

regards,
dan carpenter
