From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Mar 2019 05:56:59 +0000
Subject: [lustre-devel] [PATCH 05/28] lustre: obd_type: discard
 obd_type_lock
In-Reply-To: <87va074zfd.fsf@notabene.neil.brown.name>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
 <155168109825.31333.15239500185325332009.stgit@noble.brown>
 <alpine.LFD.2.21.1903220349550.32231@casper.infradead.org>
 <87va074zfd.fsf@notabene.neil.brown.name>
Message-ID: <29614E64-E2E6-4D92-B87C-602E35A8B0D9@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Mar 22 2019, James Simmons wrote:
>> This lock is only used to protect typ_refcnt, so change
>> that to an atomic_t and discard the lock.
>> 
>> The lock also covers calls to try_module_get and module_put,
>> but this serves no purpose as it does not prevent the module
>> from being unloaded.
>> 
>> Finally, the return value for the call to try_module_get is
>> ignored, which is not safe.
> 
> Nak. Looking at the code we can easily use the kref of the
> kobject instead. The two special cases for the ref_count
> can be removed. The one for mdc_request was removed in
> patch https://review.whamcloud.com/30419. The other refcount
> use in mgc looks like its for supporting lustre 1.4 version
> logs. I bet that can be removed. Andreas can state if it is
> still need.

James, I looked at that patch, but don't see anything in it
that relates to this.  Could you please point out the specific
code you are referencing.  Definitely there may be old code
lurking in some corners that could be removed.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
