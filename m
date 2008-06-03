From: Matthew Ahrens <Matthew.Ahrens@sun.com>
Date: Mon, 02 Jun 2008 17:50:49 -0700
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <18498.43788.847173.750390@gargle.gargle.HOWL>
References: <18493.29199.765234.755534@gargle.gargle.HOWL>
	<C46829E1.5610%peter.braam@sun.com>
	<20080601045302.GA29979@eng.sun.com>
	<18498.43788.847173.750390@gargle.gargle.HOWL>
Message-ID: <48449569.4080406@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
> Jeff Bonwick writes:
>  > I'd suggest working with Matt Ahrens on this.
> 
> Hello,
> 
> we were discussing recently what is needed from the DMU to implement quotas
> and other forms of space accounting. Our basic premise is that it is desirable
> to keep DMU part of the quota support at minimum, and to implement only
> mechanism here, leaving policy to the upper layers.

I agree with this premise.  However, your proposed implementation (especially 
the asynchronous update mechanism and associated pending file) seems 
unnecessarily complicated.

I would suggest that we simply update a "database" (eg. ZAP object or sparse 
array) of userid -> space usage from syncing context when the space is 
allocated/freed (ie, dsl_dataset_block_{born,kill}).  I believe that the 
problems this presents[*] will be more tractable than the method you outlined.

--matt

[*] eg, if the DB object is stored in the user's objset, then updating it in 
syncing context may be problematic.  if it is stored in the MOS, carrying it 
along when doing snapshot operations will be painful (snapshot, clone, send, 
recv, rollback, etc).
