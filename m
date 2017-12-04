From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 4 Dec 2017 11:40:18 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: check result of
 register_shrinker
In-Reply-To: <babc0c09-2384-e277-1c68-e07457c6e5fd@gmail.com>
References: <20171202184046.4338-1-akaraliou.dev@gmail.com>
 <985AF256-3022-45FB-BFCF-1E2B0F622AA8@intel.com>
 <babc0c09-2384-e277-1c68-e07457c6e5fd@gmail.com>
Message-ID: <20171204084018.jxfunaapcx36jd6r@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Dec 03, 2017 at 07:59:07PM +0300, ak wrote:
> Thank you for your extensive comments.
> 
> I've also thought about adding more protection into unregister_shrinker(),
> but not sure how to properly organize the patch set, because there will be
> three patches:
>     * change in mm/vmscan that adds protection and sanitizer.
>     * fixed change for Lustre driver
>     * there also two explicit usages of shrinker->nr_deferred in drivers -
>        good idea to fix too.
> All patches have different lists of maintainers, and second and third depend
> on first one. And I don't like to send them separately.
> So, I'm going to at least prepend this patch with mm/vmscan one.

Fix the style for the Lustre patch and resend.  Then patch
unregister_shrinker().  Then remove the checks.

The unregister_shrinker() changes seem like a good idea, but I haven't
really looked at it.  It might be more involved than it seems.

regards,
dan carpenter
