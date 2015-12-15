From: Joe Perches <joe@perches.com>
Date: Tue, 15 Dec 2015 06:27:56 -0800
Subject: [lustre-devel] [PATCH 1/7] staging: lustre: Delete unnecessary
 goto statements in six functions
In-Reply-To: <566D7830.9060000@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7830.9060000@users.sourceforge.net>
Message-ID: <1450189676.3551.1.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, 2015-12-13 at 14:52 +0100, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 13 Dec 2015 09:30:47 +0100
> 
> Six goto statements referred to a source code position directly behind them.
> Thus omit such unnecessary jumps.

I suggest you leave a blank line instead
of deleting the goto.

> diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
[]
> @@ -554,7 +554,6 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
> ?		retval = NULL;
> ?	else
> ?		retval = dentry;
> -	goto out;
> ? out:
> ?	if (req)
> ?		ptlrpc_req_finished(req);

etc.,,
