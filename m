From: Manoj Joseph <manoj.p.joseph@oracle.com>
Date: Wed, 30 Jun 2010 00:23:53 -0600
Subject: [Lustre-devel] Compiling Lustre with latest kernel.
In-Reply-To: <AANLkTimpSVRSY6xz6VR71e_VtJtV1gt8qQwv8IbnTRqQ@mail.gmail.com>
References: <AANLkTimpSVRSY6xz6VR71e_VtJtV1gt8qQwv8IbnTRqQ@mail.gmail.com>
Message-ID: <4C2AE2F9.2070205@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 06/29/2010 10:52 PM, Onkar Mahajan wrote:
> Is it possible to compile Lustre as a module ?
> AFAIK , it's not possible.

Actually, Lustre is built as a bunch of kernel modules.

> How do I compile Lustre with the latest Linux kernel ?
> I went through the documentation on building from source
> but It only talks about compiling with RHEL & SLES kernels
> and not general  kernels.

Here is the documentation for building lustre.
http://wiki.lustre.org/index.php/Building_Lustre_Code

As you might know by now, lustre servers need the linux kernel to be
built with some patches that are supplied along with lustre. These
patches are known to work with the supported kernels.

So, if you build against a supported kernel, the build process should be
relatively straightforward.

If you are trying to build against an unsupported kernel, it _might_
require considerable amount of work.

If you do not have a very good reason, I'd suggest sticking with the
supported kernels. You should find a list of supported kernels at the
top of the file lustre/ChangeLog in the lustre source tree.

You should be able to download the supported kernel tarballs from here:
http://downloads.lustre.org/public/kernels

Good luck!

Cheers
Manoj
