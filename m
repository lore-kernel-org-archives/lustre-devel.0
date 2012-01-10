From: wangdi <di.wang@whamcloud.com>
Date: Tue, 10 Jan 2012 15:11:18 -0800
Subject: [Lustre-devel] FID update (reserve a bit in FID to identify it
 refers Metadata object or data object)
Message-ID: <4F0CC596.4020409@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

Here is an update about FID in Lustre.

We will implement FID on OST in lustre 2.x, so both data and metadata objects will be referred by FID in lustre. But different with the FID on MDT, OST FID will not use OI to map the real inode.(OI is container for FID->inode mapping). Instead it will still store objects under /O structure (like the current 1.8 implementation), so they can have an internal reference from the namespace to avoid problems with fsck.

Then

1. for metadata object, it will be stored under /root and referenced by OI, i.e. the target must lookup OI by FID to get the inode.
2. for data object, it will be stored under /O and referenced by the /O structure itself, i.e. the target can lookup /O by some kind of FID hash to get the inode.

So the target(MDT or OST) needs to know it is meta_data object or data object, to figure out where to get the object by FID.

We thought to reserve the highest bit of OID to identify whether it is a metadata or data object, so the maximum OID for each sequence will shrink from 4 billion to 2 billion.

For FID related information, you can referhttp://wiki.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs

Thanks
WangDi
