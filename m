From: Abe Asraoui <AbeA@supermicro.com>
Date: Thu, 26 Oct 2017 00:27:24 +0000
Subject: [lustre-devel] Zfs recovery time
In-Reply-To: <3675C0E7-8B03-49FE-9410-2C0B1184BE4D@intel.com>
References: <a9bcec7262434923a9276e5fc839994a@Ex2013-MBX2.supermicro.com>
 <3675C0E7-8B03-49FE-9410-2C0B1184BE4D@intel.com>
Message-ID: <9a61cf88df0041fea3e8b237ebac37a2@Ex2013-MBX2.supermicro.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Andreas,

I'm looking for any data regarding resilvering time for a zfs pool in a case of a drive failure and 
again with full or fragmented pools.

Thanks in Advance,
Abe

-----Original Message-----
From: Dilger, Andreas [mailto:andreas.dilger at intel.com] 
Sent: Wednesday, October 25, 2017 11:34 AM
To: Abe Asraoui (Server)
Cc: Lustre Development List
Subject: Re: [lustre-devel] Zfs recovery time

On Oct 25, 2017, at 12:00, Abe Asraoui <AbeA@supermicro.com> wrote:
> 
> Hi All,
> 
> Does anyone know what the Zfs recovery time for a disk failure under lustre filesystem, or is there any documentation around this topic ?

Could you please clarify the question?  Do you mean what the resilvering time is for a ZFS zpool when a drive fails?  That depends heavily on your zpool configuration (number and performance of drives), and how full/fragmented the pool is.  This is more of a ZFS question, but some numbers I saw recently were about 20-40MB/s resilvering for the *used* data on the HDD.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
