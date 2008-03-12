From: Fernsler; Karen <fernsler@ncsa.uiuc.edu>
Date: Wed, 12 Mar 2008 07:12:48 -0500
Subject: [Lustre-devel] getting mds_hdr DB_NOTFOUND
Message-ID: <20080312121248.GB23436@ncsa.uiuc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I'm running:

e2fsck -y -v --mdsdb mdsdb --ostdb osth3_1 /dev/mapper/27l4

and getting:

Pass 6: Acquiring information for lfsck
error getting mds_hdr (3685469441:8) in /post/cfg/mdsdb: DB_NOTFOUND: No matching key/data pair found
e2fsck: aborted

Any ideas how to get around this?

This is

e2fsck -V
e2fsck 1.40.4.cfs1 (31-Dec-2007)
        Using EXT2FS Library version 1.40.4.cfs1, 31-Dec-2007


thanks,
-k


-- 
Karen Fernsler Systems Engineer
National Center for Supercomputing Applications
ph: (217) 265 5249
email: fernsler at ncsa.uiuc.edu
