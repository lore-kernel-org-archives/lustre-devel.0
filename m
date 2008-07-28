From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Mon, 28 Jul 2008 09:03:03 -0400
Subject: [Lustre-devel] Lustre version patchless kernel?
In-Reply-To: <4886A3E7.6050904@hp.com>
References: <4886A29C.2000009@hp.com> <4886A3E7.6050904@hp.com>
Message-ID: <1217250183.22114.110.camel@pc.ilinx>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2008-07-22 at 23:22 -0400, Kossey, Robert wrote:
> We also see this on recent releases like 1.6.5.1.  Why do you bother to 
> distribute kernel-lustre-smp RPMs if the kernels are not patched?

MDS and OSS kernels *are* patched.  My 1.6.5 here does not report it's
patchless:

lustre: 1.6.5
kernel: 47
build:  1.6.5-19691231190000-PRISTINE-.cache.OLDRPMS.20080513015618.linux-smp-2.6.9-67.0.7.EL_lustre.1.6.5.i686-2.6.9-67.0.7.EL_lustre.1.6.5smp

If you are using our kernel on your MDS/OSS and it's reporting
patchless, this indeed is a bug.  Could you please search our bugzilla
to see if there is a similar bug and if not found, file a bug in our
bugzilla about it?

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 189 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080728/ecc8bcdc/attachment.pgp>
