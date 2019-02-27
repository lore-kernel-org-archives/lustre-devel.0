From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Feb 2019 22:36:16 +0000 (GMT)
Subject: [lustre-devel] [PATCH 11/37] lustre: kernelcomm: make
 libcfs_kkuc_msg_put static.
In-Reply-To: <87va16t8pi.fsf@notabene.neil.brown.name>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494545.24125.14664274760505145343.stgit@noble.brown>
 <alpine.LFD.2.21.1902241711110.22752@casper.infradead.org>
 <87va16t8pi.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1902272233530.29759@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> >> libcfs_kkuc_msg_put() is never used outside of kernelcomm.c,
> >> so make it static.
> >
> > In the OpenSFS branch libcfs_kkuc_msg_put() is used by the
> > client and server code. While this is okay now in the future
> > this will be reverted. So do we keep it as is so it can handle
> > server code or do this change and then later do what I added
> > below:
> 
> Where is it used?
> 
> Looking in the current whamcloud master
> Commit f7155420024e ("LU-11208 tests: add version check to sanity tests")
> 
> $ git grep libcfs_kkuc_msg_put
> lustre/include/lustre_kernelcomm.h:int libcfs_kkuc_msg_put(struct file *fp, void *payload);
> lustre/obdclass/kernelcomm.c: * libcfs_kkuc_msg_put - send an message from kernel to userspace
> lustre/obdclass/kernelcomm.c:int libcfs_kkuc_msg_put(struct file *filp, void *payload)
> lustre/obdclass/kernelcomm.c:EXPORT_SYMBOL(libcfs_kkuc_msg_put);
> lustre/obdclass/kernelcomm.c:                   rc = libcfs_kkuc_msg_put(reg->kr_fp, payload);
> 
> libcfs_kkuc_msg_put() is only called from libcfs_kkuc_group_put().
> What am I missing?

I'm remembering older code. You are correct. Let me give it a proper 
review.
