From: James Simmons <jsimmons@infradead.org>
Date: Fri, 9 Mar 2012 12:56:54 +0000 (GMT)
Subject: [Lustre-devel] oldest lustre supported SUSE kernel
In-Reply-To: <F19688880B763E40B28B2B462677FBF805EC1D8901@MX09A.corp.emc.com>
References: <F19688880B763E40B28B2B462677FBF805E803B132@MX09A.corp.emc.com>
	<9C0BB3E3-D296-42A0-89EA-67F299215215@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805EC1D87AC@MX09A.corp.emc.com>
	<A9B334AF-99CD-4D1B-91ED-277FEB9E8282@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805EC1D8901@MX09A.corp.emc.com>
Message-ID: <alpine.LFD.2.02.1203091256060.9158@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > As you can tell, we do not build the SLES11 SP0 client ourselves automatically, only the SP1 client,
> > but if the effort is not huge it would be preferable to keep this client working.  We typically try to
> > keep the range of working clients as large as possible, since administrators may not have as much
> > control over the running clients as they do over the servers.
> > 
> > I would guess (without having looked at the SP0 kernel) that it may just be possible to change
> > lustre/autoconf/lustre-core.m4 to check this prototype, and move the two ll_page_mkwrite() helpers
> > into their own "#ifdef HAVE_PAGE_MKWRITE_VM_FAULT" section separate from HAVE_VM_OP_FAULT.
> Thanks for confirming that it is still supported. And I verified it can be fixed as you described. I created LU-1200 and attached the fix there.

Sorry to nit pick but can you push your patch with gerrit instead of just 
posting it to the Jira ticket.
