From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Feb 2019 16:52:55 +0000 (GMT)
Subject: [lustre-devel] [PATCH 03/37] lustre: embed typ_kobj if obd_type
In-Reply-To: <155053494490.24125.1514109985903155907.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494490.24125.1514109985903155907.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902241644070.22752@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


For some reason this patch didn't land in my mailbox but I can
see it on https://patchwork.kernel.org/patch/10819037. This patch
is mostly good since llite now uses dynamic_kobj_ktype with its own
ktype. Thus class_sysfs_release() will never be called with llite.

What does need fixing is

--------------------------------------------------------
type->typ_kobj.kset = lustre_kset;

changed to:

type->typ_kobj.kset = kset_get(&lustre_kset);
--------------------------------------------------------

Next change needed it change all the 

kobject_put(&type->typ_kobj); -> kobject_del(&type->typ_kobj); 

So we properly handle the kset referencing. That is currently
broken by me :-(
