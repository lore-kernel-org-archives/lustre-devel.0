From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Wed, 20 Aug 2008 15:23:35 +0400
Subject: [Lustre-devel] [RFC] "lctl readonly" modification proposal
Message-ID: <200808201523.36720.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

Currently "lctl readonly" command is used in recovery-related acceptance 
test as a disk write barrier, any server operations after such a 
barrier do not change disk state. replay-dual.sh:test_14 is an example, 
it uses test-framework.sh:replay_barrier which calls "lctl readonly".

However "lctl readonly" cannot immediately "freeze" disk state because 
it does device sync right before setting device r/o.

The additional sync breaks COS unit tests: COS-effect (syncs between 
dependent transactions) is hidden before the R/O barrier because the 
barrier does device sync anyway and COS-effect is invisible after the 
barrier because all disk writes are disabled already.

Currently syncs are issued twice at different levels of call stack:

lctl readonly
      |
mdt_iocontrol -> dt_sync
      |
   osd_ro
      |
__lvfs_set_rdonly -> lvfs_sbdev_sync(dev)
      |
dev_set_rdonly(dev, jdev)

Is there any requirement to have a device sync before setting the device 
r/o?  

If not, syncless variant of "lctl readonly" would be more useful for 
testing. If changing of "lctl readonly" behavior is not possible, it 
would be good to have a syncless set R/O operation under another ioctl.

syncless R/O and a network barrier might be a good simulation of server 
crash without a need of machine restart.

Thanks,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
