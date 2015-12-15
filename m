From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 15 Dec 2015 19:26:57 +0100
Subject: [lustre-devel] staging: lustre: Delete unnecessary goto
 statements in six functions
In-Reply-To: <1450203011.4142.4.camel@perches.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7830.9060000@users.sourceforge.net>
	<1450189676.3551.1.camel@perches.com> <20151215144133.GC5284@mwanda>
	<1450191751.3551.14.camel@perches.com> <20151215174844.GE5284@mwanda>
	<1450203011.4142.4.camel@perches.com>
Message-ID: <56705B71.6090307@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> 	rc = mdc_queue_wait(req);
> 	goto out;
> out:
> 	ptlrpc_req_finished(req);
> 	return rc;
> }
> ---------------------
>
> I think if the last goto out; is to be removed,
> then it should be replaced by a blank line.
>
> It separates the last operation block from the return.

Would you like to point a very specific coding style issue out?
How often should jump labels preceded with blank lines?

Regards,
Markus
