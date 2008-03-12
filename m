From: patrice.lucas at cea.fr <patrice.lucas@cea.fr>
Date: Wed, 12 Mar 2008 15:00:05 +0100
Subject: [Lustre-devel] Feature request: expand SNMP scope
Message-ID: <47D7E1E5.1050102@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

> After a discussion started on lustre-discuss@ [1], I'd like to join 
> other users [2] to make an official feature request about the Lustre 
> SNMP module.
> 
> I believe it could be extremely useful for Lustre systems administrators 
> to get more than just the number of free space and available objects 
> from the SNMP module.  For instance, it could be interesting to get the 
> following live stats through SNMP:
> on clients: /proc/fs/lustre/llite/*/stats 
> on OSSes:   /proc/fs/lustre/obdfilter/*/stats 
> on MDSes:   /proc/fs/lustre/mds/*/stats on MDSes.

Kilian, as you noticed from my previous mail and patch, I definitely 
agree with you.

> 
> But it would be especially interesting to not limit the SNMPable values 
> to just a subset of what's available in /proc/fs/lustre. Since it looks 
> like some work has begun to rework the Lustre /proc structure [3], 
> maybe it would be the right opportunity to incorporate SNMP more 
> closely into the new UI. The idea being to translate everything 
> available in /proc into SNMP variables, so that future variables could 
> be exported too, without having to explicitly add them to the SNMP 
> code.
> 
> I have little idea on how easily this can be achieved, but that would be 
> an excellent foundation stone for next-to-come Lustre monitoring 
> systems.

In the patch "bug #14729", I just add a new external access from the 
snmp agent to a /proc entry . I create this patch as an instance of what 
could be easyly done. The goal was to start to discuss around this need 
of improving access to monitoring data. This patch was accepted by 
Lustre team but without discussion. This method is not integrated to the 
inner Lustre code. If people change /proc entries, the snmp agent code 
must clearly be rewrite. I agree with you when you emphasize the need to 
link the snmp code to the rest of the Lustre development.

 From a more integrated point of view, do you think it could be a good 
idea to benefit from Lustre itself to deliver monitoring data ? Lustre 
is a parallel filesystem. Data delivered by Lustre can be accessed by 
remote client. Instead of using "/proc", can Lustre benefits from its 
capability of distributed filesystem to deliver monitoring data ? By 
doing that, we could lose the advantage of snmp to interface with many 
available common snmp network monitoring tools.

> 
> [1]http://lists.lustre.org/pipermail/lustre-discuss/2008-March/005277.html
> [2]http://lists.lustre.org/pipermail/lustre-devel/2008-January/001504.html, 
> and bug #14729
> [3]http://lists.lustre.org/pipermail/lustre-devel/2008-January/001475.html
> 
> Thanks!
> --
> Kilian
> 
> PS: I also created bug #15197 to keep track of this.


Thanks,
Patrice LUCAS
