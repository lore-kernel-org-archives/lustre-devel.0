From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Mon, 07 Jan 2008 13:10:36 -0500
Subject: [Lustre-devel] moving /proc to $MNT/.lustre
In-Reply-To: <4782665E.1070406@sun.com>
References: <47618E96.3080709@sun.com>
	<F8F87424-C3EE-45E7-838E-95E1047F521D@Sun.COM>
	<4782665E.1070406@sun.com>
Message-ID: <1199729436.23325.65.camel@pc.ilinx>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, 2008-01-07 at 09:50 -0800, Nathan Rutman wrote:
> well, that's why I asked.  As I said, Andreas and I are in agreement, 
> and it certainly makes sense from a portability point of view, as well 
> as consistency with future features (snapshots, audit logs, etc.), and 
> the final elimination of our various /proc locking headaches.  But yes, 
> it would break user's scripts  - that's a 1-time thing, and I think not 
> too terrible.

Is it possible to support both for a release or two to give people time
to migrate and have an actual implementation to test against as they
work to port their scripts?  The alternative is that given that we don't
provide public beta binaries or nightly snapshot binaries, we'd be
requiring people who want to port, test and release their ports on "flag
day" to build from CVS to test.

b.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 189 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080107/c1d2062b/attachment.pgp>
