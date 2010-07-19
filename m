From: Vladimir Shvedoff <vshvedoff@sgi.com>
Date: Mon, 19 Jul 2010 15:39:54 -0500
Subject: [Lustre-devel] BZ 23243 is now tracking development for Lustre
	channel bonding
Message-ID: <7DBE7E62A57B1841AC909DEB9441BEE9E67C28@CF--AMER002E--3.americas.sgi.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

BZ 23243 at bugzilla.lustre.org is now tracking development for Lustre
channel bonding/multi-rail support.

The project is at its initial stage and we are calling for detailed
requirements, desirable features, design considerations, challenges, and
comments on the same.  If possible please place all your
comments/suggestions/questions into the BZ 23243 to preserve the context
although all four Lustre mailing lists are being monitored as well.

The overall objective of the project is in providing Lustre networking
with a capacity to aggregate
node's multiple network interfaces in the following configurations: 
(a) interfaces are on the same Lustre network
(b) interfaces are on different Lustre networks but handled by the same
type of LND
(c) interfaces are on different Lustre networks and handled by different
types of LND
Dynamic load balancing and failover shall be available to interfaces
comprising the aggregates. The functionality shall be available for both
Lustre clients and servers (MDS/OSS).

The following public document released by Oracle can serve as a good
starting point for discussion:
http://wiki.lustre.org/images/e/ee/Channel_Bonding_06_15_09.pdf
<http://wiki.lustre.org/images/e/ee/Channel_Bonding_06_15_09.pdf> 

 

Vladimir Shvedoff

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100719/bae06c19/attachment.htm>
