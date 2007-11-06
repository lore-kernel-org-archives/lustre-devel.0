From: RS RS <rs2006ts@hotmail.com>
Date: Tue, 6 Nov 2007 11:59:26 -0500
Subject: [Lustre-devel] Checksum Algorithm
Message-ID: <BLU115-W12E96D373F497BF1EDDCD0CD890@phx.gbl>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

We have seen a huge performance drop in 1.6.3, due to the checksum being enabled by default.  I looked at the algorithm being used, and it is actually a CRC32, which is a very strong algorithm for detecting all sorts of problems, such as single bit errors, swapped bytes, and missing bytes.

I've been experimenting with using a simple XOR algorithm.  I've been able to recover most of the lost performance.  This algorithm will detected corrupted bytes and words.  This algorithm will not detect swapped bytes errors, but I think that these are pretty rare.  This algorithm will not detect missing bytes, but I suspect that other things in Lustre or LNET will detect this problem.  This algorithm will not detect two errors that offset each other, such as a single bit error in two words that are a multiple of 4 bytes apart.

Should we consider using a more efficient checksum algorithm, in order to regain performance?  Should the algorithm be configurable?  

-Roger

_________________________________________________________________
Boo!?Scare away worms, viruses and so much more! Try Windows Live OneCare!
http://onecare.live.com/standard/en-us/purchase/trial.aspx?s_cid=wl_hotmailnews
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20071106/30a2c755/attachment.htm>
