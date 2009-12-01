From: Nikita Danilov <nikita.danilov@clusterstor.com>
Date: Tue, 1 Dec 2009 18:00:39 +0300
Subject: [Lustre-devel] Fwd: Disk rebuild
Message-ID: <8acda98c0912010700r684bfcf6h94ec347cd6190990@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

On 03 Feb 2009 Jody McIntyre wrote:
 > It is possible to significantly reduce resync (but not recovery) times
 > using bitmaps, but these have been shown to hurt performance
 > significantly. ?Another approach, journal-guided?resynchronization, was
 > studied in a 2005 paper but has never been merged into the kernel. ?The
 > paper shows improvements in resync times from 254 seconds to 0.21
 > seconds (for a 1 GB test array) with under 5% performance impact. ?This
 > is an option if we're willing to develop and maintain the patches to do
 > it.

what is the status of this? Is ext3 guided resync code (RHEL 5 version
was posted on lkml in October) used by Lustre?

 >
 > Cheers,
 > Jody

Thank you,
Nikita.
