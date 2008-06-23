From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Mon, 23 Jun 2008 14:52:33 -0700
Subject: [Lustre-devel] changelog interface
Message-ID: <48601B21.8030209@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter, early in the changelog arch we had designed the changelog user 
API as a series of files that would show up under a special .lustre 
directory.  After the ZFS changelog investigation, I think it makes more 
sense to try and match the ZFS API so that changes to user tools are 
minimized.

So, as "zfs diff snap1 snap2" produces a stream to stdout, I think we 
should make "lctl diff startrec [endrec]" produce a similar stream.  We 
would also need a "lctl purge endrec" to clear out old changelog records.

Any objections?
