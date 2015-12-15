From: Joe Perches <joe@perches.com>
Date: Tue, 15 Dec 2015 10:34:11 -0800
Subject: [lustre-devel] staging: lustre: Delete unnecessary goto
 statements in six functions
In-Reply-To: <56705B71.6090307@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7830.9060000@users.sourceforge.net>
	<1450189676.3551.1.camel@perches.com> <20151215144133.GC5284@mwanda>
	<1450191751.3551.14.camel@perches.com> <20151215174844.GE5284@mwanda>
	<1450203011.4142.4.camel@perches.com>
	<56705B71.6090307@users.sourceforge.net>
Message-ID: <1450204451.4142.19.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2015-12-15 at 19:26 +0100, SF Markus Elfring wrote:
> > 	rc = mdc_queue_wait(req);
> > 	goto out;
> > out:
> > 	ptlrpc_req_finished(req);
> > 	return rc;
> > }
> > ---------------------
> > 
> > I think if the last goto out; is to be removed,
> > then it should be replaced by a blank line.
> > 
> > It separates the last operation block from the return.
> 
> Would you like to point a very specific coding style issue out?

Other than using vertical separation can help readability?

I think there should _not_ be a hardened rule.
Style is just a guide. ?Do what you think appropriate.

> How often should jump labels preceded with blank lines?

When other nearby blocks are also separated by blank lines.

Localized consistency can be useful.

Inconsistency can make code harder to follow/predict.
