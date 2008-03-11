From: Kilian CAVALOTTI <kilian@stanford.edu>
Date: Tue, 11 Mar 2008 11:12:35 -0700
Subject: [Lustre-devel] Feature request: expand SNMP scope
Message-ID: <200803111112.35170.kilian@stanford.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

After a discussion started on lustre-discuss@ [1], I'd like to join 
other users [2] to make an official feature request about the Lustre 
SNMP module.

I believe it could be extremely useful for Lustre systems administrators 
to get more than just the number of free space and available objects 
from the SNMP module.  For instance, it could be interesting to get the 
following live stats through SNMP:
on clients: /proc/fs/lustre/llite/*/stats 
on OSSes:   /proc/fs/lustre/obdfilter/*/stats 
on MDSes:   /proc/fs/lustre/mds/*/stats on MDSes.

But it would be especially interesting to not limit the SNMPable values 
to just a subset of what's available in /proc/fs/lustre. Since it looks 
like some work has begun to rework the Lustre /proc structure [3], 
maybe it would be the right opportunity to incorporate SNMP more 
closely into the new UI. The idea being to translate everything 
available in /proc into SNMP variables, so that future variables could 
be exported too, without having to explicitly add them to the SNMP 
code.

I have little idea on how easily this can be achieved, but that would be 
an excellent foundation stone for next-to-come Lustre monitoring 
systems.

[1]http://lists.lustre.org/pipermail/lustre-discuss/2008-March/005277.html
[2]http://lists.lustre.org/pipermail/lustre-devel/2008-January/001504.html, 
and bug #14729
[3]http://lists.lustre.org/pipermail/lustre-devel/2008-January/001475.html

Thanks!
--
Kilian

PS: I also created bug #15197 to keep track of this.
