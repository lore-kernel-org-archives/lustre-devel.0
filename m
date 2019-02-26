From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 26 Feb 2019 20:41:43 +0000
Subject: [lustre-devel] [PATCH 03/37] lustre: embed typ_kobj if obd_type
In-Reply-To: <871s3vv6h0.fsf@notabene.neil.brown.name>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494490.24125.1514109985903155907.stgit@noble.brown>
 <alpine.LFD.2.21.1902241644070.22752@casper.infradead.org>
 <871s3vv6h0.fsf@notabene.neil.brown.name>
Message-ID: <BN8PR09MB3347B7CAE3A21D36FD12A18AD67B0@BN8PR09MB3347.namprd09.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Sun, Feb 24 2019, James Simmons wrote:

>> For some reason this patch didn't land in my mailbox but I can see it 
>> on https://patchwork.kernel.org/patch/10819037. This patch is mostly 
>> good since llite now uses dynamic_kobj_ktype with its own ktype. Thus 
>> class_sysfs_release() will never be called with llite.
>>
>> What does need fixing is
>>
>> --------------------------------------------------------
>> type->typ_kobj.kset = lustre_kset;
>>
>> changed to:
>>
>> type->typ_kobj.kset = kset_get(&lustre_kset);
>
>Why?  Where is the kset_put() what will match this?

Just an off the cuff review. I'm work on a full fledge patch.
Just testing on OpenSFS branch since the server side has
some unique needs. Basically in the old days the lov and osc
layer were present on servers so you have a /sys/fs/lustre/osc
tree on the MDS server for example. Now a new layer osp
has replaced it but we need to keep the old osc tree structure
around. The function part is some people test with everything
on one node which can create unique conditions to handle.
I'm trying to sort it out.

>> --------------------------------------------------------
>>
>> Next change needed it change all the
>>
>> kobject_put(&type->typ_kobj); -> kobject_del(&type->typ_kobj);
>>
>
>Why?
>kobject_del() removed from sysfs.  kobject_put() calls kobject_release()
>on the last put.  This calls kobject_cleanup() which calls kobject_del()
>if needed.
>So why do we need to call kobject_del()?

You are right. I missed that kobject_cleanup() calls kobject_del(). I noticed
It latter when you pointed out. 
