From: NeilBrown <neilb@suse.com>
Date: Tue, 26 Feb 2019 09:38:51 +1100
Subject: [lustre-devel] [PATCH 03/37] lustre: embed typ_kobj if obd_type
In-Reply-To: <alpine.LFD.2.21.1902241644070.22752@casper.infradead.org>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494490.24125.1514109985903155907.stgit@noble.brown>
 <alpine.LFD.2.21.1902241644070.22752@casper.infradead.org>
Message-ID: <871s3vv6h0.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Feb 24 2019, James Simmons wrote:

> For some reason this patch didn't land in my mailbox but I can
> see it on https://patchwork.kernel.org/patch/10819037. This patch
> is mostly good since llite now uses dynamic_kobj_ktype with its own
> ktype. Thus class_sysfs_release() will never be called with llite.
>
> What does need fixing is
>
> --------------------------------------------------------
> type->typ_kobj.kset = lustre_kset;
>
> changed to:
>
> type->typ_kobj.kset = kset_get(&lustre_kset);

Why?  Where is the kset_put() what will match this?


> --------------------------------------------------------
>
> Next change needed it change all the 
>
> kobject_put(&type->typ_kobj); -> kobject_del(&type->typ_kobj); 
>

Why?
kobject_del() removed from sysfs.  kobject_put() calls kobject_release()
on the last put.  This calls kobject_cleanup() which calls kobject_del()
if needed.
So why do we need to call kobject_del()?

Thanks,
NeilBrown


> So we properly handle the kset referencing. That is currently
> broken by me :-(
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190226/cc38e8e6/attachment.sig>
