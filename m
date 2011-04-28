From: Eric Barton <eeb@whamcloud.com>
Date: Fri, 29 Apr 2011 00:04:37 +0100
Subject: [Lustre-devel] F/S stats visualisation
Message-ID: <008a01cc05f8$a6b26840$f41738c0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I've made some histograms that visualise the F/S stats people have
so kindly sent in.  There are a couple of surprises which seem to
do with how the filesystems were set up (e.g. huge #s of inodes
reserved but not used on OSTs) and used (different ratios of ops).

The attached PDF has a summary for each filesystem containing...

* Filesystem name

* Ratio of MDS 1K blocks to MDS inodes
  Ratio of OST 1K blocks to MDS inodes
  Ratio of OST inodes to MDS inodes

* Histogram of operation counts

* Histogram of blocks total (blue) and used (red) on the MDS
  and all OSTs

* Histogram of inodes total (blue) and used (red) on the MDS
  and all OSTs 

...hope you find it useful.

          Cheers,
                   Eric


-------------- next part --------------
A non-text attachment was scrubbed...
Name: Lustre stats.pdf
Type: application/pdf
Size: 619235 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110429/e5fbfcf5/attachment.pdf>
