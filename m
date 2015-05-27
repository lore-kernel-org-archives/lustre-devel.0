From: Patrick Farrell <paf@cray.com>
Date: Wed, 27 May 2015 20:03:52 +0000
Subject: [lustre-devel] Possible minor bug
Message-ID: <DB0C8A206669AC40B1C4E52A8584A6F614C88D93@CFWEX01.americas.cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

While doing some other work, I noticed something I believe is a potential problem in the server side quota code.

Specifically, in qmt_glimpse_lock:

While the resource lock (a spin lock) is held, it does

OBD_ALLOC_PTR(work);

Since allocations can sleep, doesn't this allocation need to be atomic?

So, following the current Lustre convention, it should be:
LIBCFS_ALLOC_ATOMIC(work, sizeof(struct
ldlm_glimpse_work));

I have seen no actual bugs from this, but I hit a hang while modifying the equivalent code in ofd_intent_policy for lock ahead, and I think the same hang is theoretically possible here.  My understanding is that, in general, doing allocations while holding a spin lock is not recommended.

I'm hoping for other input before I go further - Am I right that this is something which needs fixing?  If so, I'll open an LU and submit a patch.

Thanks,
- Patrick
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150527/f8295b6c/attachment.htm>
