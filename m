From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 3 Aug 2017 13:41:12 +0000
Subject: [lustre-devel] HSM partial archive/restore
In-Reply-To: <BN6PR1101MB2132BF4D44A3965F09A83523CBBE0@BN6PR1101MB2132.namprd11.prod.outlook.com>
References: <BN6PR1101MB2132BF4D44A3965F09A83523CBBE0@BN6PR1101MB2132.namprd11.prod.outlook.com>
Message-ID: <7B037A9A-BF93-400D-AFC1-AAD4E9B4DC97@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I've thought about partial HSM archive/restore a few times in conjunction with composite layouts.

It wouldn't be too hard to create PFL/composite layouts for chunks of the file arbitrarily (e.g. every 10GB for very large files) so that the file can be restored partially or incrementally or in parallel from multiple tapes.

This may also be useful for File Level Redundancy, so that the file can be resync'd in chunks if only part of the file is lost.

On the Lustre side, PFL has implemented virtually all of the support needed to do this in the 2.10 release.

For HSM this might involve putting the HSM archive information into the composite layout itself, so that different archive identifiers (UUIDs) can be stored for different extents of the file, or possibly different archived replica versions of the file. That would need some work, and integration with the copy tools and coordinator to be able to understand components that represent partially-restored files.

Cheers, Andreas

On Jul 27, 2017, at 21:16, Patrick Farrell <paf at cray.com<mailto:paf@cray.com>> wrote:


Hello all,


There has been some prior conversation around HSM partial archive/restore (Seagate at LUG'17: <http://cdn.opensfs.org/wp-content/uploads/2017/06/LUG-2017-Lustre-HSM-for-HPC-High-Speed-Distributed-Data-Mover-r1.11.pdf> http://cdn.opensfs.org/wp-content/uploads/2017/06/LUG-2017-Lustre-HSM-for-HPC-High-Speed-Distributed-Data-Mover-r1.11.pdf



<http://cdn.opensfs.org/wp-content/uploads/2017/06/LUG-2017-Lustre-HSM-for-HPC-High-Speed-Distributed-Data-Mover-r1.11.pdf>With complex file layouts and fallocate support being called out as requirements for enabling this.  But as far as I can tell, this has not progressed to any concrete design work.

Is this correct?  Is there work happening somewhere I'm not aware of?

If not, is there interest in starting some?  Cray has interest in this, and could help drive such a project, though we would need outside assistance (particularly with design) since we have no internal expertise relating to complex layouts.


Regards,

- Patrick



_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170803/489584eb/attachment-0001.htm>
