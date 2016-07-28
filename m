From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 28 Jul 2016 15:25:45 -0400
Subject: [lustre-devel] insanity in ll_dirty_page_discard_warn()
In-Reply-To: <20160728182659.GV2356@ZenIV.linux.org.uk>
References: <20160728182659.GV2356@ZenIV.linux.org.uk>
Message-ID: <FBC7930D-6970-45F6-975F-D9B349B5C7EF@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>


On Jul 28, 2016, at 2:26 PM, Al Viro wrote:

>        /* this can be called inside spin lock so use GFP_ATOMIC. */
>        buf = (char *)__get_free_page(GFP_ATOMIC);
>        if (buf) {
>                dentry = d_find_alias(page->mapping->host);
> 	...
> 	if (dentry)
> 		dput(dentry);
> 
> If it *can* be called under a spinlock, you have an obvious problem -
> dput() can sleep.  d_find_alias() might've picked a hashed dentry with
> zero refcount that got unhashed by the time of dput().  Or other references
> used to exist, but got dropped by that point...

Ah, the dput()->dentry_kill()->cpu_relax() I guess?

(the final iput cannot catch us here, I think, because we still have pages
in the mapping)

Hm? So the original reported path was:
            ll_dirty_page_discard_warn at ffffffffa0a3d252 [lustre]
            vvp_page_completion_common at ffffffffa0a7adfc [lustre]
            vvp_page_completion_write_common at ffffffffa0a7ae6b [lustre]
            vvp_page_completion_write at ffffffffa0a7b83e [lustre]
            cl_page_completion at ffffffffa05eed8f [obdclass]
            osc_completion at ffffffffa0880812 [osc]
            osc_ap_completion at ffffffffa086a544 [osc]
            brw_interpret at ffffffffa0876d69 [osc]

But we don't even have a call to osc_ap_completion from brw_interpret
anymore.

osc_ap_completion() itself has a comment that it is to be called under
cl_loi_list_lock, but then tries to take it itself, so the comment
is definitely stale.
And osc_completion() is called outside of that coverage.

I tend to think the comment is stale now, but need to do some more investigations
before I am 100% sure of that.

Thanks for bringing it to our attention.
