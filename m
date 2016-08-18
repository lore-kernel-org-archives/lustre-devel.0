From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Thu, 18 Aug 2016 13:43:30 -0700
Subject: [lustre-devel] CentOS 6 - Build problems with kmod
In-Reply-To: <CY4PR11MB1751486ABC8E7B3723D5549ACB150@CY4PR11MB1751.namprd11.prod.outlook.com>
References: <CY4PR11MB1751486ABC8E7B3723D5549ACB150@CY4PR11MB1751.namprd11.prod.outlook.com>
Message-ID: <9957200e-17fe-2b8d-ad99-e8dfb5019f12@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yes, those instructions should be taken with a huge grain of salt.  For
instance, instructions for compiling lustre should really employ a
custom user and talk about "useradd" and such.  Also, most users can
skip the whole custom-patched-kernel section.  Hopefully all developers
will be able to stop that too by the time 2.9.0 comes out.

The error you are seeing almost certainly means that you don't have a
kernel installed that offers symbols compatible with the kernel that
lustre was compiled against.

It sounds like you built your own kernel.  Did you install all the
resulting kernel packages before building lustre (including any
devel-related packages)?  Is your custom kernel the newest kernel
installed on your system?

Chris

On 08/18/2016 01:00 PM, Patrick Farrell wrote:
> Good afternoon,
> 
> 
> I'm trying to build and install updated Lustre master on CentOS 6 for
> the first time in a month or two, and I'm having trouble.
> 
> 
> I use the build procedure documented here:
> 
> https://wiki.hpdd.intel.com/pages/viewpage.action?pageId=8126821
> 
> 
> I've got some new kmod-* RPMs, and I need to install those to install
> Lustre, which is fine, except I get a huge string of messages like this
> when I try:
> 
> error: Failed dependencies:
>         ksym(__init_waitqueue_head) = 0xffc7c184 is needed by
> kmod-lustre-2.8.56_44_g288e55b_dirty-1.el6.x86_64
>         ksym(__mutex_init) = 0x4bf79039 is needed by
> kmod-lustre-2.8.56_44_g288e55b_dirty-1.el6.x86_64
> 
> I've rebuilt and reinstalled my kernel with this latest version of
> Lustre.  Error messages remain the same, and I can't install.
> 
> 
> Any thoughts or advice?
> 
> 
> - Patrick
> 
> 
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
