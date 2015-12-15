From: Joe Perches <joe@perches.com>
Date: Tue, 15 Dec 2015 10:10:11 -0800
Subject: [lustre-devel] [PATCH 1/7] staging: lustre: Delete unnecessary
 goto statements in six functions
In-Reply-To: <20151215174844.GE5284@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7830.9060000@users.sourceforge.net>
	<1450189676.3551.1.camel@perches.com> <20151215144133.GC5284@mwanda>
	<1450191751.3551.14.camel@perches.com> <20151215174844.GE5284@mwanda>
Message-ID: <1450203011.4142.4.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2015-12-15 at 20:48 +0300, Dan Carpenter wrote:
> On Tue, Dec 15, 2015 at 07:02:31AM -0800, Joe Perches wrote:
> > This is the original code:
> > 
> > 	result = foo();
> > 	if (result)
> > 		goto label;
> > 
> > 	result = bar();
> > 	if (result)
> > 		goto label;
> > 
> > 	result = baz();
> > 	if (result)
> > 		goto label;
> > 
> > label:
> > 	go on...
> > 
> 
> No.??There is no test.??The original code looks like:
> 
> 	result = foo();
> 	if (result)
> 		goto out;
> 	result = baz();
> 	goto out;
> out:
> 	go on..
> 
> regards,
> dan carpenter

Here is the original code:
---------------------
	/* Copy hsm_progress struct */
	req_hpk = req_capsule_client_get(&req->rq_pill, &RMF_MDS_HSM_PROGRESS);
	if (req_hpk == NULL) {
		rc = -EPROTO;
		goto out;
	}

	*req_hpk = *hpk;
	req_hpk->hpk_errval = lustre_errno_hton(hpk->hpk_errval);

	ptlrpc_request_set_replen(req);

	rc = mdc_queue_wait(req);
	goto out;
out:
	ptlrpc_req_finished(req);
	return rc;
}
---------------------

I think if the last goto out; is to be removed,
then it should be replaced by a blank line.

It separates the last operation block from the return.

cheers, Joe
