From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Wed, 11 May 2011 11:05:13 -0700
Subject: [Lustre-devel] Technical debt in the lustre build system
In-Reply-To: <EBE08B3E-7905-4A4D-9FDB-B27220455FAF@whamcloud.com>
References: <4DC46DDB.4000906@llnl.gov>
	<EBE08B3E-7905-4A4D-9FDB-B27220455FAF@whamcloud.com>
Message-ID: <4DCACFD9.8080902@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 05/10/2011 02:53 PM, Andreas Dilger wrote:

> Chris, I tend to agree with most of your statements. Having a simpler build system is desirable for everyone. It also makes sense to have "make rpms" use this build system instead of having a separate system to handle the "production" build vs "homebrew" builds, which isn't the case today.

Agreed!

> I think it would be great to see small incremental patches that fix the problems that you have detailed here. Some of them appear to be very minor changes (i.e. extra files included in the RPM packages, or poorly-named files).

I totally agree; I definitely think this needs an incremental approach. 
  But also a concerted effort to drive those incremental changes.

LLNL has tried to push up patches to clean up some of those minor 
changes in the past and failed to gain traction.  Maybe we just didn't 
push hard enough.  So this time I want to keep pushing.  And get more 
people involved so hopefully they'll understand where the incremental 
changes are leading.

> Ken also mentioned the Makefile vs. autoMakefile.am issue, and this is a historic artifact of when Lustre built on both 2.4 and 2.6 kernels, and is no longer needed. It might still make sense to have a simple "list of source files" that can be included by the various Makefiles for each platform, so that there isn't a need to modify 3 or 4 makefiles whenever a new source file is added.

Great.

> One issue with separating ldiskfs into it's own package is that fsfilt (or obd-ldiskfs on newer versions of Lustre) are linked closely to the ldiskfs code, and cannot completely be configured using the header file today. That said, it may be practical to store the results of the configure check in the ldiskfs header itself (e.g. #define HAVE_SOME_FEATURE) but this would also need a bit of work.
>
> I'd be interested to see how this is handled by the LLNL build system today.

Sure, I'll get Ned to comment on this.

>> Grantly, lustre is a bit more complex in ways...but by splitting the
>> code into multiple projects I think we can reduce the spec file complexity.
>
> I agree. However, you also need to recognize that Lustre was started when RHEL3 was the main distro, so the ability of the RPM .spec file has increased significantly since that time.  I don't mean to indicate that it _shouldn't_ be cleaned up, but it hasn't taken a priority to date, if it continues to work.

Sure, I understand that.  Though you may be giving newer versions of RPM 
too much credit. :)

Chris
