From: Andreas Dilger <adilger@sun.com>
Date: Fri, 11 Jul 2008 15:32:07 -0600
Subject: [Lustre-devel] GSS cross-realm on MDT -> OST
In-Reply-To: <20080709211013.GA8132@lanczos.q-leap.de>
References: <C49A27F8.4E91%peter.braam@sun.com> <4874F47B.4010209@sun.com>
	<20080709202937.GB6239@webber.adilger.int>
	<20080709211013.GA8132@lanczos.q-leap.de>
Message-ID: <20080711213207.GK6239@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 09, 2008  23:10 +0200, Bernd Schubert wrote:
> On Wed, Jul 09, 2008 at 02:29:38PM -0600, Andreas Dilger wrote:
> > Please see bug 15827 with some details of the problem.
> > 
> > For the non-kerberos case having administrator action at the MGS is
> > the most secure.  Enabling a shared secret key passed to mkfs.lustre
> > like "--mgs-key e85021aee637f7250e482a9a5b23cb0d" sent from the
> > MDT/OST to the MGS at first connect time at least provides some
> > restriction on adding new devices to the filesystem.
> 
> Hmm, is a secret key really neccessary, for me this sounds a bit like
> security by obscurity. Wouldn't it be better to to have a two way
> MDT/OST registration?
> 
> 1.) As it is, simply mount the filesystem on the MDT/OST. But this will
> put this filesystem into a registered, but unconfirmed state on the MGS.
> 
> 2.) Introduce a lctl command for the MGS to list all
> registered-but-unconfirmed systems. And another command to confirm the 
> registration.

Yes, this is defintely the minimum requirement, and it should be the
default behaviour.  For the case when completely automated configuration
is needed (e.g. during automated regression testing) then having the
--mgs-key mount option would still prevent "random" OSTs from joining the
filesystem (as in bug 15827).

> On on the other hand, this approach might conflict with the writeconf concept.

No, I think 2-step authentication is the most secure, but there needs
to some way to circumvent it, only if the MGS allows it of course.  If
the MGS is compromised then all bets are off...

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
