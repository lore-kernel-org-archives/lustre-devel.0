From: jmferrer <jmferrer@caton.es>
Date: Mon, 22 Oct 2007 12:56:37 +0200
Subject: [Lustre-devel] The mds_connect operation failed with -11
Message-ID: <471C81E5.5000601@caton.es>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi, list:


I'm trying configure lustre with:

1 MGS -------------> 192.168.3.100 with mkfs.lustre --mgs /dev/md1 ;
mount -t lustre ...

1 MDT ------------> 192.168.3.101 with mkfs.lustre --fsname=datafs00
--mdt --mgsnode=192.168.3.100 /dev/sda3 ; mount -t lustre ...


4 ost -----------> 192.168.3.102-104 with mkfs.lustre --fsname=datafs00
--ost --mgsnode=192.168.3.100 at tcp0 /dev/sda3  ; mount -t lustre.....
foreach node



But when I try mount from any node:

LOG IN NODE:
LustreError: 4743:0:(obd_mount.c:1927:lustre_fill_super()) Unable to
mount  (-22)
LustreError: 11-0: an error occurred while communicating with
192.168.3.101 at tcp. The mds_connect operation failed with -11
LustreError: Skipped 1 previous similar message
LustreError: 11-0: an error occurred while communicating with
192.168.3.101 at tcp. The mds_connect operation failed with -11
LustreError: Skipped 5 previous similar messages
LustreError: 11-0: an error occurred while communicating with
192.168.3.101 at tcp. The mds_connect operation failed with -11
LustreError: Skipped 10 previous similar messages
LustreError: 11-0: an error occurred while communicating with
192.168.3.101 at tcp. The mds_connect operation failed with -11
LustreError: Skipped 20 previous similar messages


LOG IN MGS:
    ---------


thanks and sorry for my english.
