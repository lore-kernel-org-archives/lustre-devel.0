From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 6 Dec 2016 21:37:39 +0300
Subject: [lustre-devel] [bug report] staging: add Lustre file system
 client support
In-Reply-To: <44BA9680-2A0D-49E2-B073-1AA664E8328C@intel.com>
References: <20161123122959.GA17323@mwanda>
	<C7AE2AE0-89E7-49F6-B7C8-8BCF0F957045@intel.com>
	<20161206110259.GG8244@mwanda>
	<44BA9680-2A0D-49E2-B073-1AA664E8328C@intel.com>
Message-ID: <20161206183739.GI8244@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Dec 06, 2016 at 10:44:54AM -0500, Oleg Drokin wrote:
> I see, indeed, it all makes sense now.
> So basically if we unconditionally check for the size to be > 0, we should be
> fine then, I imagine.
> On the other hand there's probably no se for no param and nonzero param len,
> so it's probably even better to enforce size as zero when no param.

Checking for > 0 is not enough, because it could also have an integer
overflow on 32 bit systems.  We need to cap the upper bound as well.

regards,
dan carpenter
