From: Wendy Cheng <s.wendy.cheng@gmail.com>
Date: Fri, 11 Oct 2013 10:11:33 -0700
Subject: [Lustre-devel] Kernel crash from "mkfs.lustre --index" setting
Message-ID: <CABgxfbG2DWP-Md7SjQnhEkSUcqaBFqkyGMc0f=t=cVsPHu80sg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This panic seems to be generic regardless the platform, though I'm
actually on Intel Xeon Phi Lustre (client) nodes.

New to Lustre, I mistakenly thought the "index" option of mkfs.lustre
was for software raid so I formatted one of the server disks as the
following:

server> mkfs.lustre --reformat --fsname=lus1 --mgs --mdt --index=1 /dev/sdd1
server> mkfs.lustre --reformat --ost --fsname=lus1
--mgsnode=192.168.20.46 at o2ib0 --index=1 /dev/sde1

The client mount immediately crashed at lmv_get_info(). The attached
patch fixed that particular panic ... but unfortunately crashed at an
assertion further down the path. I'll be travelling next week so might
give up pursuing this issue. The disks are now subsequently
re-formatted with index=0 - things seem to work fine and performance
numbers collected. Three questions here:

1. What is this "index" option all about ?
2. Does the problem worth being fixed ? Or is it a user error ?
3. The performance numbers (again, NOT Xeon Phi specific) surprise me.
Would this list be a good place to ask questions ?

-- Wendy
-------------- next part --------------
A non-text attachment was scrubbed...
Name: index.patch
Type: application/octet-stream
Size: 1884 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20131011/978dfb1b/attachment.obj>
