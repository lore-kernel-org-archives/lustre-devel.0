From: aayush agrawal <aayush.agrawal@calsoftinc.com>
Date: Mon, 18 Aug 2014 15:57:25 +0530
Subject: [Lustre-devel] Full stripe write in RAID6
Message-ID: <53F1D50D.7080805@calsoftinc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I am using lustre version: 2.5.0 and corresponding kernel 2.6.32-358.
Apart from default patches which comes with lustre 2.5.0, I applied 
below patches in kernel 2.6.32-358.

raid5-configurable-cachesize-rhel6.patch
raid5-large-io-rhel5.patch
raid5-stats-rhel6.patch
raid5-zerocopy-rhel6.patch
raid5-mmp-unplug-dev-rhel6.patch
raid5-mmp-unplug-dev.patch
raid5-maxsectors-rhel5.patch
raid5-stripe-by-stripe-handling-rhel6.patch

I have taken all above patches from below link:
https://github.com/Xyratex/lustre-stable/tree/b_neo_1.4.0/lustre/kernel_patches/patches

My question is: If I am writing entire stripe then whether RAID6 md 
driver need to read any of the blocks from underlying device?
I am asking this question on lustre mailing list because I have seen 
that lustre community has changed RAID driver a lot.

I have created RAID6 device with default (512K)  chunk size with total 6 
RAID devices.
cat  /sys/block/md127/queue/optimal_io_size =>2097152
I believe this is full stripe (512K * 4 data disks).

If I write 2MB data, I am expected to dirty entire stripe hence what I 
believe I need not require to read either any of the data block or 
parity blocks. Thus avoiding RAID6 penalties.
Whether md/raid driver supports full stripe writes by avoiding RAID 6 
penalties?

I also expected 6 disks will receive 512K writes each. (4 data disk+ 2 
parity disks).
If I do IO directly on block device /dev/md127, I do observe reads 
happening on md device and underlying raid devices as well.

  #mdstat o/p:
  md127 : active raid6 sdah1[5] sdai1[4] sdaj1[3] sdcg1[2] sdch1[1]
  sdci1[0]
        41926656 blocks super 1.2 level 6, 512k chunk, algorithm 2
  [6/6] [UUUUUU]

  # raw -qa
  /dev/raw/raw1:  bound to major 9, minor 127

  #time (dd if=/dev/zero of=/dev/raw/raw1 bs=2M count=1 && sync)
(also tried with of=/dev/md127 oflag=direct but the same results.)
  # iostat shows:
  Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read Blk_wrtn
  sdaj1             7.00         0.00       205.20          0 1026
  sdai1             6.20         0.00       205.20          0 1026
  sdah1             9.80         0.00       246.80          0 1234
  sdcg1             6.80         0.00       205.20          0 1026
  sdci1             9.60         0.00       246.80          0 1234
  sdch1             6.80         0.00       205.20          0 1026
  md127             0.80         0.00       819.20          0 4096

I assume if I perform writes in multiples of "optimal_io_size" I would 
be doing full stripe writes thus avoiding reads.
But unfortunately with two 2M writes, I do see reads happening for some 
these drives.
Same case for count=4 or 6 (equal to data disks or total disks).

  # time (dd if=/dev/zero of=/dev/raw/raw1 bs=2M count=2 && sync)

  Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read Blk_wrtn
  sdaj1            13.40       204.80       410.00       1024 2050
  sdai1            11.20         0.00       410.00          0 2050
  sdah1            15.80         0.00       464.40          0 2322
  sdcg1            13.20       204.80       410.00       1024 2050
  sdci1            16.60         0.00       464.40          0 2322
  sdch1            12.40       192.00       410.00        960 2050
  md127             1.60         0.00      1638.40          0 8192

I believe RAID6 penalties will exist if it's a random write, but in case 
of seq. write, whether they will still exist in some other form in Linux 
md/raid driver?
My aim is to maximize RAID6 Write IO rate with sequential Writes 
withoutRAID6 penalties.

Rectify me wherever my assumptions are wrong. Let me know if any other 
configuration param (for block device or md device) is required to 
achieve the same.

Thanks,
Aayush


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20140818/c81615a8/attachment.htm>
