From: Andreas Dilger <adilger@sun.com>
Date: Wed, 09 Jul 2008 14:29:38 -0600
Subject: [Lustre-devel] GSS cross-realm on MDT -> OST
In-Reply-To: <4874F47B.4010209@sun.com>
References: <C49A27F8.4E91%peter.braam@sun.com> <4874F47B.4010209@sun.com>
Message-ID: <20080709202937.GB6239@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 09, 2008  11:25 -0600, Eric Mei wrote:
> Yes Ben is right, currently in a same realm any MDS could authenticate 
> with any MDS and OSS. But afaics the problem is nothing to do with 
> Kerberos. It's because currently Lustre have no config information about 
> the server cluster membership, each server target have no idea what 
> other targets are.
> 
> So solve this, we can either place the configuration on each MDS/OST 
> nodes - as Ben proposed in last mail; or probably better centrally 
> managed by MGS, thus MDT/OST would be able to get uptodate server 
> cluster information. Would it work?

I think that MDT/OST addition to the filesystem needs to be managed
properly at the MGS, regardless of whether Kerberos is in use or not.

Please see bug 15827 with some details of the problem.

For the non-kerberos case having administrator action at the MGS is
the most secure.  Enabling a shared secret key passed to mkfs.lustre
like "--mgs-key e85021aee637f7250e482a9a5b23cb0d" sent from the
MDT/OST to the MGS at first connect time at least provides some
restriction on adding new devices to the filesystem.

With Kerberos systems there could be principals for the OSTs stored
inside their filesystems by mkfs.lustre or tunefs.lustre that can be
loaded into the keyring at mount time.  Having it inside the filesystem
(instead of e.g /etc/{something}) ensures that it is always available
to the MDT/OST if it can mount.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
