From: Bernd Schubert <bs@q-leap.de>
Date: Wed, 9 Jul 2008 23:10:13 +0200
Subject: [Lustre-devel] GSS cross-realm on MDT -> OST
In-Reply-To: <20080709202937.GB6239@webber.adilger.int>
References: <C49A27F8.4E91%peter.braam@sun.com> <4874F47B.4010209@sun.com>
	<20080709202937.GB6239@webber.adilger.int>
Message-ID: <20080709211013.GA8132@lanczos.q-leap.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jul 09, 2008 at 02:29:38PM -0600, Andreas Dilger wrote:
> On Jul 09, 2008  11:25 -0600, Eric Mei wrote:
> > Yes Ben is right, currently in a same realm any MDS could authenticate 
> > with any MDS and OSS. But afaics the problem is nothing to do with 
> > Kerberos. It's because currently Lustre have no config information about 
> > the server cluster membership, each server target have no idea what 
> > other targets are.
> > 
> > So solve this, we can either place the configuration on each MDS/OST 
> > nodes - as Ben proposed in last mail; or probably better centrally 
> > managed by MGS, thus MDT/OST would be able to get uptodate server 
> > cluster information. Would it work?
> 
> I think that MDT/OST addition to the filesystem needs to be managed
> properly at the MGS, regardless of whether Kerberos is in use or not.
> 
> Please see bug 15827 with some details of the problem.
> 
> For the non-kerberos case having administrator action at the MGS is
> the most secure.  Enabling a shared secret key passed to mkfs.lustre
> like "--mgs-key e85021aee637f7250e482a9a5b23cb0d" sent from the
> MDT/OST to the MGS at first connect time at least provides some
> restriction on adding new devices to the filesystem.

Hmm, is a secret key really neccessary, for me this sounds a bit like
security by obscurity. Wouldn't it be better to to have a two way
MDT/OST registration?

1.) As it is, simply mount the filesystem on the MDT/OST. But this will
put this filesystem into a registered, but unconfirmed state on the MGS.

2.) Introduce a lctl command for the MGS to list all
registered-but-unconfirmed systems. And another command to confirm the 
registration.

On on the other hand, this approach might conflict with the writeconf concept.


Cheers,
Bernd
