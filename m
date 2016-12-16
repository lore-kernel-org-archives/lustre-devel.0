From: Joe Perches <joe@perches.com>
Date: Fri, 16 Dec 2016 10:43:24 -0800
Subject: [lustre-devel] [PATCH] staging : lustre : Remove braces from
	single-line body.
In-Reply-To: <1481911175-19592-1-git-send-email-khan.tabrez21@gmail.com>
References: <1481911175-19592-1-git-send-email-khan.tabrez21@gmail.com>
Message-ID: <1481913804.29291.92.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tabrez khan <khan.tabrez21@gmail.com>, oleg.drokin@intel.com, jsimmons@infradead.org, andreas.dilger@intel.com
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Fri, 2016-12-16 at 23:29 +0530, Tabrez khan wrote:
> Remove unnecessary braces {} from single line if statement.
> This warning is found using checkpatch.pl.
[]
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
[]
> @@ -1134,9 +1134,9 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
>  	}
>  
>  	/* Sanity checks for a reconnected import. */
> -	if (!(imp->imp_replayable) != !(msg_flags & MSG_CONNECT_REPLAYABLE)) {
> +	if (!(imp->imp_replayable) != !(msg_flags & MSG_CONNECT_REPLAYABLE))
>  		CERROR("imp_replayable flag does not match server after reconnect. We should LBUG right here.\n");
> -	}
> +

There are one too many blank lines now.

And that's an awful lot of !s.

Generically, it might make simpler reading code to
cast to bool instead of using !.

Most code uses !! to make sure whatever value is
either 0 or 1 without changing the logic/polarity.
