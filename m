From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 25 Oct 2017 18:34:08 +0000
Subject: [lustre-devel] Zfs recovery time
In-Reply-To: <a9bcec7262434923a9276e5fc839994a@Ex2013-MBX2.supermicro.com>
References: <a9bcec7262434923a9276e5fc839994a@Ex2013-MBX2.supermicro.com>
Message-ID: <3675C0E7-8B03-49FE-9410-2C0B1184BE4D@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

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
